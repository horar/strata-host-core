/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "CmdSetAssistedPlatformId.h"

#include "PlatformCommandConstants.h"
#include <PlatformOperationsStatus.h>
#include <CommandValidator.h>
#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>
#include <QJsonObject>

namespace strata::platform::command {

CmdSetAssistedPlatformId::CmdSetAssistedPlatformId(const PlatformPtr& platform)
    : BasePlatformCommand(platform, QStringLiteral("set_assisted_platform_id"), CommandType::SetAssistedPlatformId)
{
}

void CmdSetAssistedPlatformId::setBaseData(const CmdSetPlatformIdData& data)
{
    data_ = data;
}

void CmdSetAssistedPlatformId::setControllerData(const CmdSetPlatformIdData& controllerData)
{
    controllerData_ = controllerData;
}

void CmdSetAssistedPlatformId::setFwClassId(const QString& fwClassId)
{
    fwClassId_ = fwClassId;
}

QByteArray CmdSetAssistedPlatformId::message()
{
    QJsonDocument doc;
    QJsonObject data;
    QJsonObject payload;

    if (data_.has_value()) {
        payload.insert(JSON_CLASS_ID, data_->classId);
        payload.insert(JSON_PLATFORM_ID, data_->platformId);
        payload.insert(JSON_BOARD_COUNT, data_->boardCount);
    }

    if (controllerData_.has_value()) {
        payload.insert(JSON_CNTRL_CLASS_ID, controllerData_->classId);
        payload.insert(JSON_CNTRL_PLATFORM_ID, controllerData_->platformId);
        payload.insert(JSON_CNTRL_BOARD_COUNT, controllerData_->boardCount);
    }

    if (fwClassId_.has_value()) {
        //macos 10.14 does not support value()
        payload.insert(JSON_FW_CLASS_ID, fwClassId_.value_or(""));
    }

    data.insert(JSON_CMD, this->name());
    data.insert(JSON_PAYLOAD, payload);

    doc.setObject(data);

    return doc.toJson(QJsonDocument::Compact);
}

bool CmdSetAssistedPlatformId::processNotification(const rapidjson::Document& doc, CommandResult& result)
{
    if (CommandValidator::validateNotification(CommandValidator::JsonType::setAssistedPlatformIdNotif, doc) == false) {
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
    } else if (jsonStatus == JSON_BOARD_NOT_CONNECTED) {
        status_ = operation::BOARD_NOT_CONNECTED_TO_CONTROLLER;
    } else {
        qCCritical(lcPlatformCommand) << platform_ << "Unknown status string:" << jsonStatus;
    }

    return true;
}

}  // namespace
