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
    commandList_.emplace_back(std::make_unique<CmdSetPlatformId>(device_, data));
    commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(device_));

    currentCommand_ = commandList_.end();
}

}  // namespace
