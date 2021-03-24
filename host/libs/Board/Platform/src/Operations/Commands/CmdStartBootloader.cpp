#include "CmdStartBootloader.h"
#include "PlatformOperationsConstants.h"
#include <PlatformOperationsStatus.h>

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

namespace strata::device::command {

CmdStartBootloader::CmdStartBootloader(const device::DevicePtr& device) :
    BaseDeviceCommand(device, QStringLiteral("start_bootloader"), CommandType::StartBootloader)
{ }

QByteArray CmdStartBootloader::message() {
    return QByteArray("{\"cmd\":\"start_bootloader\",\"payload\":{}}");
}

bool CmdStartBootloader::processNotification(rapidjson::Document& doc) {
    if (CommandValidator::validateNotification(CommandValidator::JsonType::startBootloaderNotif, doc)) {
        const rapidjson::Value& status = doc[JSON_NOTIFICATION][JSON_PAYLOAD][JSON_STATUS];
        if (status == JSON_OK) {
            result_ = CommandResult::Done;
            setDeviceApiVersion(device::Device::ApiVersion::Unknown);
        } else {
            result_ = CommandResult::Failure;
        }
        return true;
    } else {
        return false;
    }
}

}  // namespace
