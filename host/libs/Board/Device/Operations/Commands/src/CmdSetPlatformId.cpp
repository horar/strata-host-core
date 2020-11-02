#include "CmdSetPlatformId.h"

#include "DeviceOperationsConstants.h"
#include <DeviceOperationsFinished.h>
#include <CommandValidator.h>
#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>
#include <QJsonObject>

namespace strata::device::command {

CmdSetPlatformId::CmdSetPlatformId(
        const device::DevicePtr &device,
        const CmdSetPlatformIdData &data)
    : BaseDeviceCommand(device, QStringLiteral("set_platform_id")),
      data_(data),
      dataForFinished_(operation::DEFAULT_DATA)
{
}

QByteArray CmdSetPlatformId::message()
{
    QJsonDocument doc;
    QJsonObject data;
    QJsonObject payload;

    payload.insert("class_id", data_.classId);
    payload.insert("platform_id", data_.platformId);
    payload.insert("board_count", data_.boardCount);

    data.insert("cmd", this->name());
    data.insert("payload", payload);

    doc.setObject(data);

    return doc.toJson(QJsonDocument::Compact);
}

bool CmdSetPlatformId::processNotification(rapidjson::Document &doc)
{
    if (CommandValidator::validateNotification(CommandValidator::JsonType::setPlatformIdNotif, doc) == false) {
        return false;
    }

    result_ = CommandResult::Failure;

    const rapidjson::Value& payload = doc[JSON_NOTIFICATION][JSON_PAYLOAD];
    QString status = payload[JSON_STATUS].GetString();

    if (status == "ok") {
        result_ = CommandResult::Done;
    } else if (status == "failed") {
        dataForFinished_ = operation::SET_PLATFORM_ID_FAILED;
    } else if (status == "already_initialized") {
        dataForFinished_ = operation::PLATFORM_ID_ALREADY_SET;
    } else {
        qCCritical(logCategoryDeviceOperations) << "unknown status string:" << status;
    }

    return true;
}

int CmdSetPlatformId::dataForFinish() const
{
    return dataForFinished_;
}

} //namespace
