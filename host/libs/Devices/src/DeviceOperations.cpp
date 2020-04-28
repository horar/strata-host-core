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

DeviceOperations::DeviceOperations(const SerialDevicePtr& device) :
    device_(device), responseTimer_(this), operation_(Operation::None),
    state_(State::None), activity_(Activity::None), reqFwInfoResp_(true)
{
    deviceId_ = static_cast<uint>(device_->deviceId());

    responseTimer_.setSingleShot(true);
    responseTimer_.setInterval(RESPONSE_TIMEOUT);

    connect(this, &DeviceOperations::nextStep, this, &DeviceOperations::process, Qt::QueuedConnection);
    connect(device_.get(), &SerialDevice::msgFromDevice, this, &DeviceOperations::handleDeviceResponse);
    connect(device_.get(), &SerialDevice::serialDeviceError, this, &DeviceOperations::handleDeviceError);
    connect(&responseTimer_, &QTimer::timeout, this, &DeviceOperations::handleResponseTimeout);

    qCDebug(logCategoryDeviceOperations) << this << "Created object for device operations.";
}

DeviceOperations::~DeviceOperations() {
    device_->unlockDevice(reinterpret_cast<quintptr>(this));
    qCDebug(logCategoryDeviceOperations) << this << "Finished operations.";
}

void DeviceOperations::identify(bool requireFwInfoResponse) {
    reqFwInfoResp_ = requireFwInfoResponse;
    startOperation(Operation::Identify);
}

void DeviceOperations::switchToBootloader() {
    startOperation(Operation::SwitchToBootloader);
}

void DeviceOperations::flashFirmwareChunk(const QVector<quint8>& chunk, int chunkNumber) {
    chunk_ = chunk;
    chunkNumber_ = chunkNumber;
    chunkRetryCount_ = 0;
    startOperation(Operation::FlashFirmwareChunk);
}

void DeviceOperations::backupFirmwareChunk(bool firstChunk) {
    chunkRetryCount_ = 0;
    firstBackupChunk_ = firstChunk;
    startOperation(Operation::BackupFirmwareChunk);
}

void DeviceOperations::startApplication() {
    startOperation(Operation::StartApplication);
}

int DeviceOperations::deviceId() const {
    return static_cast<int>(deviceId_);
}

QVector<quint8> DeviceOperations::recentFirmwareChunk() const {
    return chunk_;
}

void DeviceOperations::startOperation(Operation operation) {
    if (operation_ != Operation::None) {  // another operation is runing
        // flash or backup firmware chunk is a special case
        if (operation_ != operation || (operation != Operation::FlashFirmwareChunk && operation != Operation::BackupFirmwareChunk)) {
            QString err_msg(QStringLiteral("Cannot start operation, because another operation is running."));
            qCWarning(logCategoryDeviceOperations) << this << err_msg;
            emit error(err_msg);
            return;
        }
    }
    operation_ = operation;

    if (device_->lockDeviceForOperation(reinterpret_cast<quintptr>(this)) == false) {
        QString err_msg(QStringLiteral("Cannot start operation, because cannot get access to device."));
        qCWarning(logCategoryDeviceOperations) << this << err_msg;
        emit error(err_msg);
        return;
    }

    // Some boards need time for booting,
    // wait before sending JSON messages for certain operations.
    std::chrono::milliseconds delay(0);
    switch (operation_) {
    case Operation::Identify :
        state_ = State::GetFirmwareInfo;
        delay = LAUNCH_DELAY;
        break;
    case Operation::SwitchToBootloader :
        state_ = State::GetPlatformId;
        break;
    case Operation::FlashFirmwareChunk :
        state_ = State::FlashFwChunk;
        break;
    case Operation::BackupFirmwareChunk :
        state_ = State::BackupFwChunk;
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

    QTimer::singleShot(delay, this, [this](){ emit nextStep(QPrivateSignal()); });
}

void DeviceOperations::finishOperation(Operation operation, int data) {
    resetInternalStates();
    device_->unlockDevice(reinterpret_cast<quintptr>(this));
    emit finished(static_cast<int>(operation), data);
}

void DeviceOperations::cancelOperation() {
    responseTimer_.stop();
    resetInternalStates();
    device_->unlockDevice(reinterpret_cast<quintptr>(this));
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
        qCInfo(logCategoryDeviceOperations) << this << "Sending 'get_firmware_info' command.";
        if (device_->sendMessage(CMD_GET_FIRMWARE_INFO, reinterpret_cast<quintptr>(this))) {
            activity_ = Activity::WaitingForFirmwareInfo;
            responseTimer_.start();
        }
        break;
    case State::GetPlatformId :
        qCInfo(logCategoryDeviceOperations) << this << "Sending 'request_platform_id' command.";
        if (device_->sendMessage(CMD_REQUEST_PLATFORM_ID, reinterpret_cast<quintptr>(this))) {
            activity_ = Activity::WaitingForPlatformId;
            responseTimer_.start();
        }
        break;
    case State::UpdateFirmware :
        qCInfo(logCategoryDeviceOperations) << this << "Sending 'update_firmware' command.";
        if (device_->sendMessage(CMD_UPDATE_FIRMWARE, reinterpret_cast<quintptr>(this))) {
            activity_ = Activity::WaitingForSwitchToBootloader;
            responseTimer_.start();
        }
        break;
    case State::SwitchedToBootloader :
        qCInfo(logCategoryDeviceOperations) << this << "Ready for firmware operations.";
        finishOperation(Operation::SwitchToBootloader);
        break;
    case State::FlashFwChunk :
        {
            const char *msg = "Sending 'flash_firmware' command.";
            if (chunkNumber_ == 1) { qCInfo(logCategoryDeviceOperations) << this << msg; }
            else { qCDebug(logCategoryDeviceOperations) << this << msg; }
        }
        if (device_->sendMessage(createFlashFwJson(), reinterpret_cast<quintptr>(this))) {
            activity_ = Activity::WaitingForFlashFwChunk;
            responseTimer_.start();
        }
        break;
    case State::BackupFwChunk :
        {
            const char *msg = "Sending 'backup_firmware' command.";
            if (firstBackupChunk_) { qCInfo(logCategoryDeviceOperations) << this << msg; }
            else { qCDebug(logCategoryDeviceOperations) << this << msg; }
        }
        if (device_->sendMessage(createBackupFwJson(), reinterpret_cast<quintptr>(this))) {
            activity_ = Activity::WaitingForBackupFwChunk;
            responseTimer_.start();
        }
        break;
    case State::StartApplication :
        qCInfo(logCategoryDeviceOperations) << this << "Sending 'start_application' command.";
        if (device_->sendMessage(CMD_START_APPLICATION, reinterpret_cast<quintptr>(this))) {
            activity_ = Activity::WaitingForStartApp;
            responseTimer_.start();
        }
        break;
    case State::Timeout :
        qCWarning(logCategoryDeviceOperations) << this << "Response timeout (no valid response to the sent command).";
        finishOperation(Operation::Timeout);
        break;
    case State::None :
        break;
    }
}

void DeviceOperations::handleResponseTimeout() {
    if (reqFwInfoResp_ == false && operation_ == Operation::Identify && activity_ == Activity::WaitingForFirmwareInfo) {
        qCInfo(logCategoryDeviceOperations) << this << "No response to 'get_firmware_info' command.";
        state_ = State::GetPlatformId;
    } else {
        state_ = State::Timeout;
    }
    emit nextStep(QPrivateSignal());
}

void DeviceOperations::handleDeviceError(int errCode, QString msg) {
    Q_UNUSED(errCode)
    responseTimer_.stop();
    resetInternalStates();
    qCCritical(logCategoryDeviceOperations) << this << "Error: " << msg;
    emit error(msg);
}

void DeviceOperations::handleDeviceResponse(const QByteArray& data) {
    if (operation_ == Operation::None) {  // In this case we do not care about messages from device.
        qCDebug(logCategoryDeviceOperations) << this << "No operation is running, message from device is ignored.";
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
                } else {  // Operation::SwitchToBootloader
                    if (device_->property(DeviceProperties::verboseName) == BOOTLOADER_STR) {
                        qCInfo(logCategoryDeviceOperations) << this << "Platform in bootloader mode. Ready for firmware operations.";
                        state_ = State::SwitchedToBootloader;
                    } else {
                        state_ = State::UpdateFirmware;
                    }
                    emit nextStep(QPrivateSignal());
                }
                break;
            case Activity::WaitingForSwitchToBootloader :
                responseTimer_.stop();
                state_ = State::SwitchedToBootloader;
                // Bootloader takes 5 seconds to start (known issue related to clock source).
                // Platform and bootloader uses the same setting for clock source.
                // Clock source for bootloader and application must match. Otherwise when application jumps to bootloader,
                // it will have a hardware fault which requires board to be reset.
                qCInfo(logCategoryDeviceOperations) << this << "Waiting 5 seconds for bootloader to start.";
                QTimer::singleShot(BOOTLOADER_START_DELAY, this, [this](){ emit nextStep(QPrivateSignal()); });
                break;
            case Activity::WaitingForFlashFwChunk :
                responseTimer_.stop();
                if (chunkRetryCount_ == 0) {
                    if (chunkNumber_ == 0 ) {  // the last chunk
                        finishOperation(Operation::FlashFirmwareChunk, chunkNumber_);
                    } else {
                        // Chunk was flashed but flashing operation is not finished yet,
                        // so emit only signal and do not call function finishOperation().
                        emit finished(static_cast<int>(Operation::FlashFirmwareChunk), chunkNumber_);
                    }
                } else {
                    emit nextStep(QPrivateSignal());  // retry - flash chunk again
                }
                break;
            case Activity::WaitingForBackupFwChunk :
                responseTimer_.stop();
                if (chunkRetryCount_ == 0) {
                    if (chunkNumber_ == 0 ) {  // the last chunk
                        finishOperation(Operation::BackupFirmwareChunk, chunkNumber_);
                    } else {
                        // Chunk was backed up but backup operation is not finished yet,
                        // so emit only signal and do not call function finishOperation().
                        emit finished(static_cast<int>(Operation::BackupFirmwareChunk), chunkNumber_);
                    }
                } else {
                    emit nextStep(QPrivateSignal());  // retry - ask for chunk again
                }
                break;
            case Activity::WaitingForStartApp :
                responseTimer_.stop();
                finishOperation(Operation::StartApplication);
                break;
            case Activity::None :
                break;
            }
        }
    }
    else {
        qCWarning(logCategoryDeviceOperations) << this << "Received unknown or malformed response.";
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
            case Activity::WaitingForSwitchToBootloader :
                cmpStr = JSON_UPDATE_FIRMWARE;
                break;
            case Activity::WaitingForFlashFwChunk :
                cmpStr = JSON_FLASH_FIRMWARE;
                break;
            case Activity::WaitingForBackupFwChunk :
                cmpStr = JSON_BACKUP_FIRMWARE;
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
            qCDebug(logCategoryDeviceOperations) << this << "Received '" << value.GetString() << "' notification.";
            switch (activity_) {
            case Activity::WaitingForFirmwareInfo :
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
            case Activity::WaitingForSwitchToBootloader :
                if (CommandValidator::validate(CommandValidator::JsonType::updateFwRes, doc)) {
                    const rapidjson::Value& status = doc[JSON_NOTIFICATION][JSON_PAYLOAD][JSON_STATUS];
                    if (status == JSON_OK) {
                        ok = true;
                    }
                }
                break;
            case Activity::WaitingForFlashFwChunk :
                if (CommandValidator::validate(CommandValidator::JsonType::flashFwRes, doc)) {
                    const rapidjson::Value& status = doc[JSON_NOTIFICATION][JSON_PAYLOAD][JSON_STATUS];
                    if (status == JSON_OK) {
                        ok = true;
                        chunkRetryCount_ = 0;
                    } else {
                        if (status == JSON_RESEND_CHUNK) {
                            if (chunkRetryCount_ < MAX_CHUNK_RETRIES) {
                                ++chunkRetryCount_;
                                ok = true;
                                qCInfo(logCategoryDeviceOperations) << this << "Retry to flash firmware chunk.";
                            } else {
                                qCWarning(logCategoryDeviceOperations) << this << "Reached maximum retries for flash firmware chunk.";
                            }
                        }
                    }
                }
                break;
            case Activity::WaitingForBackupFwChunk :
                if (CommandValidator::validate(CommandValidator::JsonType::backupFwRes, doc)) {
                    const rapidjson::Value& chunk = doc[JSON_NOTIFICATION][JSON_PAYLOAD][JSON_CHUNK];
                    const rapidjson::Value& number = chunk[JSON_NUMBER];
                    const rapidjson::Value& size = chunk[JSON_SIZE];
                    const rapidjson::Value& crc = chunk[JSON_CRC];
                    const rapidjson::Value& data = chunk[JSON_DATA];
                    if (number.IsInt() && size.IsUint() && crc.IsUint()) {
                        rapidjson::SizeType dataSize = data.GetStringLength();
                        size_t maxDecodedSize = base64::decoded_size(dataSize); // returns max bytes needed to decode a base64 string
                        chunk_.resize(static_cast<int>(maxDecodedSize));
                        const char *dataStr = data.GetString();
                        auto [realDecodedSize, readChars] = base64::decode(chunk_.data(), dataStr, dataSize);
                        chunk_.resize(static_cast<int>(realDecodedSize));
                        chunkNumber_ = number.GetInt();
                        if (size.GetUint() == realDecodedSize) {
                            if (crc.GetUint() == crc16::buypass(chunk_.data(), static_cast<uint32_t>(chunk_.size()))) {
                                ok = true;
                                chunkRetryCount_ = 0;
                            } else {
                                qCCritical(logCategoryDeviceOperations) << this << "Wrong CRC of firmware chunk.";
                            }
                        } else {
                            qCCritical(logCategoryDeviceOperations) << this << "Wrong SIZE of firmware chunk.";
                        }
                        if (ok == false) {
                            if (chunkRetryCount_ < MAX_CHUNK_RETRIES) {
                                ++chunkRetryCount_;
                                ok = true;
                                qCInfo(logCategoryDeviceOperations) << this << "Retry to backup firmware chunk.";
                            } else {
                                qCWarning(logCategoryDeviceOperations) << this << "Reached maximum retries for backup firmware chunk.";
                            }
                        }
                    }
                }
                break;
            case Activity::WaitingForStartApp :
                if (CommandValidator::validate(CommandValidator::JsonType::startAppRes, doc)) {
                    const rapidjson::Value& status = doc[JSON_NOTIFICATION][JSON_PAYLOAD][JSON_STATUS];
                    if (status == JSON_OK) {
                        ok = true;
                    }
                }
                break;
            case Activity::None :
                break;
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

QByteArray DeviceOperations::createBackupFwJson() {
    const char *json = nullptr;
    if (chunkRetryCount_ != 0) {
        qCInfo(logCategoryDeviceOperations) << "Resend";
        json = CMD_BACKUP_FIRMWARE_STATUS_RESEND;
    } else {
        json = (firstBackupChunk_) ? CMD_BACKUP_FIRMWARE : CMD_BACKUP_FIRMWARE_STATUS_OK;
    }
    return QByteArray(json);
}

}  // namespace
