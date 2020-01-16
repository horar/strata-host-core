#include "SerialDevice.h"
#include "SerialDeviceConstants.h"

#include <rapidjson/document.h>
#include <rapidjson/error/en.h>

#include "logging/LoggingQtCategories.h"

namespace spyglass {

QDebug operator<<(QDebug dbg, const SerialDevice* d) {
    return dbg.nospace() << "Serial device 0x" << hex << d->ucid_;
}

SerialDevice::SerialDevice(const int connectionID, const QString& name) :
    connection_id_(connectionID), ucid_(static_cast<uint>(connectionID)), name_(name),
    device_busy_(false), state_(State::None), action_(Action::None)
{
    read_buffer_.reserve(READ_BUFFER_SIZE);
    response_timer_.setSingleShot(true);
    response_timer_.setInterval(RESPONSE_TIMEOUT);

    connect(&serial_port_, &QSerialPort::errorOccurred, this, &SerialDevice::handleError);
    connect(&serial_port_, &QSerialPort::readyRead, this, &SerialDevice::readMessage);
    connect(&response_timer_, &QTimer::timeout, this, &SerialDevice::handleResponseTimeout);
    connect(this, &SerialDevice::identifyDevice, this, &SerialDevice::deviceIdentification);
    connect(this, &SerialDevice::writeToPort, this, &SerialDevice::writeData);

    qCDebug(logCategorySerialDevice).nospace() << "Created new serial device: ID: 0x" << hex << ucid_ << ", name: " << name_;
}

SerialDevice::~SerialDevice() {
    close();
    qCDebug(logCategorySerialDevice).nospace() << "Deleted serial device 0x" << hex << ucid_;
}

bool SerialDevice::open() {
    serial_port_.setPortName(name_);
    serial_port_.setBaudRate(QSerialPort::Baud115200);
    serial_port_.setDataBits(QSerialPort::Data8);
    serial_port_.setParity(QSerialPort::NoParity);
    serial_port_.setStopBits(QSerialPort::OneStop);
    serial_port_.setFlowControl(QSerialPort::NoFlowControl);

    return serial_port_.open(QIODevice::ReadWrite);
}

void SerialDevice::close() {
    if (serial_port_.isOpen()) {
        serial_port_.close();
    }
}

void SerialDevice::readMessage() {
    const QByteArray data = serial_port_.readAll();

    // messages from Strata boards ends with new line character
    int from = 0;
    int end;
    while ((end = data.indexOf('\n', from)) > -1) {
        read_buffer_.append(data.data() + from, static_cast<size_t>(end - from));
        from = end + 1;  // +1 due to skip '\n'

        // qCDebug(logCategorySerialDevice).nospace().noquote() << "Serial device 0x" << hex << ucid_ << ": received message: " << QString::fromStdString(read_buffer_);
        emit msgFromDevice(connection_id_, QByteArray::fromStdString(read_buffer_));
        read_buffer_.clear();
    }

    if (from < data.size()) {  // message contains some data after '\n' (or has no '\n')
        read_buffer_.append(data.data() + from, static_cast<size_t>(data.size() - from));
    }
}

void SerialDevice::write(const QByteArray& data) {
    emit writeToPort(data, QPrivateSignal());
}

void SerialDevice::writeData(const QByteArray& data) {
    if (device_busy_) {
        qCDebug(logCategorySerialDevice) << this << ": Cannot write to device because device is busy.";
        emit serialDeviceError(connection_id_, "Cannot write to device because device is busy.");
    }
    else {
        qint64 written_bytes = serial_port_.write(data);
        written_bytes += serial_port_.write("\n");
        if (written_bytes != (data.size() + 1)) {
            qCCritical(logCategorySerialDevice) << this << ": Cannot write whole data to device.";
            emit serialDeviceError(connection_id_, "Cannot write whole data to device.");
        }
    }
}

void SerialDevice::handleError(QSerialPort::SerialPortError error) {
    // https://doc.qt.io/qt-5/qserialport.html#SerialPortError-enum
    if (error != QSerialPort::NoError) {  // Do not emit error signal if there is no error.
        QString err_msg = "Serial port error (" + QString::number(error) + "): " + serial_port_.errorString();
        if (error == QSerialPort::ResourceError) {
            // board was unconnected from computer (cable was unplugged)
            qCInfo(logCategorySerialDevice).noquote() << this << ": " << err_msg;
        }
        else {
            qCCritical(logCategorySerialDevice).noquote() << this << ": " << err_msg;
            emit serialDeviceError(connection_id_, err_msg);
        }
    }
}

bool SerialDevice::launchDevice() {
    if (serial_port_.isOpen()) {
        device_busy_ = true;
        state_ = State::GetFirmwareInfo;
        // some boards need time for booting, so wait before sending JSON messages
        QTimer::singleShot(LAUNCH_DELAY, [this](){ emit identifyDevice(QPrivateSignal()); });
        return true;
    }
    else {
        return false;
    }
}

void SerialDevice::deviceIdentification() {
    switch (state_) {
        case State::GetFirmwareInfo :
            connect(this, &SerialDevice::msgFromDevice, this, &SerialDevice::handleDeviceResponse);
            serial_port_.clear();
            serial_port_.write(CMD_GET_FIRMWARE_INFO);
            action_ = Action::WaitingForFirmwareInfo;
            response_timer_.start();
            break;
        case State::GetPlatformInfo :
            serial_port_.write(CMD_REQUEST_PLATFORM_ID);
            action_ = Action::WaitingForPlatformInfo;
            response_timer_.start();
            break;
        case State::DeviceReady :
        case State::UnrecognizedDevice :
            disconnect(this, &SerialDevice::msgFromDevice, this, &SerialDevice::handleDeviceResponse);
            action_ = Action::Done;
            device_busy_ = false;
            emit deviceReady(connection_id_, (state_ == State::DeviceReady) ? true : false);
            break;
        case State::None :
            break;
    }
}

void SerialDevice::handleDeviceResponse(const int /* connectionId */, const QByteArray& data) {
    bool is_ack = false;
    if (parseDeviceResponse(data, is_ack)) {
        switch (action_) {
            case Action::WaitingForFirmwareInfo :
            case Action::WaitingForPlatformInfo :
                if (is_ack) {
                    break;
                }
                response_timer_.stop();
                state_ = (action_ == Action::WaitingForFirmwareInfo) ? State::GetPlatformInfo : State::DeviceReady;
                emit identifyDevice(QPrivateSignal());
                break;
            case Action::Done :
            case Action::None :
                break;
        }
    }
    else {  // unknown or malformed device response
        state_ = State::UnrecognizedDevice;
        emit identifyDevice(QPrivateSignal());
    }
}

bool getJsonString(const rapidjson::Value& val, QString& str) {
    if (val.IsString()) {
        str = val.GetString();
        return true;
    }
    return false;
}

bool SerialDevice::parseDeviceResponse(const QByteArray& data, bool& is_ack) {
    rapidjson::Document doc;
    rapidjson::ParseResult result = doc.Parse(data.data());

    if (!result) {
        QString err_msg = "Cannot parse JSON: " + data + " Error at offset " + QString::number(result.Offset()) + ": " + GetParseError_En(result.Code());
        qCCritical(logCategorySerialDevice).noquote() << this << ": " << err_msg;
        emit serialDeviceError(connection_id_, err_msg);
        return false;
    }

    is_ack = false;
    bool ok = false;

    if (doc.HasMember(JSON_ACK)) {
        is_ack = true;

        // check value of "ack" key:
        const rapidjson::Value& val = doc[JSON_ACK];
        if (val.IsString()) {
            if ((action_ == Action::WaitingForFirmwareInfo) && (val == JSON_GET_FW_INFO)) {
                ok = true;
            }
            else if ((action_ == Action::WaitingForPlatformInfo) && (val == JSON_REQ_PLATFORM_ID)) {
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
            if (notif.IsObject() == false) {
                break;
            }
            if (notif.HasMember(JSON_VALUE) == false || notif.HasMember(JSON_PAYLOAD) == false) {
                break;
            }
            const rapidjson::Value& val = notif[JSON_VALUE];
            if (val.IsString() == false) {
                break;
            }
            const rapidjson::Value& payload = notif[JSON_PAYLOAD];
            if (payload.IsObject() == false) {
                break;
            }
            if (val == JSON_GET_FW_INFO) {
                if (payload.HasMember(JSON_BOOTLOADER) == false || payload.HasMember(JSON_APPLICATION) == false) {
                    break;
                }
                const rapidjson::Value& bldr = payload[JSON_BOOTLOADER];
                const rapidjson::Value& appl = payload[JSON_APPLICATION];
                if (bldr.IsObject() == false || appl.IsObject() == false) {
                    break;
                }
                if (bldr.HasMember(JSON_VERSION)) {
                    const rapidjson::Value& ver = bldr[JSON_VERSION];
                    ok = getJsonString(ver, bootloader_ver_);
                }
                if (appl.HasMember(JSON_VERSION)) {
                    const rapidjson::Value& ver = appl[JSON_VERSION];
                    ok = getJsonString(ver, application_ver_);
                }
            }
            else if (val == JSON_PLATFORM_ID) {
                if (payload.HasMember(JSON_NAME)) {
                    const rapidjson::Value& name = payload[JSON_NAME];
                    ok = getJsonString(name, verbose_name_);
                }
                if (payload.HasMember(JSON_PLATFORM_ID)) {
                    const rapidjson::Value& plat_id = payload[JSON_PLATFORM_ID];
                    ok = getJsonString(plat_id, platform_id_);
                }
                if (payload.HasMember(JSON_CLASS_ID)) {
                    const rapidjson::Value& class_id = payload[JSON_CLASS_ID];
                    ok = getJsonString(class_id, class_id_);
                }
            }
        } while (false);
    }

    if (ok == false) {
        qCWarning(logCategorySerialDevice) << this << ": Content of JSON response is wrong.";
    }

    return ok;
}

void SerialDevice::handleResponseTimeout() {
    qCWarning(logCategorySerialDevice) << this << ": Response timeout";
    action_ = Action::None;
    state_ = State::UnrecognizedDevice;
    emit identifyDevice(QPrivateSignal());
}

QVariantMap SerialDevice::getDeviceInfo() const {
    QVariantMap result;
    result.insert(QStringLiteral("connectionId"), connection_id_);
    if (device_busy_ == false) {
        result.insert(QStringLiteral("platformId"), platform_id_);
        result.insert(QStringLiteral("classId"), class_id_);
        result.insert(QStringLiteral("verboseName"), verbose_name_);
        result.insert(QStringLiteral("bootloaderVersion"), bootloader_ver_);
        result.insert(QStringLiteral("applicationVersion"), application_ver_);
    }
    return result;
}

}  // namespace
