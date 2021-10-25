/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "CmdSetPlatformId.h"

#include "PlatformCommandConstants.h"
#include <PlatformOperationsStatus.h>
#include <CommandValidator.h>
#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>
#include <QJsonObject>

namespace strata::platform::command {

CmdSetPlatformId::CmdSetPlatformId(
        const PlatformPtr& platform,
        const CmdSetPlatformIdData& data)
    : BasePlatformCommand(platform, QStringLiteral("set_platform_id"), CommandType::SetPlatformId),
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

bool CmdSetPlatformId::processNotification(const rapidjson::Document& doc, CommandResult& result)
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
        qCCritical(lcPlatformCommand) << platform_ << "Unknown status string:" << jsonStatus;
    }

    return true;
}

}  // namespace
