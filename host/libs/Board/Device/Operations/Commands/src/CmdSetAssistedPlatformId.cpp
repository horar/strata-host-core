#include "CmdSetAssistedPlatformId.h"

#include "DeviceOperationsConstants.h"
#include <DeviceOperationsFinished.h>
#include <CommandValidator.h>
#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>
#include <QJsonObject>

namespace strata::device::command {

CmdSetAssistedPlatformId::CmdSetAssistedPlatformId(
        const device::DevicePtr &device,
        const QString &classId,
        const QString &platformId,
        int boardCount,
        const QString &controllerClassId,
        const QString &controllerPlatformId,
        int controllerBoardCount,
        const QString fwClassId)
    : BaseDeviceCommand(device, QStringLiteral("set_assisted_platform_id")),
      classId_(classId),
      platformId_(platformId),
      boardCount_(boardCount),
      controllerClassId_(controllerClassId),
      controllerPlatformId_(controllerPlatformId),
      controllerBoardCount_(controllerBoardCount),
      fwClassId_(fwClassId),
      dataForFinished_(operation::DEFAULT_DATA)
{
}

QByteArray CmdSetAssistedPlatformId::message()
{
    QJsonDocument doc;
    QJsonObject data;
    QJsonObject payload;

    payload.insert("class_id", classId_);
    payload.insert("platform_id", platformId_);
    payload.insert("board_count", boardCount_);
    payload.insert("controller_class_id", controllerClassId_);
    payload.insert("controller_platform_id", controllerPlatformId_);
    payload.insert("controller_board_count", controllerBoardCount_);
    payload.insert("fw_class_id", fwClassId_);

    data.insert("cmd", this->name());
    data.insert("payload", payload);

    doc.setObject(data);

    return doc.toJson(QJsonDocument::Compact);
}

bool CmdSetAssistedPlatformId::processNotification(rapidjson::Document &doc)
{
    if (CommandValidator::validateNotification(CommandValidator::JsonType::setAssistedPlatformIdNotif, doc) == false) {
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

int CmdSetAssistedPlatformId::dataForFinish() const
{
    return dataForFinished_;
}

}
