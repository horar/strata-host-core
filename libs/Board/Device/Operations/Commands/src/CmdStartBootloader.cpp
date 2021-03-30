#include "CmdStartBootloader.h"
#include "DeviceOperationsConstants.h"
#include <DeviceOperationsStatus.h>

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

namespace strata::device::command {

CmdStartBootloader::CmdStartBootloader(const device::DevicePtr& device) :
    BaseDeviceCommand(device, QStringLiteral("start_bootloader"), CommandType::StartBootloader)
{ }

QByteArray CmdStartBootloader::message() {
    return QByteArray("{\"cmd\":\"start_bootloader\",\"payload\":{}}");
}

bool CmdStartBootloader::processNotification(rapidjson::Document& doc, CommandResult& result) {
    if (CommandValidator::validateNotification(CommandValidator::JsonType::startBootloaderNotif, doc)) {
        const rapidjson::Value& status = doc[JSON_NOTIFICATION][JSON_PAYLOAD][JSON_STATUS];
        if (status == JSON_OK) {
            result = CommandResult::Done;
            setDeviceApiVersion(device::Device::ApiVersion::Unknown);
        } else {
            result = CommandResult::Failure;
        }
        return true;
    } else {
        return false;
    }
}

}  // namespace
