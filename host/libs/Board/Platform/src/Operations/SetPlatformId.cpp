#include <Operations/SetPlatformId.h>
#include "Commands/PlatformCommands.h"
#include "PlatformOperationsConstants.h"

namespace strata::device::operation {

using command::CmdSetPlatformId;
using command::CmdRequestPlatformId;

SetPlatformId::SetPlatformId(
        const device::DevicePtr &device,
        const command::CmdSetPlatformIdData &data)
    : BaseDeviceOperation(device, Type::SetPlatformId)
{
    commandList_.reserve(2);

    // BaseDeviceOperation member device_ must be used as a parameter for commands!
    commandList_.emplace_back(std::make_unique<CmdSetPlatformId>(device_, data));
    commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(device_));

    currentCommand_ = commandList_.end();
}

}  // namespace
