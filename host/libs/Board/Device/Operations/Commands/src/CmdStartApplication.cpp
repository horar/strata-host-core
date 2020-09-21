#include "CmdStartApplication.h"
#include "DeviceOperationsConstants.h"

#include <CommandValidator.h>

namespace strata::device::command {

CmdStartApplication::CmdStartApplication(const device::DevicePtr& device) :
    BaseDeviceCommand(device, QStringLiteral("start_application")) { }

QByteArray CmdStartApplication::message() {
    return QByteArray("{\"cmd\":\"start_application\",\"payload\":{}}");
}

bool CmdStartApplication::processNotification(rapidjson::Document& doc) {
    if (CommandValidator::validateNotification(CommandValidator::JsonType::startApplicationNotif, doc)) {
        const rapidjson::Value& status = doc[JSON_NOTIFICATION][JSON_PAYLOAD][JSON_STATUS];
        result_ = (status == JSON_OK) ? CommandResult::Done : CommandResult::Failure;
        return true;
    } else {
        return false;
    }
}

}  // namespace
