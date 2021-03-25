#include "CmdBackupFirmware.h"
#include "PlatformOperationsConstants.h"

#include <PlatformOperationsStatus.h>

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

#include <CodecBase64.h>
#include <Buypass.h>

namespace strata::platform::command {

CmdBackupFirmware::CmdBackupFirmware(const device::DevicePtr& device, QVector<quint8>& chunk, int totalChunks) :
    BasePlatformCommand(device, QStringLiteral("backup_firmware"), CommandType::BackupFirmware), chunk_(chunk),
    totalChunks_(totalChunks), firstBackupChunk_(true), maxRetries_(MAX_CHUNK_RETRIES), retriesCount_(0) { }

QByteArray CmdBackupFirmware::message() {
    QByteArray status;
    if (retriesCount_ == 0) {
        if (firstBackupChunk_) {
            status = "init";
            firstBackupChunk_ = false;
        } else {
            status = "ok";
        }
    } else {
        status = "resend_chunk";
    }
    return QByteArray("{\"cmd\":\"backup_firmware\",\"payload\":{\"status\":\"" + status + "\"}}");
}

bool CmdBackupFirmware::processNotification(rapidjson::Document& doc) {
    if (CommandValidator::validateNotification(CommandValidator::JsonType::backupFirmwareNotif, doc)) {
        const rapidjson::Value& payload = doc[JSON_NOTIFICATION][JSON_PAYLOAD];
        const rapidjson::Value& chunk = payload[JSON_CHUNK];
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
            status_ = chunkNumber_;

            bool ok = false;
            if (size.GetUint() == realDecodedSize) {
                if (crc.GetUint() == crc16::buypass(chunk_.data(), static_cast<uint32_t>(chunk_.size()))) {
                    ok = true;
                } else {
                    qCCritical(logCategoryPlatformOperations) << device_ << "Wrong CRC of firmware chunk.";
                }
            } else {
                qCCritical(logCategoryPlatformOperations) << device_ << "Wrong SIZE of firmware chunk.";
            }

            if (ok) {
                result_ = ((chunkNumber_ + 1) == totalChunks_) ? CommandResult::Done : CommandResult::Partial;
                retriesCount_ = 0;  // reset retries count before next run
            } else {
                if (retriesCount_ < maxRetries_) {
                    ++retriesCount_;
                    qCInfo(logCategoryPlatformOperations) << device_ << "Going to retry to backup firmware chunk.";
                    result_ = CommandResult::Retry;
                } else {
                    qCWarning(logCategoryPlatformOperations) << device_ << "Reached maximum retries for backup firmware chunk.";
                    result_ = CommandResult::Failure;
                }
            }
        } else {
            qCWarning(logCategoryPlatformOperations) << device_ << "Wrong format of notification.";
            result_ = CommandResult::Failure;
        }

        return true;
    } else {
        return false;
    }
}

bool CmdBackupFirmware::logSendMessage() const {
    return firstBackupChunk_;
}

}  // namespace
