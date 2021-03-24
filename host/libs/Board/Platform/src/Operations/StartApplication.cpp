#include <Operations/StartApplication.h>
#include "Commands/PlatformCommands.h"
#include "PlatformOperationsConstants.h"

namespace strata::device::operation {

using command::CmdStartApplication;
using command::CmdRequestPlatformId;
using command::CmdGetFirmwareInfo;

StartApplication::StartApplication(const device::DevicePtr& device) :
    BaseDeviceOperation(device, Type::StartApplication)
{
    commandList_.reserve(3);

    // BaseDeviceOperation member device_ must be used as a parameter for commands!
    commandList_.emplace_back(std::make_unique<CmdStartApplication>(device_));
    commandList_.emplace_back(std::make_unique<CmdGetFirmwareInfo>(device_, true, MAX_GET_FW_INFO_RETRIES));
    commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(device_));

    currentCommand_ = commandList_.end();
}

}  // namespace
