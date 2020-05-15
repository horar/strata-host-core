#include "CmdRequestPlatformId.h"
#include "DeviceOperationsConstants.h"

#include <CommandValidator.h>

namespace strata {

CmdRequestPlatformId::CmdRequestPlatformId(const SerialDevicePtr& device) :
    BaseDeviceCommand(device, QStringLiteral("request_platform_id")) { }

QByteArray CmdRequestPlatformId::message() {
    return QByteArray("{\"cmd\":\"request_platform_id\"}");
}

bool CmdRequestPlatformId::processNotification(rapidjson::Document& doc) {
    if (CommandValidator::validate(CommandValidator::JsonType::reqPlatIdRes, doc)) {
        const rapidjson::Value& payload = doc[JSON_NOTIFICATION][JSON_PAYLOAD];
        const char *name = payload[JSON_NAME].GetString();
        const char *platformId = payload[JSON_PLATFORM_ID].GetString();
        const char *classId = payload[JSON_CLASS_ID].GetString();
        setDeviceProperties(name, platformId, classId, nullptr, nullptr);
        result_ = CommandResult::Done;
        return true;
    }
    return false;
}

}  // namespace
