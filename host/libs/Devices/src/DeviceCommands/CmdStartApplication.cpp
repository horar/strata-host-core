#include "CmdStartApplication.h"
#include "DeviceOperationsConstants.h"

#include <CommandValidator.h>

namespace strata {

CmdStartApplication::CmdStartApplication(const SerialDevicePtr& device) :
    BaseDeviceCommand(device, QStringLiteral("start_application")) { }

QByteArray CmdStartApplication::message() {
    return QByteArray("{\"cmd\":\"start_application\"}");
}

bool CmdStartApplication::processNotification(rapidjson::Document& doc) {
    if (CommandValidator::validate(CommandValidator::JsonType::startAppRes, doc)) {
        const rapidjson::Value& status = doc[JSON_NOTIFICATION][JSON_PAYLOAD][JSON_STATUS];
        if (status == JSON_OK) {
            result_ = CommandResult::Done;
            return true;
        }
    }
    return false;
}

}  // namespace
