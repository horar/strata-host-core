#include "CmdFlashFirmware.h"
#include "DeviceOperationsConstants.h"

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

#include <CodecBase64.h>
#include <Buypass.h>

#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>

namespace strata::device::command {

CmdFlashFirmware::CmdFlashFirmware(const device::DevicePtr& device) :
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
    if (CommandValidator::validate(CommandValidator::JsonType::flashFwRes, doc)) {
        const rapidjson::Value& status = doc[JSON_NOTIFICATION][JSON_PAYLOAD][JSON_STATUS];
        if (status == JSON_OK) {
            result_ = (chunkNumber_ == 0) ? CommandResult::Done : CommandResult::Repeat;
        } else {
            result_ = CommandResult::Failure;
            if (status == JSON_RESEND_CHUNK) {
                if (retriesCount_ < maxRetries_) {
                    ++retriesCount_;
                    qCInfo(logCategoryDeviceOperations) << device_ << "Going to retry to flash firmware chunk.";
                    result_ = CommandResult::Retry;
                } else {
                    qCWarning(logCategoryDeviceOperations) << device_ << "Reached maximum retries for flash firmware chunk.";
                }
            }
        }
        return true;
    } else {
        return false;
    }
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

}  // namespace
