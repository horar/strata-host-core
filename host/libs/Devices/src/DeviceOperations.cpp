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

QDebug operator<<(QDebug dbg, const DeviceOperations* dev_op) {
    return dbg.nospace() << "Device 0x" << hex << dev_op->device_id_ << ": ";
}

DeviceOperations::DeviceOperations(SerialDeviceShPtr device) :
    device_(device), operation_(Operation::None), state_(State::None), activity_(Activity::None)
{
    device_id_ = static_cast<uint>(device_->getDeviceId());

    response_timer_.setSingleShot(true);
    response_timer_.setInterval(RESPONSE_TIMEOUT);

    connect(this, &DeviceOperations::nextStep, this, &DeviceOperations::process);
    connect(device_.get(), &SerialDevice::msgFromDevice, this, &DeviceOperations::handleDeviceResponse);
    connect(device_.get(), &SerialDevice::serialDeviceError, this, &DeviceOperations::handleDeviceError);
    connect(&response_timer_, &QTimer::timeout, this, &DeviceOperations::handleResponseTimeout);
}

void DeviceOperations::identify() {
    startOperation(Operation::PrepareForFlash);
}

void DeviceOperations::prepareForFlash() {
    startOperation(Operation::PrepareForFlash);
}

void DeviceOperations::flashFirmwareChunk(QVector<quint8> chunk, int chunk_number) {
    chunk_ = chunk;
    chunk_number_ = chunk_number;
    startOperation(Operation::FlashFirmwareChunk);
}

void DeviceOperations::startApplication() {
    startOperation(Operation::StartApplication);
}

void DeviceOperations::startOperation(Operation oper) {
    if (operation_ != Operation::None) {  // another operation is runing
        // flash firmware chunk is a special case
        if (operation_ != Operation::FlashFirmwareChunk || oper != Operation::FlashFirmwareChunk) {
            QString err_msg("Cannot start operation, because another operation is running.");
            qCWarning(logCategoryDeviceActions) << this << err_msg;
            emit error(err_msg);
            return;
        }
    }
    operation_ = oper;

    // Some boards need time for booting,
    // wait before sending JSON messages for certain operations.
    std::chrono::milliseconds delay(0);
    switch (operation_) {
    case Operation::PrepareForFlash :
        state_ = State::GetPlatformId;
        delay = LAUNCH_DELAY;
        break;
    case Operation::FlashFirmwareChunk :
        state_ = State::FlashFwChunk;
        break;
    case Operation::StartApplication :
        state_ = State::StartApplication;
        break;
    default:
        QString err_msg("Unsupported operation.");
        qCWarning(logCategoryDeviceActions) << this << err_msg;
        emit error(err_msg);
        return;
    }

    QTimer::singleShot(delay, [this](){ emit nextStep(QPrivateSignal()); });
}

void DeviceOperations::cancelOperation() {
    response_timer_.stop();
    resetInternalStates();
    emit cancelled();
}

void DeviceOperations::resetInternalStates() {
    operation_ = Operation::None;
    state_ = State::None;
    activity_ = Activity::None;
}

void DeviceOperations::process() {
    ack_received_ = false;  // Flag if we have received ACK for sent command.
    switch (state_) {
    case State::GetPlatformId :
        qCDebug(logCategoryDeviceActions) << this << "Sending 'request_platform_id' command.";
        device_->write(CMD_REQUEST_PLATFORM_ID);
        activity_ = Activity::WaitingForPlatformId;
        response_timer_.start();
        break;
    case State::UpdateFirmware :
        qCDebug(logCategoryDeviceActions) << this << "Sending 'update_firmware' command.";
        device_->write(CMD_UPDATE_FIRMWARE);
        activity_ = Activity::WaitingForUpdateFw;
        response_timer_.start();
        break;
    case State::ReadyForFlashFw :
        qCInfo(logCategoryDeviceActions) << this << "Platform in bootloader mode. Ready for flashing firmware.";
        resetInternalStates();
        QTimer::singleShot(0, [this](){ emit readyForFlashFw(); });
        break;
    case State::FlashFwChunk :
        qCDebug(logCategoryDeviceActions) << this << "Sending 'flash_firmware' command.";
        device_->write(createFlashFwJson());
        activity_ = Activity::WaitingForFlashFwChunk;
        response_timer_.start();
        break;
    case State::FwChunkFlashed :
        if (chunk_number_ == 0 ) {  // the last chunk
            resetInternalStates();
        }
        QTimer::singleShot(0, [this](){ emit fwChunkFlashed(chunk_number_); });
        break;
    case State::StartApplication :
        qCDebug(logCategoryDeviceActions) << this << "Sending 'start_application' command.";
        device_->write(CMD_START_APPLICATION);
        activity_ = Activity::WaitingForStartApp;
        response_timer_.start();
        break;
    case State::ApplicationStarted :
        resetInternalStates();
        QTimer::singleShot(0, [this](){ emit applicationStarted(); });
        break;
    case State::Timeout :
        qCWarning(logCategoryDeviceActions) << this << "Response timeout (no valid response to the sent command).";
        resetInternalStates();
        QTimer::singleShot(0, [this](){ emit timeout(); });
        break;    
    default :
        resetInternalStates();
        break;
    }
}

void DeviceOperations::handleResponseTimeout() {
    activity_ = Activity::None;
    state_ = State::Timeout;
    emit nextStep(QPrivateSignal());
}

void DeviceOperations::handleDeviceError(QString msg) {
    response_timer_.stop();
    resetInternalStates();
    emit error(msg);
}

void DeviceOperations::handleDeviceResponse(const QByteArray& data) {
    if (operation_ == Operation::None) {  // In this case we do not care about messages from device.
        qCDebug(logCategoryDeviceActions) << this << "No operation is running, message from device is ignored.";
        return;
    }
    bool is_ack = false;
    if (parseDeviceResponse(data, is_ack)) {
        // If ACK was received ACK do nothing and wait for notification.
        if (is_ack == false) {
            if (ack_received_ == false) {
                qCWarning(logCategoryDeviceActions) << this << "Received notification without ACK.";
            }
            switch (activity_) {
            case Activity::WaitingForPlatformId :
                response_timer_.stop();
                if (device_->getProperty(strata::DeviceProperties::verboseName) == BOOTLOADER_STR) {
                    state_ = State::ReadyForFlashFw;
                } else {
                    state_ = State::UpdateFirmware;
                }
                QTimer::singleShot(0, [this](){ emit nextStep(QPrivateSignal()); });
                break;
            case Activity::WaitingForUpdateFw :
                response_timer_.stop();
                state_ = State::ReadyForFlashFw;
                // Bootloader takes 5 seconds to start (known issue related to clock source).
                // Platform and bootloader uses the same setting for clock source.
                // Clock source for bootloader and application must match. Otherwise when application jumps to bootloader,
                // it will have a hardware fault which requires board to be reset.
                qCInfo(logCategoryDeviceActions) << this << "Waiting 5 seconds for bootloader to start.";
                QTimer::singleShot(BOOTLOADER_START_DELAY, [this](){ emit nextStep(QPrivateSignal()); });
                break;
            case Activity::WaitingForFlashFwChunk :
                response_timer_.stop();
                state_ = State::FwChunkFlashed;
                emit nextStep(QPrivateSignal());
                break;
            case Activity::WaitingForStartApp :
                response_timer_.stop();
                state_ = State::ApplicationStarted;
                emit nextStep(QPrivateSignal());
                break;
            default :
                break;
            }
        }
    }
    else {  // unknown or malformed device response
        qCWarning(logCategoryDeviceActions) << this << "Received unknown or malformed response.";
    }
}

bool DeviceOperations::parseDeviceResponse(const QByteArray& data, bool& is_ack) {
    rapidjson::Document doc;

    if (CommandValidator::parseJson(data.toStdString(), doc) == false) {
        qCWarning(logCategoryDeviceActions).noquote() << this << "Cannot parse JSON: '" << data << "'.";
        return false;
    }

    if (doc.IsObject() == false) {
        // JSON can contain only a value (e.g. "abc").
        // We require object as a JSON content (JSON starts with '{' and ends with '}')
        qCWarning(logCategoryDeviceActions).noquote() << this << "Content of JSON response is not an object: '" << data << "'.";
        return false;
    }

    bool ok = false;

    // *** response is ACK ***
    if (doc.HasMember(JSON_ACK)) {
        is_ack = true;
        if (CommandValidator::validate(CommandValidator::JsonType::ack, doc)) {
            const char *ack_str = doc[JSON_ACK].GetString();
            const char *cmp_str = nullptr;
            qCDebug(logCategoryDeviceActions) << this << "Received '" << ack_str << "' ACK.";

            switch (activity_) {
            case Activity::WaitingForPlatformId :
                cmp_str = JSON_REQ_PLATFORM_ID;
                break;
            case Activity::WaitingForUpdateFw :
                cmp_str = JSON_UPDATE_FIRMWARE;
                break;
            case Activity::WaitingForFlashFwChunk :
                cmp_str = JSON_FLASH_FIRMWARE;
                break;
            case Activity::WaitingForStartApp :
                cmp_str = JSON_START_APP;
                break;
            case Activity::None :
                break;
            }

            if (cmp_str && (std::strcmp(ack_str, cmp_str) == 0)) {
                ack_received_ = true;
                ok = doc[JSON_PAYLOAD][JSON_RETURN_VALUE].GetBool();
            } else {
                qCWarning(logCategoryDeviceActions) << this << "Received ACK '" << ack_str << "' is for another command than expected.";
            }
        }

    }
    else {
        is_ack = false;
    }

    // *** response is notification ***
    if (doc.HasMember(JSON_NOTIFICATION)) {
        if (CommandValidator::validate(CommandValidator::JsonType::notification, doc)) {
            const rapidjson::Value& value = doc[JSON_NOTIFICATION][JSON_VALUE];
            const rapidjson::Value& payload = doc[JSON_NOTIFICATION][JSON_PAYLOAD];
            const char *notification_str = nullptr;
            bool standard_notification = true;
            qCDebug(logCategoryDeviceActions) << this << "Received '" << value.GetString() << "' notification.";
            switch (activity_) {
            case Activity::WaitingForPlatformId :
                standard_notification = false;
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
                notification_str = JSON_UPDATE_FIRMWARE;
                break;
            case Activity::WaitingForFlashFwChunk :
                notification_str = JSON_FLASH_FIRMWARE;
                break;
            case Activity::WaitingForStartApp :
                notification_str = JSON_START_APP;
                break;
            default:
                break;
            }

            if (standard_notification && notification_str) {
                if (payload.HasMember(JSON_STATUS)) {
                    const rapidjson::Value& status = payload[JSON_STATUS];
                    if (value == notification_str && status.IsString() && status == JSON_OK) {
                        ok = true;
                    }
                }
            }
        }
    }

    if (ok == false) {
        qCWarning(logCategoryDeviceActions).noquote() << this << "Content of JSON response is wrong: '" << data << "'.";
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
        writer.Int(chunk_number_);

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
