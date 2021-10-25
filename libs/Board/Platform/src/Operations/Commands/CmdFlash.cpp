/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "CmdFlash.h"
#include "PlatformCommandConstants.h"

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

#include <CodecBase64.h>
#include <Buypass.h>

#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>

namespace strata::platform::command {

CmdFlash::CmdFlash(const PlatformPtr& platform, int chunkCount, bool flashFirmware) :
    BasePlatformCommand(platform,
                      (flashFirmware) ? QStringLiteral("flash_firmware") : QStringLiteral("flash_bootloader"),
                      (flashFirmware) ? CommandType::FlashFirmware : CommandType::FlashBootloader),
    flashFirmware_(flashFirmware), chunkNumber_(0), chunkCount_(chunkCount),
    maxRetries_(MAX_CHUNK_RETRIES), retriesCount_(0)
{ }

QByteArray CmdFlash::message() {
    rapidjson::StringBuffer sb;
    rapidjson::Writer<rapidjson::StringBuffer> writer(sb);

    writer.StartObject();

    writer.Key(JSON_CMD);
    writer.String((flashFirmware_) ? JSON_FLASH_FIRMWARE : JSON_FLASH_BOOTLOADER);

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

bool CmdFlash::processNotification(const rapidjson::Document& doc, CommandResult& result) {
    CommandValidator::JsonType jsonType = (flashFirmware_)
                                          ? CommandValidator::JsonType::flashFirmwareNotif
                                          : CommandValidator::JsonType::flashBootloaderNotif;
    if (CommandValidator::validateNotification(jsonType, doc)) {
        const rapidjson::Value& status = doc[JSON_NOTIFICATION][JSON_PAYLOAD][JSON_STATUS];
        if (status == JSON_OK) {
            result = (chunkNumber_ == (chunkCount_ - 1)) ? CommandResult::Done : CommandResult::RepeatAndWait;
        } else {
            result = CommandResult::Failure;
            if (status == JSON_RESEND_CHUNK) {
                const char* binaryType = (flashFirmware_) ? "firmware" : "bootloader";
                if (retriesCount_ < maxRetries_) {
                    ++retriesCount_;
                    qCInfo(lcPlatformCommand) << platform_ << "Going to retry to flash " << binaryType << " chunk.";
                    result = CommandResult::Retry;
                } else {
                    qCWarning(lcPlatformCommand) << platform_ << "Reached maximum retries for flash " << binaryType << " chunk.";
                }
            }
        }
        return true;
    } else {
        return false;
    }
}

bool CmdFlash::logSendMessage() const {
    // log only first flashed chunk
    return (chunkNumber_ == 0);
}

void CmdFlash::setNewChunk(const QVector<quint8>& chunk, int chunkNumber) {
    chunk_ = chunk;
    chunkNumber_ = chunkNumber;
    status_ = chunkNumber_;
    retriesCount_ = 0;  // reset retries count before next run
}

}  // namespace
