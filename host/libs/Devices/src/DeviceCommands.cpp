#include "DeviceCommands.h"
#include "DeviceOperationsConstants.h"
#include <CommandValidator.h>

#include <climits>

#include <CodecBase64.h>
#include <Buypass.h>

#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>

#include "logging/LoggingQtCategories.h"

namespace strata {

// Base Command

BaseDeviceCommand::BaseDeviceCommand(const SerialDevicePtr& device, const QString& commandName) :
    cmdName_(commandName), device_(device), ackReceived_(false), result_(CommandResult::InProgress) { }

BaseDeviceCommand::~BaseDeviceCommand() { }

void BaseDeviceCommand::setAckReceived() {
    ackReceived_ = true;
}

bool BaseDeviceCommand::ackReceived() const {
    return ackReceived_;
}

void BaseDeviceCommand::onTimeout() {
    result_ = CommandResult::InProgress;
}

bool BaseDeviceCommand::skip() {
    return false;
}

bool BaseDeviceCommand::logSendMessage() const {
    return true;
}

std::chrono::milliseconds BaseDeviceCommand::waitBeforeNextCommand() const {
    return std::chrono::milliseconds(0);
}

void BaseDeviceCommand::prepareRepeat() { }

int BaseDeviceCommand::dataForFinish() const {
    return INT_MIN;  // default value for finished() signal
}

const QString BaseDeviceCommand::name() const {
    return cmdName_;
}

CommandResult BaseDeviceCommand::result() const {
    return result_;
}

void BaseDeviceCommand::setDeviceProperties(const char* name, const char* platformId, const char* classId, const char* btldrVer, const char* applVer) {
    device_->setProperties(name, platformId, classId, btldrVer, applVer);
}


// Get Firmware Info Command

CmdGetFirmwareInfo::CmdGetFirmwareInfo(const SerialDevicePtr& device, bool requireResponse) :
    BaseDeviceCommand(device, QStringLiteral("get_firmware_info")), requireResponse_(requireResponse) { }

QByteArray CmdGetFirmwareInfo::message() {
    return QByteArray("{\"cmd\":\"get_firmware_info\"}");
}

bool CmdGetFirmwareInfo::processNotification(rapidjson::Document& doc) {
    bool ok = false;
    if (CommandValidator::validate(CommandValidator::JsonType::getFwInfoRes, doc)) {
        const rapidjson::Value& payload = doc[JSON_NOTIFICATION][JSON_PAYLOAD];
        const rapidjson::Value& bootloader = payload[JSON_BOOTLOADER];
        const rapidjson::Value& application = payload[JSON_APPLICATION];
        if (bootloader.MemberCount() > 0) {  // JSON_BOOTLOADER object has some members -> it is not empty
            setDeviceProperties(nullptr, nullptr, nullptr, bootloader[JSON_VERSION].GetString(), nullptr);
            result_ = CommandResult::Done;
            ok = true;
        }
        if (application.MemberCount() > 0) {  // JSON_APPLICATION object has some members -> it is not empty
            setDeviceProperties(nullptr, nullptr, nullptr, nullptr, application[JSON_VERSION].GetString());
            result_ = CommandResult::Done;
            ok = true;
        }
    }
    return ok;
}

void CmdGetFirmwareInfo::onTimeout() {
    result_ = (requireResponse_) ? CommandResult::InProgress : CommandResult::Done;
}


// Request Platform Id Command

CmdRequestPlatformId::CmdRequestPlatformId(const SerialDevicePtr& device) :
    BaseDeviceCommand(device, QStringLiteral("request_platform_id")) { }

QByteArray CmdRequestPlatformId::message() {
    return QByteArray("{\"cmd\":\"request_platform_id\"}");
}

bool CmdRequestPlatformId::processNotification(rapidjson::Document& doc) {
    if (CommandValidator::validate(CommandValidator::JsonType::reqPlatIdRes, doc)) {
        const rapidjson::Value& payload = doc[JSON_NOTIFICATION][JSON_PAYLOAD];
        const char *name = payload[JSON_NAME].GetString();
        const char *platformId = payload[JSON_PLATFORM_ID].GetString();
        const char *classId = payload[JSON_CLASS_ID].GetString();
        setDeviceProperties(name, platformId, classId, nullptr, nullptr);
        result_ = CommandResult::Done;
        return true;
    }
    return false;
}


// Update Firmware Command

CmdUpdateFirmware::CmdUpdateFirmware(const SerialDevicePtr& device) :
    BaseDeviceCommand(device, QStringLiteral("update_firmware")) { }

QByteArray CmdUpdateFirmware::message() {
    return QByteArray("{\"cmd\":\"update_firmware\"}");
}

bool CmdUpdateFirmware::processNotification(rapidjson::Document& doc) {
    if (CommandValidator::validate(CommandValidator::JsonType::updateFwRes, doc)) {
        const rapidjson::Value& status = doc[JSON_NOTIFICATION][JSON_PAYLOAD][JSON_STATUS];
        if (status == JSON_OK) {
            result_ = CommandResult::Done;
            return true;
        }
    }
    return false;
}

bool CmdUpdateFirmware::skip() {
    if (device_->property(DeviceProperties::verboseName) == BOOTLOADER_STR) {
        qCInfo(logCategoryDeviceOperations) << device_.get() << "Platform already in bootloader mode. Ready for firmware operations.";
        result_ = CommandResult::FinaliseOperation;
        return true;
    } else {
        return false;
    }
}

std::chrono::milliseconds CmdUpdateFirmware::waitBeforeNextCommand() const {
    // Bootloader takes 5 seconds to start (known issue related to clock source).
    // Platform and bootloader uses the same setting for clock source.
    // Clock source for bootloader and application must match. Otherwise when application jumps to bootloader,
    // it will have a hardware fault which requires board to be reset.
    qCInfo(logCategoryDeviceOperations) << device_.get() << "Waiting 5 seconds for bootloader to start.";
    return std::chrono::milliseconds(5500);
}

int CmdUpdateFirmware::dataForFinish() const {
    // If this command was skipped, return 1 instead of default value INT_MIN.
    return (result_ == CommandResult::FinaliseOperation) ? 1 : INT_MIN;
}


// Flash Firmware Command

CmdFlashFirmware::CmdFlashFirmware(const SerialDevicePtr& device) :
    BaseDeviceCommand(device, QStringLiteral("flash_firmware")),
    chunkNumber_(0), maxRetries_(MAX_CHUNK_RETRIES), retriesCount_(0) { }

QByteArray CmdFlashFirmware::message() {
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

bool CmdFlashFirmware::processNotification(rapidjson::Document& doc) {
    bool ok = false;
    if (CommandValidator::validate(CommandValidator::JsonType::flashFwRes, doc)) {
        const rapidjson::Value& status = doc[JSON_NOTIFICATION][JSON_PAYLOAD][JSON_STATUS];
        if (status == JSON_OK) {
            ok = true;
            result_ = (chunkNumber_ == 0) ? CommandResult::Done : CommandResult::Repeat;
        } else {
            if (status == JSON_RESEND_CHUNK) {
                if (retriesCount_ < maxRetries_) {
                    ++retriesCount_;
                    ok = true;
                    qCInfo(logCategoryDeviceOperations) << device_.get() << "Going to retry to flash firmware chunk.";
                    result_ = CommandResult::Retry;
                } else {
                    qCWarning(logCategoryDeviceOperations) << device_.get() << "Reached maximum retries for flash firmware chunk.";
                }
            }
        }
    }
    return ok;
}

bool CmdFlashFirmware::logSendMessage() const {
    return (chunkNumber_ == 1);
}

void CmdFlashFirmware::prepareRepeat() {
    retriesCount_ = 0;
}

int CmdFlashFirmware::dataForFinish() const {
    // flashed chunk number is used as data for finished() signal
    return chunkNumber_;
}

void CmdFlashFirmware::setChunk(const QVector<quint8>& chunk, int chunkNumber) {
    chunk_ = chunk;
    chunkNumber_ = chunkNumber;
}


// Backup Firmware Command

CmdBackupFirmware::CmdBackupFirmware(const SerialDevicePtr& device, QVector<quint8>& chunk) :
    BaseDeviceCommand(device, QStringLiteral("backup_firmware")),
    chunk_(chunk), firstBackupChunk_(true), maxRetries_(MAX_CHUNK_RETRIES), retriesCount_(0) { }

QByteArray CmdBackupFirmware::message() {
    QByteArray msg;
    if (retriesCount_ == 0) {
        msg = (firstBackupChunk_) ? "{\"cmd\":\"backup_firmware\"}" : "{\"cmd\":\"backup_firmware\",\"payload\":{\"status\":\"ok\"}}";
    } else {
        msg = "{\"cmd\":\"backup_firmware\",\"payload\":{\"status\":\"resend_chunk\"}}";
    }
    return msg;
}

bool CmdBackupFirmware::processNotification(rapidjson::Document& doc) {
    bool ok = false;
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
                    result_ = (chunkNumber_ == 0) ? CommandResult::Done : CommandResult::Repeat;
                } else {
                    qCCritical(logCategoryDeviceOperations) << device_.get() << "Wrong CRC of firmware chunk.";
                }
            } else {
                qCCritical(logCategoryDeviceOperations) << device_.get() << "Wrong SIZE of firmware chunk.";
            }
            if (ok == false) {
                if (retriesCount_ < maxRetries_) {
                    ++retriesCount_;
                    ok = true;
                    result_ = CommandResult::Retry;
                    qCInfo(logCategoryDeviceOperations) << device_.get() << "Going to retry to backup firmware chunk.";
                } else {
                    qCWarning(logCategoryDeviceOperations) << device_.get() << "Reached maximum retries for backup firmware chunk.";
                }
            }
        }
    }
    return ok;
}

bool CmdBackupFirmware::logSendMessage() const {
    return firstBackupChunk_;
}

void CmdBackupFirmware::prepareRepeat() {
    firstBackupChunk_ = false;
    retriesCount_ = 0;
}

int CmdBackupFirmware::dataForFinish() const {
    // backed up chunk number is used as data for finished() signal
    return chunkNumber_;
}


// Start Application Command

CmdStartApplication::CmdStartApplication(const SerialDevicePtr& device) :
    BaseDeviceCommand(device, QStringLiteral("start_application")) { }

QByteArray CmdStartApplication::message() {
    return QByteArray("{\"cmd\":\"start_application\"}");
}

bool CmdStartApplication::processNotification(rapidjson::Document& doc) {
    if (CommandValidator::validate(CommandValidator::JsonType::startAppRes, doc)) {
        const rapidjson::Value& status = doc[JSON_NOTIFICATION][JSON_PAYLOAD][JSON_STATUS];
        if (status == JSON_OK) {
            result_ = CommandResult::Done;
            return true;
        }
    }
    return false;
}

}  // namespace
