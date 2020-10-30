#include <Device/Operations/SetAssistedPlatformId.h>
#include "Commands/include/DeviceCommands.h"
#include "DeviceOperationsConstants.h"


namespace strata::device::operation {

using command::CmdSetAssistedPlatformId;


SetAssistedPlatformId::SetAssistedPlatformId(
        const DevicePtr &device,
        const QString &classId,
        const QString &platformId,
        int boardCount,
        const QString &controllerClassId,
        const QString &controllerPlatformId,
        int controllerBoardCount,
        const QString fwClassId)
    : BaseDeviceOperation(device, Type::SetAssistedPlatformId)
{
    commandList_.emplace_back(std::make_unique<CmdSetAssistedPlatformId>(
                                  device_,
                                  classId,
                                  platformId,
                                  boardCount,
                                  controllerClassId,
                                  controllerPlatformId,
                                  controllerBoardCount,
                                  fwClassId));

    currentCommand_ = commandList_.end();
}

}  // namespace
