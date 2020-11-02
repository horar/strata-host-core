#include <Device/Operations/SetAssistedPlatformId.h>
#include "Commands/include/DeviceCommands.h"
#include "DeviceOperationsConstants.h"


namespace strata::device::operation {

using command::CmdSetAssistedPlatformId;

SetAssistedPlatformId::SetAssistedPlatformId(
        const DevicePtr &device,
        const command::CmdSetAssistedPlatformIdData &data)
    : BaseDeviceOperation(device, Type::SetAssistedPlatformId)
{
    commandList_.emplace_back(std::make_unique<CmdSetAssistedPlatformId>(
                                  device_,
                                  data));

    currentCommand_ = commandList_.end();
}

}  // namespace
