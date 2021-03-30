#include <Device/Operations/SetPlatformId.h>
#include "Commands/include/DeviceCommands.h"
#include "DeviceOperationsConstants.h"

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

    initCommandList();
}

}  // namespace
