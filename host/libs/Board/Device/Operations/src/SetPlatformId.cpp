#include <Device/Operations/SetPlatformId.h>
#include "Commands/include/DeviceCommands.h"
#include "DeviceOperationsConstants.h"

namespace strata::device::operation {

using command::CmdSetPlatformId;

SetPlatformId::SetPlatformId(
        const device::DevicePtr& device,
        const QString &classId,
        const QString &platformId,
        int boardCount)
    : BaseDeviceOperation(device, Type::SetPlatformId)
{
    commandList_.emplace_back(std::make_unique<CmdSetPlatformId>(
                                  device_,
                                  classId,
                                  platformId,
                                  boardCount));

    currentCommand_ = commandList_.end();
}

}  // namespace
