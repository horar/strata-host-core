#include "CmdRequestPlatformId.h"
#include "DeviceOperationsConstants.h"

#include <CommandValidator.h>

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
        if (payload.HasMember(JSON_PLATFORM_ID)) {
            platformId = payload[JSON_PLATFORM_ID].GetString();
            classId = payload[JSON_CLASS_ID].GetString();
        }
        setDeviceProperties(name, platformId, classId, nullptr, nullptr);
        result_ = CommandResult::Done;
        return true;
    } else {
        return false;
    }
}

}  // namespace
