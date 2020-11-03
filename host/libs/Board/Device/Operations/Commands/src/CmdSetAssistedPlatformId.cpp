#include "CmdSetAssistedPlatformId.h"

#include "DeviceOperationsConstants.h"
#include <DeviceOperationsFinished.h>
#include <CommandValidator.h>
#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>
#include <QJsonObject>

namespace strata::device::command {

CmdSetAssistedPlatformId::CmdSetAssistedPlatformId(const DevicePtr &device)
    : BaseDeviceCommand(device, QStringLiteral("set_assisted_platform_id")),
      dataForFinished_(operation::DEFAULT_DATA)
{
}

void CmdSetAssistedPlatformId::setBaseData(const CmdSetPlatformIdData &data)
{
    data_ = data;
}

void CmdSetAssistedPlatformId::setControllerData(const CmdSetPlatformIdData &controllerData)
{
    controllerData_ = controllerData;
}

void CmdSetAssistedPlatformId::setFwClassId(const QString &fwClassId)
{
    fwClassId_ = fwClassId;
}

QByteArray CmdSetAssistedPlatformId::message()
{
    QJsonDocument doc;
    QJsonObject data;
    QJsonObject payload;

    if (data_.has_value()) {
        payload.insert("class_id", data_->classId);
        payload.insert("platform_id", data_->platformId);
        payload.insert("board_count", data_->boardCount);
    }

    if (controllerData_.has_value()) {
        payload.insert("controller_class_id", controllerData_->classId);
        payload.insert("controller_platform_id", controllerData_->platformId);
        payload.insert("controller_board_count", controllerData_->boardCount);
    }

    if (fwClassId_.has_value()) {
        //macos 10.14 does not support value()
        payload.insert("fw_class_id", fwClassId_.value_or(""));
    }

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
