/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "CmdBackupFirmware.h"
#include "PlatformCommandConstants.h"

#include <PlatformOperationsStatus.h>

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

#include <CodecBase64.h>
#include <Buypass.h>

namespace strata::platform::command {

CmdBackupFirmware::CmdBackupFirmware(const PlatformPtr& platform, QVector<quint8>& chunk, int totalChunks) :
    BasePlatformCommand(platform, QStringLiteral("backup_firmware"), CommandType::BackupFirmware), chunk_(chunk),
    totalChunks_(totalChunks), firstBackupChunk_(true), maxRetries_(MAX_CHUNK_RETRIES), retriesCount_(0)
{ }

QByteArray CmdBackupFirmware::message()
{
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

bool CmdBackupFirmware::processNotification(const rapidjson::Document& doc, CommandResult& result)
{
    if (CommandValidator::validateNotification(CommandValidator::JsonType::backupFirmwareNotif, doc)) {
        if (totalChunks_ <= 0) {
            qCWarning(lcPlatformCommand) << platform_ << "Count of firmware chunks is not known.";
            result = CommandResult::Failure;
        } else {
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
                    qCDebug(lcPlatformCommand) << platform_ << "Received chunk with size " << realDecodedSize << " bytes.";
                    if (crc.GetUint() == crc16::buypass(chunk_.data(), static_cast<uint32_t>(chunk_.size()))) {
                        ok = true;
                    } else {
                        qCCritical(lcPlatformCommand) << platform_ << "Wrong CRC of firmware chunk.";
                    }
                } else {
                    qCCritical(lcPlatformCommand) << platform_ << "Wrong SIZE of firmware chunk.";
                }

                if (ok) {
                    result = ((chunkNumber_ + 1) == totalChunks_) ? CommandResult::Done : CommandResult::RepeatAndWait;
                    retriesCount_ = 0;  // reset retries count before next run
                } else {
                    if (retriesCount_ < maxRetries_) {
                        ++retriesCount_;
                        qCInfo(lcPlatformCommand) << platform_ << "Going to retry to backup firmware chunk.";
                        result = CommandResult::Retry;
                    } else {
                        qCWarning(lcPlatformCommand) << platform_ << "Reached maximum retries for backup firmware chunk.";
                        result = CommandResult::Failure;
                    }
                }
            } else {
                qCWarning(lcPlatformCommand) << platform_ << "Wrong format of notification.";
                result = CommandResult::Failure;
            }
        }

        return true;
    } else {
        return false;
    }
}

bool CmdBackupFirmware::logSendMessage() const
{
    return firstBackupChunk_;
}

void CmdBackupFirmware::setTotalChunks(int totalChunks)
{
    totalChunks_ = totalChunks;
}

}  // namespace
