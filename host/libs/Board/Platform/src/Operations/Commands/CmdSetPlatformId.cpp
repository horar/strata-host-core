#include "CmdSetPlatformId.h"

#include "PlatformOperationsConstants.h"
#include <PlatformOperationsStatus.h>
#include <CommandValidator.h>
#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>
#include <QJsonObject>

namespace strata::platform::command {

CmdSetPlatformId::CmdSetPlatformId(
        const device::DevicePtr& device,
        const CmdSetPlatformIdData& data)
    : BasePlatformCommand(device, QStringLiteral("set_platform_id"), CommandType::SetPlatformId),
      data_(data)
{
}

QByteArray CmdSetPlatformId::message()
{
    QJsonDocument doc;
    QJsonObject data;
    QJsonObject payload;

    payload.insert(JSON_CLASS_ID, data_.classId);
    payload.insert(JSON_PLATFORM_ID, data_.platformId);
    payload.insert(JSON_BOARD_COUNT, data_.boardCount);

    data.insert(JSON_CMD, this->name());
    data.insert(JSON_PAYLOAD, payload);

    doc.setObject(data);

    return doc.toJson(QJsonDocument::Compact);
}

bool CmdSetPlatformId::processNotification(rapidjson::Document& doc, CommandResult& result)
{
    if (CommandValidator::validateNotification(CommandValidator::JsonType::setPlatformIdNotif, doc) == false) {
        return false;
    }

    result = CommandResult::Failure;

    const rapidjson::Value& payload = doc[JSON_NOTIFICATION][JSON_PAYLOAD];
    const QString jsonStatus = payload[JSON_STATUS].GetString();

    if (jsonStatus == JSON_OK) {
        result = CommandResult::Done;
    } else if (jsonStatus == JSON_FAILED) {
        status_ = operation::SET_PLATFORM_ID_FAILED;
    } else if (jsonStatus == JSON_ALREADY_INITIALIZED) {
        status_ = operation::PLATFORM_ID_ALREADY_SET;
    } else {
        qCCritical(logCategoryPlatformCommand) << device_ << "Unknown status string:" << jsonStatus;
    }

    return true;
}

}  // namespace
