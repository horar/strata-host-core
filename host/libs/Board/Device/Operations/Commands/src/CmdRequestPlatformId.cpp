#include "CmdRequestPlatformId.h"
#include "DeviceOperationsConstants.h"

#include <CommandValidator.h>

#include <cstring>

namespace strata::device::command {


CmdRequestPlatformId::CmdRequestPlatformId(const device::DevicePtr& device) :
    BaseDeviceCommand(device, QStringLiteral("request_platform_id")) { }

QByteArray CmdRequestPlatformId::message() {
    return QByteArray("{\"cmd\":\"request_platform_id\",\"payload\":{}}");
}

bool CmdRequestPlatformId::processNotification(rapidjson::Document& doc) {
    if (CommandValidator::validateNotification(CommandValidator::JsonType::reqPlatformIdNotif, doc)) {
        const rapidjson::Value& payload = doc[JSON_NOTIFICATION][JSON_PAYLOAD];
        const char *name = payload[JSON_NAME].GetString();
        const char *platformId = "";
        const char *classId = "";
        Device::ControllerType controllerType = Device::ControllerType::Embedded;
        if (payload.HasMember(JSON_PLATFORM_ID)) {
            platformId = payload[JSON_PLATFORM_ID].GetString();
            classId = payload[JSON_CLASS_ID].GetString();
        }
        if (payload.HasMember(JSON_CONTROLLER_TYPE)) {
            if (payload[JSON_CONTROLLER_TYPE].GetInt() == CONTROLLER_TYPE_ASSISTED) {
                controllerType = Device::ControllerType::Assisted;
            }
        }
        setDeviceProperties(name, platformId, classId, controllerType);
        if (payload.HasMember(JSON_CNTRL_PLATFORM_ID)) {
            setDeviceAssistedProperties(payload[JSON_CNTRL_PLATFORM_ID].GetString(),
                                        payload[JSON_CNTRL_CLASS_ID].GetString(),
                                        payload[JSON_FW_CLASS_ID].GetString());
        }

        Device::ApiVersion apiVersion = device_->apiVersion();
        if (apiVersion == Device::ApiVersion::Unknown || apiVersion == Device::ApiVersion::v1_0) {
            if (std::strcmp(name, CSTR_NAME_BOOTLOADER) == 0) {
                setDeviceBootloaderMode(true);
            }
            if (payload.HasMember(JSON_PLATF_ID_VER)) {
                setDeviceApiVersion(Device::ApiVersion::v1_0);
            }
        }

        result_ = CommandResult::Done;
        return true;
    } else {
        return false;
    }
}

}  // namespace
