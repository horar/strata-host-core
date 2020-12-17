#include "CmdStartBootloader.h"
#include "DeviceOperationsConstants.h"
#include <DeviceOperationsStatus.h>

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

namespace strata::device::command {

CmdStartBootloader::CmdStartBootloader(const device::DevicePtr& device) :
    BaseDeviceCommand(device, QStringLiteral("start_bootloader")) { }

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

std::chrono::milliseconds CmdStartBootloader::waitBeforeNextCommand() const {
    // Bootloader takes 5 seconds to start (known issue related to clock source).
    // Platform and bootloader uses the same setting for clock source.
    // Clock source for bootloader and application must match. Otherwise when application jumps to bootloader,
    // it will have a hardware fault which requires board to be reset.
    qCInfo(logCategoryDeviceOperations) << device_ << "Waiting 5 seconds for bootloader to start.";
    return std::chrono::milliseconds(5500);
}

}  // namespace
