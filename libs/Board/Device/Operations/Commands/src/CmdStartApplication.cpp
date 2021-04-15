#include "CmdStartApplication.h"
#include "DeviceCommandConstants.h"

#include <cstring>

#include <DeviceOperationsStatus.h>

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

namespace strata::device::command {

CmdStartApplication::CmdStartApplication(const device::DevicePtr& device) :
    BaseDeviceCommand(device, QStringLiteral("start_application"), CommandType::StartApplication)
{ }

QByteArray CmdStartApplication::message() {
    return QByteArray("{\"cmd\":\"start_application\",\"payload\":{}}");
}

bool CmdStartApplication::processNotification(rapidjson::Document& doc, CommandResult& result) {
    if (CommandValidator::validateNotification(CommandValidator::JsonType::startApplicationNotif, doc)) {
        result = CommandResult::Failure;

        const char* jsonStatus = doc[JSON_NOTIFICATION][JSON_PAYLOAD][JSON_STATUS].GetString();
        if (std::strcmp(jsonStatus, JSON_OK) == 0) {
            result = CommandResult::Done;
            setDeviceApiVersion(device::Device::ApiVersion::Unknown);
            setDeviceBootloaderMode(false);
        } else {
            if (std::strcmp(jsonStatus, CSTR_NO_FIRMWARE) == 0) {
                qCWarning(logCategoryDeviceCommand) << device_ << "Nothing to start, board has no valid firmware.";
                result = CommandResult::FinaliseOperation;
                status_ = operation::NO_FIRMWARE;
            }
        }

        return true;
    } else {
        return false;
    }
}

}  // namespace