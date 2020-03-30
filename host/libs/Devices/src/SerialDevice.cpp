#include "SerialDevice.h"
#include "SerialDeviceConstants.h"

#include "logging/LoggingQtCategories.h"

#include <CommandValidator.h>

#include <rapidjson/document.h>
#include <rapidjson/error/en.h>
#include <rapidjson/writer.h>


namespace strata {

QDebug operator<<(QDebug dbg, const SerialDevice* d) {
    return dbg.nospace() << "Serial device 0x" << hex << d->ucid_;
}

SerialDevice::SerialDevice(const int connectionID, const QString& name) :
    connection_id_(connectionID), ucid_(static_cast<uint>(connectionID)), port_name_(name),
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

    qCDebug(logCategorySerialDevice).nospace() << "Created new serial device. ID: 0x" << hex << ucid_ << ", name: " << port_name_;
}

SerialDevice::~SerialDevice() {
    close();
    qCDebug(logCategorySerialDevice).nospace() << "Deleted serial device 0x" << hex << ucid_;
}

bool SerialDevice::open() {
    if (serial_port_.isOpen()) {
        qCDebug(logCategorySerialDevice).nospace() << this << "Attempt to open already opened serial port.";
        return true;
    }

    serial_port_.setPortName(port_name_);
    serial_port_.setBaudRate(QSerialPort::Baud115200);
    serial_port_.setDataBits(QSerialPort::Data8);
    serial_port_.setParity(QSerialPort::NoParity);
    serial_port_.setStopBits(QSerialPort::OneStop);
    serial_port_.setFlowControl(QSerialPort::NoFlowControl);

    bool opened = serial_port_.open(QIODevice::ReadWrite);
    if (opened) {
        serial_port_.clear(QSerialPort::AllDirections);
    }
    return opened;
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
        // std::string keeps allocated memory after clear(), this is why read_buffer_ is std::string
    }

    if (from < data.size()) {  // message contains some data after '\n' (or has no '\n')
        read_buffer_.append(data.data() + from, static_cast<size_t>(data.size() - from));
    }
}

void SerialDevice::write(const QByteArray& data) {
    emit writeToPort(data, QPrivateSignal());
}

void SerialDevice::writeData(const QByteArray& data) {
    if (device_busy_) {  // Device is busy -> device identification is still running.
        qCDebug(logCategorySerialDevice) << this << ": Cannot write to device because device is busy.";
        emit serialDeviceError(connection_id_, QStringLiteral("Cannot write to device because device is busy."));
    }
    else {
        qint64 written_bytes = serial_port_.write(data);
        written_bytes += serial_port_.write("\n");
        if (written_bytes != (data.size() + 1)) {
            qCCritical(logCategorySerialDevice) << this << ": Cannot write whole data to device.";
            emit serialDeviceError(connection_id_, QStringLiteral("Cannot write whole data to device."));
        }
    }
}

void SerialDevice::handleError(QSerialPort::SerialPortError error) {
    // https://doc.qt.io/qt-5/qserialport.html#SerialPortError-enum
    if (error != QSerialPort::NoError) {  // Do not emit error signal if there is no error.
        QString err_msg = "Serial port error (" + QString::number(error) + "): " + serial_port_.errorString();
        if (error == QSerialPort::ResourceError) {
            // board was unconnected from computer (cable was unplugged)
            qCWarning(logCategorySerialDevice).noquote() << this << ": " << err_msg << " (Probably unexpectedly disconnected device.)";
        }
        else {
            qCCritical(logCategorySerialDevice).noquote() << this << ": " << err_msg;
            emit serialDeviceError(connection_id_, err_msg);
        }
    }
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

QString SerialDevice::getProperty(DeviceProperties property) const {
    if (property == DeviceProperties::connectionName) {
        return port_name_;
    }

    if (device_busy_ == false) {
        switch (property) {
            case DeviceProperties::verboseName :
                return verbose_name_;
            case DeviceProperties::platformId :
                return platform_id_;
            case DeviceProperties::classId :
                return class_id_;
            case DeviceProperties::bootloaderVer :
                return bootloader_ver_;
            case DeviceProperties::applicationVer :
                return application_ver_;
            default:
                break;
        }
    }

    // Device is busy (device identification is still running) or property is not supported.
    return QString();
}

int SerialDevice::getConnectionId() const {
    return connection_id_;
}

void SerialDevice::setProperties(const char* verboseName, const char* platformId, const char* classId, const char* btldrVer, const char* applVer) {
    if (verboseName) { verbose_name_ = verboseName; }
    if (platformId)  { platform_id_ = platformId; }
    if (classId)     { class_id_ = classId; }
    if (btldrVer)    { bootloader_ver_ = btldrVer; }
    if (applVer)     { application_ver_ = applVer; }
}

/*
 *****
 Section with code for handling device operations via JSON commands.
 *****
*/

bool SerialDevice::identify(bool getFwInfo) {
    if (serial_port_.isOpen() && (device_busy_ == false)) {
        device_busy_ = true;  // Start of device identification.
        state_ = getFwInfo ? State::GetFirmwareInfo : State::GetPlatformInfo;
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
            qCDebug(logCategorySerialDevice) << this << ": Sending 'get_firmware_info' command.";
            connect(this, &SerialDevice::msgFromDevice, this, &SerialDevice::handleDeviceResponse);
            serial_port_.write(CMD_GET_FIRMWARE_INFO);
            action_ = Action::WaitingForFirmwareInfo;
            response_timer_.start();
            break;
        case State::GetPlatformInfo :
            qCDebug(logCategorySerialDevice) << this << ": Sending 'request_platform_id' command.";
            connect(this, &SerialDevice::msgFromDevice, this, &SerialDevice::handleDeviceResponse, Qt::UniqueConnection);
            serial_port_.write(CMD_REQUEST_PLATFORM_ID);
            action_ = Action::WaitingForPlatformInfo;
            response_timer_.start();
            break;
        case State::DeviceReady :
        case State::UnrecognizedDevice :
            disconnect(this, &SerialDevice::msgFromDevice, this, &SerialDevice::handleDeviceResponse);
            action_ = Action::Done;
            device_busy_ = false;  // Device identification has ended.
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
        qCDebug(logCategorySerialDevice) << this << ": Received unknown or malformed response.";

        // Lines below are commented due to this situation:
        // After application is closed, board still sends JSONs. And when application
        // is reopened it gets one of that JSONs before expected JSON reply.
        // So, when we receive unexpected message we do nothing. When expected message
        // will not be received, response timeout will occur.

        //state_ = State::UnrecognizedDevice;
        //emit identifyDevice(QPrivateSignal());
    }
}

void SerialDevice::handleResponseTimeout() {
    qCWarning(logCategorySerialDevice) << this << ": Response timeout (no valid response to the sent command).";
    action_ = Action::None;
    state_ = State::UnrecognizedDevice;
    emit identifyDevice(QPrivateSignal());
}

bool SerialDevice::parseDeviceResponse(const QByteArray& data, bool& is_ack) {
    rapidjson::Document doc;
    bool ok = false;

    if (CommandValidator::parseJson(data.toStdString(), doc) == false) {
        return false;
    }

    if (doc.IsObject()) {
        // JSON can contain only a value (e.g. "abc").
        // We require object as a JSON content (JSON starts with '{' and ends with '}')

        if (doc.HasMember(JSON_ACK)) {  // response is ACK
            is_ack = true;
            if (CommandValidator::validate(CommandValidator::JsonType::ack, doc) == false) {
                return false;
            }
            const rapidjson::Value& ack = doc[JSON_ACK];
            if ((action_ == Action::WaitingForFirmwareInfo) && (ack == JSON_GET_FW_INFO)) {
                qCDebug(logCategorySerialDevice) << this << ": Received ACK for 'get_firmware_info' command.";
               ok = true;
            }
            else if ((action_ == Action::WaitingForPlatformInfo) && (ack == JSON_REQ_PLATFORM_ID)) {
                qCDebug(logCategorySerialDevice) << this << ": Received ACK for 'request_platform_id' command.";
                ok = true;
            }
            if (ok) {
                ok = doc[JSON_PAYLOAD][JSON_RETURN_VALUE].GetBool();
            }
            return ok;
        }

        // response is notification
        is_ack = false;

        if (action_ == Action::WaitingForFirmwareInfo) {
            if (CommandValidator::validate(CommandValidator::JsonType::getFwInfoRes, doc) == false) {
                return false;
            }
            const rapidjson::Value& payload = doc[JSON_NOTIFICATION][JSON_PAYLOAD];
            const rapidjson::Value& btldr = payload[JSON_BOOTLOADER];
            const rapidjson::Value& appl = payload[JSON_APPLICATION];
            const rapidjson::SizeType has_btldr = btldr.MemberCount();
            const rapidjson::SizeType has_appl = appl.MemberCount();
            if (has_btldr) {
                bootloader_ver_ = btldr[JSON_VERSION].GetString();
            }
            if (has_appl) {
                application_ver_ = appl[JSON_VERSION].GetString();
            }
            if (has_btldr || has_appl) {
                ok = true;
            }
        }
        else if (action_ == Action::WaitingForPlatformInfo) {
            if (CommandValidator::validate(CommandValidator::JsonType::reqPlatIdRes, doc) == false) {
                return false;
            }
            const rapidjson::Value& payload = doc[JSON_NOTIFICATION][JSON_PAYLOAD];
            if (payload.HasMember(JSON_NAME)) {
                verbose_name_ = payload[JSON_NAME].GetString();
                platform_id_ = payload[JSON_PLATFORM_ID].GetString();
                class_id_ = payload[JSON_CLASS_ID].GetString();
                ok = true;
            }
            else if (payload.HasMember(JSON_VERBOSE_NAME)) {
                verbose_name_ = payload[JSON_VERBOSE_NAME].GetString();
                platform_id_ = payload[JSON_PLATFORM_ID].GetString();
                ok = true;
            }
        }

    }

    if (ok == false) {
        qCWarning(logCategorySerialDevice).noquote() << this << ": Content of JSON response is wrong: '" << data << "'.";
    }

    return ok;
}

}  // namespace
