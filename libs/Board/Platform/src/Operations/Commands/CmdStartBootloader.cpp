/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "CmdStartBootloader.h"
#include "PlatformCommandConstants.h"
#include <PlatformOperationsStatus.h>

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

namespace strata::platform::command {

CmdStartBootloader::CmdStartBootloader(const PlatformPtr& platform) :
    BasePlatformCommand(platform, QStringLiteral("start_bootloader"), CommandType::StartBootloader)
{ }

QByteArray CmdStartBootloader::message() {
    return QByteArray("{\"cmd\":\"start_bootloader\",\"payload\":{}}");
}

bool CmdStartBootloader::processNotification(const rapidjson::Document& doc, CommandResult& result) {
    if (CommandValidator::validateNotification(CommandValidator::JsonType::startBootloaderNotif, doc)) {
        const rapidjson::Value& status = doc[JSON_NOTIFICATION][JSON_PAYLOAD][JSON_STATUS];
        if (status == JSON_OK) {
            result = CommandResult::Done;
            setDeviceApiVersion(Platform::ApiVersion::Unknown);
        } else {
            result = CommandResult::Failure;
        }
        return true;
    } else {
        return false;
    }
}

}  // namespace
