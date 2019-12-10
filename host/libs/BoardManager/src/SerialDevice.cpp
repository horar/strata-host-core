#include <SerialDevice.h>
#include <SerialDeviceConstants.h>

#include <rapidjson/document.h>
#include <rapidjson/error/en.h>

#include "logging/LoggingQtCategories.h"

namespace spyglass {

SerialDevice::SerialDevice(const int connectionID, const QString& name) :
    m_connection_id(connectionID), m_ucid(static_cast<uint>(connectionID)), m_name(name),
    m_device_busy(false), m_state(State::None), m_action(Action::None)
{
    m_read_buffer.reserve(READ_BUFFER_SIZE);
    m_response_timer.setSingleShot(true);
    m_response_timer.setInterval(RESPONSE_TIMEOUT_MS);

    connect(&m_serial_port, &QSerialPort::errorOccurred, this, &SerialDevice::handleError);
    connect(&m_serial_port, &QSerialPort::readyRead, this, &SerialDevice::readMessage);
    connect(&m_response_timer, &QTimer::timeout, this, &SerialDevice::handleResponseTimeout);
    connect(this, &SerialDevice::identifyDevice, this, &SerialDevice::deviceIdentification);
    connect(this, &SerialDevice::writeToPort, this, &SerialDevice::writeData);

    qCDebug(logCategorySerialDevice).nospace() << "Created new serial device: ID: 0x" << hex << m_ucid << ", name: " << m_name;
}

SerialDevice::~SerialDevice() {
    close();
    qCDebug(logCategorySerialDevice).nospace() << "Deleted serial device 0x" << hex << m_ucid;
}

bool SerialDevice::open() {
    m_serial_port.setPortName(m_name);
    m_serial_port.setBaudRate(QSerialPort::Baud115200);
    m_serial_port.setDataBits(QSerialPort::Data8);
    m_serial_port.setParity(QSerialPort::NoParity);
    m_serial_port.setStopBits(QSerialPort::OneStop);
    m_serial_port.setFlowControl(QSerialPort::NoFlowControl);

    return m_serial_port.open(QIODevice::ReadWrite);
}

void SerialDevice::close() {
    if (m_serial_port.isOpen()) {
        m_serial_port.close();
    }
}

void SerialDevice::readMessage() {
    const QByteArray data = m_serial_port.readAll();

    // messages from Strata boards ends with new line character
    int end;
    int from = 0;
    while ((end = data.indexOf('\n', from)) > -1) {
        m_read_buffer.append(data.data() + from, static_cast<size_t>(end - from));
        from = end + 1;  // +1 due to skip '\n'

        // qCDebug(logCategorySerialDevice).nospace().noquote() << "Serial device 0x" << hex << m_ucid << ": received message: " << QString::fromStdString(m_read_buffer);
        emit msgFromDevice(m_connection_id, QByteArray::fromStdString(m_read_buffer));
        m_read_buffer.clear();
    }

    if (from < data.size()) {  // message contains some data after '\n' (or has no '\n')
        m_read_buffer.append(data.data() + from, static_cast<size_t>(data.size() - from));
    }
}

void SerialDevice::write(const QByteArray& data) {
    emit writeToPort(data, QPrivateSignal());
}

void SerialDevice::writeData(const QByteArray& data) {
    if (m_device_busy) {
        qCDebug(logCategorySerialDevice).nospace() << "Serial device 0x" << hex << m_ucid << ": Cannot write to device because device is busy.";
        emit serialDeviceError(m_connection_id, "Cannot write to device because device is busy.");
    }
    else {
        qint64 written_bytes = m_serial_port.write(data);
        written_bytes += m_serial_port.write("\n");
        if (written_bytes != (data.size() + 1)) {
            qCCritical(logCategorySerialDevice).nospace() << "Serial device 0x" << hex << m_ucid << ": Cannot write whole data to device.";
            emit serialDeviceError(m_connection_id, "Cannot write whole data to device.");
        }
    }
}

void SerialDevice::handleError(QSerialPort::SerialPortError error) {
    // https://doc.qt.io/qt-5/qserialport.html#SerialPortError-enum
    if (error != QSerialPort::NoError) {
        QString err_msg = "Serial port error (" + QString::number(error) + "): " + m_serial_port.errorString();
        if (error == QSerialPort::ResourceError) {
            // board was unconnected from computer (cable was unplugged)
            qCInfo(logCategorySerialDevice).nospace().noquote() << "Serial device 0x" << hex << m_ucid << ": " << err_msg;
        }
        else {
            qCCritical(logCategorySerialDevice).nospace().noquote() << "Serial device 0x" << hex << m_ucid << ": " << err_msg;
            emit serialDeviceError(m_connection_id, err_msg);
        }
    }
}

bool SerialDevice::launchDevice() {
    if (m_serial_port.isOpen()) {
        m_device_busy = true;
        m_state = State::GetFirmwareInfo;
        /*
        // some boards need time for booting, so wait before sending JSON messages
        QTimer::singleShot(LAUNCH_DELAY_MS, [this](){ emit identifyDevice(QPrivateSignal()); });
        */
        emit identifyDevice(QPrivateSignal());  // comment if the previous command is uncommented
        return true;
    }
    else {
        return false;
    }
}

void SerialDevice::deviceIdentification() {
    switch (m_state) {
        case State::GetFirmwareInfo :
            connect(this, &SerialDevice::msgFromDevice, this, &SerialDevice::handleDeviceResponse);
            m_serial_port.clear();
            m_serial_port.write(CMD_GET_FIRMWARE_INFO "\n");
            m_action = Action::WaitingForFirmwareInfo;
            m_response_timer.start();
            break;
        case State::GetPlatformInfo :
            m_serial_port.write(CMD_REQUEST_PLATFORM_ID "\n");
            m_action = Action::WaitingForPlatformInfo;
            m_response_timer.start();
            break;
        case State::DeviceReady :
        case State::UnrecognizedDevice :
            disconnect(this, &SerialDevice::msgFromDevice, this, &SerialDevice::handleDeviceResponse);
            m_action = Action::Done;
            m_device_busy = false;
            emit deviceReady(m_connection_id, (m_state == State::DeviceReady) ? true : false);
            break;
        case State::None :
            break;
    }
}

void SerialDevice::handleDeviceResponse(const int /* connectionId */, const QByteArray& data) {
    bool is_ack = false;
    if (parseDeviceResponse(data, is_ack)) {
        switch (m_action) {
            case Action::WaitingForFirmwareInfo :
            case Action::WaitingForPlatformInfo :
                if (is_ack) {
                    break;
                }
                m_response_timer.stop();
                m_state = (m_action == Action::WaitingForFirmwareInfo) ? State::GetPlatformInfo : State::DeviceReady;
                emit identifyDevice(QPrivateSignal());
                break;
            case Action::Done :
            case Action::None :
                break;
        }
    }
    else {  // unknown or malformed device response
        m_state = State::UnrecognizedDevice;
        //emit unexpMsgFromDevice(m_connection_id, data);
        emit identifyDevice(QPrivateSignal());
    }
}

bool SerialDevice::parseDeviceResponse(const QByteArray& data, bool& is_ack) {
    rapidjson::Document doc;
    rapidjson::ParseResult result = doc.Parse(data.data());

    if (!result) {
        QString err_msg = "Cannot parse JSON: " + data + " Error at offset " + QString::number(result.Offset()) + ": " + GetParseError_En(result.Code());
        qCCritical(logCategorySerialDevice).nospace().noquote() << "Serial device 0x" << hex << m_ucid << ": " << err_msg;
        emit serialDeviceError(m_connection_id, err_msg);
        return false;
    }

    is_ack = false;
    bool ok = false;

    if (doc.HasMember(JSON_ACK)) {
        is_ack = true;

        // check value of "ack" key:
        const rapidjson::Value& val = doc[JSON_ACK];
        if (val.IsString()) {
            if ((m_action == Action::WaitingForFirmwareInfo) && (val == JSON_GET_FW_INFO)) {
                ok = true;
            }
            else if ((m_action == Action::WaitingForPlatformInfo) && (val == JSON_REQ_PLATFORM_ID)) {
                ok = true;
            }
        }

        // check value of "payload" key:
        if (ok && doc.HasMember(JSON_PAYLOAD)) {
            ok = false;
            const rapidjson::Value& payload = doc[JSON_PAYLOAD];
            if (payload.HasMember(JSON_RETURN_VALUE)) {
                const rapidjson::Value& val = payload[JSON_RETURN_VALUE];
                if (val.IsBool()) {
                    ok = val.GetBool();
                }
            }
        }
    }
    else if (doc.HasMember(JSON_NOTIFICATION)) {
        const rapidjson::Value& notif = doc[JSON_NOTIFICATION];
        do {
            if (!notif.IsObject()) {
                break;
            }
            if (!notif.HasMember(JSON_VALUE) || !notif.HasMember(JSON_PAYLOAD)) {
                break;
            }
            const rapidjson::Value& val = notif[JSON_VALUE];
            if (!val.IsString()) {
                break;
            }
            const rapidjson::Value& payload = notif[JSON_PAYLOAD];
            if (!payload.IsObject()) {
                break;
            }
            if (val == JSON_GET_FW_INFO) {
                if (!payload.HasMember(JSON_BOOTLOADER) || !payload.HasMember(JSON_APPLICATION)) {
                    break;
                }
                const rapidjson::Value& bldr = payload[JSON_BOOTLOADER];
                const rapidjson::Value& appl = payload[JSON_APPLICATION];
                if (!bldr.IsObject() || !appl.IsObject()) {
                    break;
                }
                if (bldr.HasMember(JSON_VERSION)) {
                    const rapidjson::Value& ver = bldr[JSON_VERSION];
                    if (ver.IsString()) {
                        m_bootloader_ver = ver.GetString();
                    }
                }
                if (appl.HasMember(JSON_VERSION)) {
                    const rapidjson::Value& ver = appl[JSON_VERSION];
                    if (ver.IsString()) {
                        m_application_ver = ver.GetString();
                    }
                }
                ok = true;
            }
            else if (val == JSON_PLATFORM_ID) {
                const char* name = JSON_VERBOSE_NAME;
                if (payload.HasMember(JSON_PLAT_ID_VERSION)) {
                    name = JSON_NAME;
                }
                if (!payload.HasMember(JSON_PLATFORM_ID) || !payload.HasMember(name)) {
                    break;
                }
                const rapidjson::Value& plat_id = payload[JSON_PLATFORM_ID];
                const rapidjson::Value& verb_name = payload[name];
                if (!plat_id.IsString() || !verb_name.IsString()) {
                    break;
                }
                m_platform_id = plat_id.GetString();
                m_verbose_name = verb_name.GetString();
                ok = true;
            }
        } while (false);
    }

    return ok;
}

void SerialDevice::handleResponseTimeout() {
    qCWarning(logCategorySerialDevice).nospace() << "Serial device 0x" << hex << m_ucid << ": Response timeout";
    m_action = Action::None;
    m_state = State::UnrecognizedDevice;
    emit identifyDevice(QPrivateSignal());
}

QVariantMap SerialDevice::getDeviceInfo() const {
    QVariantMap result;
    result.insert(QStringLiteral("connectionId"), m_connection_id);
    if (!m_device_busy) {
        result.insert(QStringLiteral("platformId"), m_platform_id);
        result.insert(QStringLiteral("verboseName"), m_verbose_name);
        result.insert(QStringLiteral("bootloaderVersion"), m_bootloader_ver);
        result.insert(QStringLiteral("applicationVersion"), m_application_ver);
    }
    return result;
}

}  // namespace
