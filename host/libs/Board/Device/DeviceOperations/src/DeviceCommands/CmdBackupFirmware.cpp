#include "CmdBackupFirmware.h"
#include "DeviceOperationsConstants.h"

#include <DeviceOperationsFinished.h>

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

#include <CodecBase64.h>
#include <Buypass.h>

namespace strata::device::command {

CmdBackupFirmware::CmdBackupFirmware(const device::DevicePtr& device, QVector<quint8>& chunk, int& totalChunks) :
    BaseDeviceCommand(device, QStringLiteral("backup_firmware")), chunk_(chunk),
    totalChunks_(totalChunks), firstBackupChunk_(true), maxRetries_(MAX_CHUNK_RETRIES), retriesCount_(0) { }

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
    if (CommandValidator::validate(CommandValidator::JsonType::backupFirmwareRes, doc)) {
        const rapidjson::Value& payload = doc[JSON_NOTIFICATION][JSON_PAYLOAD];
        if (payload.HasMember(JSON_STATUS)) {
            const rapidjson::Value& status = payload[JSON_STATUS];
            if (status == CSTR_NO_FIRMWARE) {
                qCWarning(logCategoryDeviceOperations) << device_ << "Nothing to backup, board has no firmware.";
                result_ = CommandResult::FinaliseOperation;
            } else {
                result_ = CommandResult::Failure;
            }
        } else {
            const rapidjson::Value& chunk = payload[JSON_CHUNK];
            const rapidjson::Value& number = chunk[JSON_NUMBER];
            const rapidjson::Value& total = chunk[JSON_TOTAL];
            const rapidjson::Value& size = chunk[JSON_SIZE];
            const rapidjson::Value& crc = chunk[JSON_CRC];
            const rapidjson::Value& data = chunk[JSON_DATA];

            if (number.IsInt() && total.IsInt() && size.IsUint() && crc.IsUint()) {
                rapidjson::SizeType dataSize = data.GetStringLength();
                size_t maxDecodedSize = base64::decoded_size(dataSize); // returns max bytes needed to decode a base64 string
                chunk_.resize(static_cast<int>(maxDecodedSize));
                const char *dataStr = data.GetString();
                auto [realDecodedSize, readChars] = base64::decode(chunk_.data(), dataStr, dataSize);
                chunk_.resize(static_cast<int>(realDecodedSize));
                chunkNumber_ = number.GetInt();
                totalChunks_ = total.GetInt();

                bool ok = false;
                if (size.GetUint() == realDecodedSize) {
                    if (crc.GetUint() == crc16::buypass(chunk_.data(), static_cast<uint32_t>(chunk_.size()))) {
                        ok = true;
                    } else {
                        qCCritical(logCategoryDeviceOperations) << device_ << "Wrong CRC of firmware chunk.";
                    }
                } else {
                    qCCritical(logCategoryDeviceOperations) << device_ << "Wrong SIZE of firmware chunk.";
                }

                if (ok) {
                    result_ = (chunkNumber_ == 0) ? CommandResult::Done : CommandResult::Repeat;
                } else {
                    if (retriesCount_ < maxRetries_) {
                        ++retriesCount_;
                        qCInfo(logCategoryDeviceOperations) << device_ << "Going to retry to backup firmware chunk.";
                        result_ = CommandResult::Retry;
                    } else {
                        qCWarning(logCategoryDeviceOperations) << device_ << "Reached maximum retries for backup firmware chunk.";
                        result_ = CommandResult::Failure;
                    }
                }
            }
        }
        return true;
    } else {
        return false;
    }
}

bool CmdBackupFirmware::logSendMessage() const {
    return firstBackupChunk_;
}

void CmdBackupFirmware::prepareRepeat() {
    firstBackupChunk_ = false;
    retriesCount_ = 0;
}

int CmdBackupFirmware::dataForFinish() const {
    // backed up chunk number or OPERATION_BACKUP_NO_FIRMWARE is used as data for finished() signal
    return (result_ == CommandResult::FinaliseOperation) ? OPERATION_BACKUP_NO_FIRMWARE : chunkNumber_;
}

}  // namespace
