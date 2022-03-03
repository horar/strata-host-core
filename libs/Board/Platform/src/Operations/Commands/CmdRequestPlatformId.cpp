/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "CmdRequestPlatformId.h"
#include "PlatformCommandConstants.h"

#include <CommandValidator.h>

#include <cstring>

namespace strata::platform::command {

CmdRequestPlatformId::CmdRequestPlatformId(const PlatformPtr& platform) :
    BasePlatformCommand(platform, QStringLiteral("request_platform_id"), CommandType::RequestPlatformid)
{ }

QByteArray CmdRequestPlatformId::message() {
    return QByteArray("{\"cmd\":\"request_platform_id\",\"payload\":{}}");
}

bool CmdRequestPlatformId::processNotification(const rapidjson::Document& doc, CommandResult& result) {
    if (CommandValidator::validateNotification(CommandValidator::JsonType::reqPlatformIdNotif, doc)) {
        const rapidjson::Value& payload = doc[JSON_NOTIFICATION][JSON_PAYLOAD];
        const char *name = payload[JSON_NAME].GetString();
        const char *platformId = nullptr;
        const char *classId = nullptr;
        Platform::ControllerType controllerType = Platform::ControllerType::Embedded;
        if (payload.HasMember(JSON_PLATFORM_ID)) {
            platformId = payload[JSON_PLATFORM_ID].GetString();
            classId = payload[JSON_CLASS_ID].GetString();
        }
        if (payload.HasMember(JSON_CONTROLLER_TYPE)) {
            if (payload[JSON_CONTROLLER_TYPE].GetInt() == CONTROLLER_TYPE_ASSISTED) {
                controllerType = Platform::ControllerType::Assisted;
            }
        }
        setDeviceProperties(name, platformId, classId, controllerType);
        if (payload.HasMember(JSON_CNTRL_PLATFORM_ID)) {
            setDeviceAssistedProperties(payload[JSON_CNTRL_PLATFORM_ID].GetString(),
                                        payload[JSON_CNTRL_CLASS_ID].GetString(),
                                        payload[JSON_FW_CLASS_ID].GetString());
        }

        Platform::ApiVersion apiVersion = platform_->apiVersion();
        if (apiVersion == Platform::ApiVersion::Unknown || apiVersion == Platform::ApiVersion::v1_0) {
            if (std::strcmp(name, CSTR_NAME_BOOTLOADER) == 0) {
                setDeviceBootloaderMode(true);
            }
            if (payload.HasMember(JSON_PLATF_ID_VER)) {
                setDeviceApiVersion(Platform::ApiVersion::v1_0);
            }
        }

        result = CommandResult::Done;
        return true;
    } else {
        return false;
    }
}

}  // namespace
