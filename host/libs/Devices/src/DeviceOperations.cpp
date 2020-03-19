#include "DeviceOperations.h"
#include "DeviceOperationsConstants.h"

#include <cstring>

#include <DeviceProperties.h>
#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

#include <CodecBase64.h>
#include <Buypass.h>

#include <rapidjson/document.h>
#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>


namespace strata {

QDebug operator<<(QDebug dbg, const DeviceOperations* devOp) {
    return dbg.nospace().noquote() << "Device 0x" << hex << devOp->deviceId_ << ": ";
}

DeviceOperations::DeviceOperations(SerialDeviceShPtr device) :
    device_(device), operation_(Operation::None), state_(State::None), activity_(Activity::None)
{
    deviceId_ = static_cast<uint>(device_->getDeviceId());

    responseTimer_.setSingleShot(true);
    responseTimer_.setInterval(RESPONSE_TIMEOUT);

    connect(this, &DeviceOperations::nextStep, this, &DeviceOperations::process, Qt::QueuedConnection);
    connect(device_.get(), &SerialDevice::msgFromDevice, this, &DeviceOperations::handleDeviceResponse);
    connect(device_.get(), &SerialDevice::serialDeviceError, this, &DeviceOperations::handleDeviceError);
    connect(&responseTimer_, &QTimer::timeout, this, &DeviceOperations::handleResponseTimeout);

    qCDebug(logCategoryDeviceOperations) << this << "Created object for device operations.";
}

DeviceOperations::~DeviceOperations() {
    qCDebug(logCategoryDeviceOperations) << this << "Finished operations.";
}

void DeviceOperations::identify() {
    startOperation(Operation::Identify);
}

void DeviceOperations::prepareForFlash() {
    startOperation(Operation::PrepareForFlash);
}

void DeviceOperations::flashFirmwareChunk(QVector<quint8> chunk, int chunk_number) {
    chunk_ = chunk;
    chunkNumber_ = chunk_number;
    startOperation(Operation::FlashFirmwareChunk);
}

void DeviceOperations::startApplication() {
    startOperation(Operation::StartApplication);
}

int DeviceOperations::getDeviceId() {
    return static_cast<int>(deviceId_);
}

void DeviceOperations::startOperation(Operation operation) {
    if (operation_ != Operation::None) {  // another operation is runing
        // flash firmware chunk is a special case
        if (operation_ != Operation::FlashFirmwareChunk || operation != Operation::FlashFirmwareChunk) {
            QString err_msg("Cannot start operation, because another operation is running.");
            qCWarning(logCategoryDeviceOperations) << this << err_msg;
            emit error(err_msg);
            return;
        }
    }
    operation_ = operation;

    // Some boards need time for booting,
    // wait before sending JSON messages for certain operations.
    std::chrono::milliseconds delay(0);
    switch (operation_) {
    case Operation::Identify :
        state_ = State::GetFirmwareInfo;
        delay = LAUNCH_DELAY;
        break;
    case Operation::PrepareForFlash :
        state_ = State::GetPlatformId;
        break;
    case Operation::FlashFirmwareChunk :
        state_ = State::FlashFwChunk;
        break;
    case Operation::StartApplication :
        state_ = State::StartApplication;
        break;
    default:
        {
            QString err_msg("Unsupported operation.");
            qCWarning(logCategoryDeviceOperations) << this << err_msg;
            emit error(err_msg);
        }
        return;
    }

    QTimer::singleShot(delay, [this](){ emit nextStep(QPrivateSignal()); });
}

void DeviceOperations::finishOperation(Operation operation) {
    resetInternalStates();
    emit finished(static_cast<int>(operation));
}

void DeviceOperations::cancelOperation() {
    responseTimer_.stop();
    resetInternalStates();
    emit finished(static_cast<int>(Operation::Cancel));
}

void DeviceOperations::resetInternalStates() {
    operation_ = Operation::None;
    state_ = State::None;
    activity_ = Activity::None;
}

void DeviceOperations::process() {
    ackReceived_ = false;  // Flag if we have received ACK for sent command.
    switch (state_) {
    case State::GetFirmwareInfo :
        qCDebug(logCategoryDeviceOperations) << this << "Sending 'get_firmware_info' command.";
        device_->write(CMD_GET_FIRMWARE_INFO);
        activity_ = Activity::WaitingForFirmwareInfo;
        responseTimer_.start();
        break;
    case State::GetPlatformId :
        qCDebug(logCategoryDeviceOperations) << this << "Sending 'request_platform_id' command.";
        device_->write(CMD_REQUEST_PLATFORM_ID);
        activity_ = Activity::WaitingForPlatformId;
        responseTimer_.start();
        break;
    case State::UpdateFirmware :
        qCDebug(logCategoryDeviceOperations) << this << "Sending 'update_firmware' command.";
        device_->write(CMD_UPDATE_FIRMWARE);
        activity_ = Activity::WaitingForUpdateFw;
        responseTimer_.start();
        break;
    case State::ReadyForFlashFw :
        qCInfo(logCategoryDeviceOperations) << this << "Platform in bootloader mode. Ready for flashing firmware.";
        finishOperation(Operation::PrepareForFlash);
        break;
    case State::FlashFwChunk :
        qCDebug(logCategoryDeviceOperations) << this << "Sending 'flash_firmware' command.";
        device_->write(createFlashFwJson());
        activity_ = Activity::WaitingForFlashFwChunk;
        responseTimer_.start();
        break;
    case State::StartApplication :
        qCDebug(logCategoryDeviceOperations) << this << "Sending 'start_application' command.";
        device_->write(CMD_START_APPLICATION);
        activity_ = Activity::WaitingForStartApp;
        responseTimer_.start();
        break;
    case State::Timeout :
        qCWarning(logCategoryDeviceOperations) << this << "Response timeout (no valid response to the sent command).";
        emit finished(static_cast<int>(Operation::Timeout));
        break;
    default :
        break;
    }
}

void DeviceOperations::handleResponseTimeout() {
    state_ = State::Timeout;
    emit nextStep(QPrivateSignal());
}

void DeviceOperations::handleDeviceError(QString msg) {
    responseTimer_.stop();
    resetInternalStates();
    qCWarning(logCategoryDeviceOperations) << this << "Error: " << msg;
    emit error(msg);
}

void DeviceOperations::handleDeviceResponse(const QByteArray& data) {
    if (operation_ == Operation::None) {  // In this case we do not care about messages from device.
        qCDebug(logCategoryDeviceActions) << this << "No operation is running, message from device is ignored.";
        return;
    }
    bool isAck = false;
    if (parseDeviceResponse(data, isAck)) {
        // If ACK was received ACK do nothing and wait for notification.
        if (isAck == false) {
            if (ackReceived_ == false) {
                qCWarning(logCategoryDeviceOperations) << this << "Received notification without ACK.";
            }
            switch (activity_) {
            case Activity::WaitingForFirmwareInfo :
                responseTimer_.stop();
                state_ = State::GetPlatformId;
                emit nextStep(QPrivateSignal());
                break;
            case Activity::WaitingForPlatformId :
                responseTimer_.stop();
                if (operation_ == Operation::Identify) {
                    finishOperation(Operation::Identify);
                } else {  // Operation::PrepareForFlash
                    if (device_->getProperty(DeviceProperties::verboseName) == BOOTLOADER_STR) {
                        qCInfo(logCategoryDeviceOperations) << this << "Platform in bootloader mode. Ready for flashing firmware.";
                        state_ = State::ReadyForFlashFw;
                    } else {
                        state_ = State::UpdateFirmware;
                    }
                    emit nextStep(QPrivateSignal());
                }
                break;
            case Activity::WaitingForUpdateFw :
                responseTimer_.stop();
                state_ = State::ReadyForFlashFw;
                // Bootloader takes 5 seconds to start (known issue related to clock source).
                // Platform and bootloader uses the same setting for clock source.
                // Clock source for bootloader and application must match. Otherwise when application jumps to bootloader,
                // it will have a hardware fault which requires board to be reset.
                qCInfo(logCategoryDeviceOperations) << this << "Waiting 5 seconds for bootloader to start.";
                QTimer::singleShot(BOOTLOADER_START_DELAY, [this](){ emit nextStep(QPrivateSignal()); });
                break;
            case Activity::WaitingForFlashFwChunk :
                responseTimer_.stop();
                if (chunkNumber_ == 0 ) {  // the last chunk
                    resetInternalStates();
                }
                emit finished(static_cast<int>(Operation::FlashFirmwareChunk), chunkNumber_);
                break;
            case Activity::WaitingForStartApp :
                responseTimer_.stop();
                finishOperation(Operation::StartApplication);
                break;
            default :
                break;
            }
        }
    }
    else {
        qCWarning(logCategoryDeviceActions) << this << "Received unknown or malformed response.";
    }
}

bool DeviceOperations::parseDeviceResponse(const QByteArray& data, bool& isAck) {
    rapidjson::Document doc;

    if (CommandValidator::parseJson(data.toStdString(), doc) == false) {
        qCWarning(logCategoryDeviceOperations).noquote() << this << "Cannot parse JSON: '" << data << "'.";
        return false;
    }

    if (doc.IsObject() == false) {
        // JSON can contain only a value (e.g. "abc").
        // We require object as a JSON content (JSON starts with '{' and ends with '}')
        qCWarning(logCategoryDeviceOperations).noquote() << this << "Content of JSON response is not an object: '" << data << "'.";
        return false;
    }

    bool ok = false;

    // *** response is ACK ***
    if (doc.HasMember(JSON_ACK)) {
        isAck = true;
        if (CommandValidator::validate(CommandValidator::JsonType::ack, doc)) {
            const char *ackStr = doc[JSON_ACK].GetString();
            const char *cmpStr = nullptr;
            qCDebug(logCategoryDeviceOperations) << this << "Received '" << ackStr << "' ACK.";

            switch (activity_) {
            case Activity::WaitingForFirmwareInfo :
                cmpStr = JSON_GET_FW_INFO;
                break;
            case Activity::WaitingForPlatformId :
                cmpStr = JSON_REQ_PLATFORM_ID;
                break;
            case Activity::WaitingForUpdateFw :
                cmpStr = JSON_UPDATE_FIRMWARE;
                break;
            case Activity::WaitingForFlashFwChunk :
                cmpStr = JSON_FLASH_FIRMWARE;
                break;
            case Activity::WaitingForStartApp :
                cmpStr = JSON_START_APP;
                break;
            case Activity::None :
                break;
            }

            if (cmpStr && (std::strcmp(ackStr, cmpStr) == 0)) {
                ackReceived_ = true;
                ok = doc[JSON_PAYLOAD][JSON_RETURN_VALUE].GetBool();
            } else {
                qCWarning(logCategoryDeviceOperations) << this << "Received ACK '" << ackStr << "' is for another command than expected.";
            }
        }
    }
    else {
        isAck = false;
    }

    // *** response is notification ***
    if (doc.HasMember(JSON_NOTIFICATION)) {
        if (CommandValidator::validate(CommandValidator::JsonType::notification, doc)) {
            const rapidjson::Value& value = doc[JSON_NOTIFICATION][JSON_VALUE];
            const rapidjson::Value& payload = doc[JSON_NOTIFICATION][JSON_PAYLOAD];
            const char *notificationStr = nullptr;
            bool standardNotification = true;
            qCDebug(logCategoryDeviceOperations) << this << "Received '" << value.GetString() << "' notification.";
            switch (activity_) {
            case Activity::WaitingForFirmwareInfo :
                standardNotification = false;
                if (CommandValidator::validate(CommandValidator::JsonType::getFwInfoRes, doc)) {
                    const rapidjson::Value& payload = doc[JSON_NOTIFICATION][JSON_PAYLOAD];
                    const rapidjson::Value& btldr = payload[JSON_BOOTLOADER];
                    const rapidjson::Value& appl = payload[JSON_APPLICATION];
                    if (btldr.MemberCount()) {  // JSON_BOOTLOADER object has some members -> it is not empty
                        device_->setProperties(nullptr, nullptr, nullptr, btldr[JSON_VERSION].GetString(), nullptr);
                        ok = true;
                    }
                    if (appl.MemberCount()) {  // JSON_APPLICATION object has some members -> it is not empty
                        device_->setProperties(nullptr, nullptr, nullptr, nullptr, appl[JSON_VERSION].GetString());
                        ok = true;
                    }
                }
                break;
            case Activity::WaitingForPlatformId :
                standardNotification = false;
                if (CommandValidator::validate(CommandValidator::JsonType::reqPlatIdRes, doc)) {
                    const rapidjson::Value& payload = doc[JSON_NOTIFICATION][JSON_PAYLOAD];
                    if (payload.HasMember(JSON_NAME)) {
                        device_->setProperties(payload[JSON_NAME].GetString(), payload[JSON_PLATFORM_ID].GetString(),
                                               payload[JSON_CLASS_ID].GetString(), nullptr, nullptr);
                        ok = true;
                    }
                    else if (payload.HasMember(JSON_VERBOSE_NAME)) {
                        device_->setProperties(payload[JSON_VERBOSE_NAME].GetString(), payload[JSON_PLATFORM_ID].GetString(),
                                               nullptr, nullptr, nullptr);
                        ok = true;
                    }
                }
                break;
            case Activity::WaitingForUpdateFw :
                notificationStr = JSON_UPDATE_FIRMWARE;
                break;
            case Activity::WaitingForFlashFwChunk :
                notificationStr = JSON_FLASH_FIRMWARE;
                break;
            case Activity::WaitingForStartApp :
                notificationStr = JSON_START_APP;
                break;
            default:
                break;
            }

            if (standardNotification && notificationStr) {
                if (payload.HasMember(JSON_STATUS)) {
                    const rapidjson::Value& status = payload[JSON_STATUS];
                    if (value == notificationStr && status.IsString() && status == JSON_OK) {
                        ok = true;
                    }
                }
            }
        }
    }

    if (ok == false) {
        qCWarning(logCategoryDeviceOperations).noquote() << this << "Content of JSON response is wrong: '" << data << "'.";
    }

    return ok;
}

QByteArray DeviceOperations::createFlashFwJson() {
    rapidjson::StringBuffer sb;
    rapidjson::Writer<rapidjson::StringBuffer> writer(sb);

        writer.StartObject();

        writer.Key(JSON_CMD);
        writer.String(JSON_FLASH_FIRMWARE);

        writer.Key(JSON_PAYLOAD);
        writer.StartObject();

        writer.Key(JSON_CHUNK);
        writer.StartObject();

        writer.Key(JSON_NUMBER);
        writer.Int(chunkNumber_);

        writer.Key(JSON_SIZE);
        writer.Int(chunk_.size());

        writer.Key(JSON_CRC);
        writer.Int(crc16::buypass(chunk_.data(), static_cast<uint32_t>(chunk_.size())));

        size_t chunkBase64Size = base64::encoded_size(static_cast<size_t>(chunk_.size()));
        QByteArray chunkBase64;
        chunkBase64.resize(static_cast<int>(chunkBase64Size));
        base64::encode(chunkBase64.data(), chunk_.data(), static_cast<size_t>(chunk_.size()));

        writer.Key(JSON_DATA);
        writer.String(chunkBase64.data(), static_cast<rapidjson::SizeType>(chunkBase64Size));

        writer.EndObject();

        writer.EndObject();

        writer.EndObject();

        return QByteArray(sb.GetString(), static_cast<int>(sb.GetSize()));
}

}  // namespace
