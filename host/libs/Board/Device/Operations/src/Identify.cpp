#include <Device/Operations/Identify.h>
#include "Commands/include/DeviceCommands.h"

#include <QTimer>

namespace strata::device::operation {

using command::CmdGetFirmwareInfo;
using command::CmdRequestPlatformId;

Identify::Identify(const device::DevicePtr& device, bool requireFwInfoResponse, uint maxFwInfoRetries) :
    BaseDeviceOperation(device, Type::Identify)
{
    // BaseDeviceOperation member device_ must be used as a parameter for commands!
    commandList_.emplace_back(std::make_unique<CmdGetFirmwareInfo>(device_, requireFwInfoResponse, maxFwInfoRetries));
    commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(device_));

    currentCommand_ = commandList_.end();
}

void Identify::runWithDelay(std::chrono::milliseconds delay)
{
    QTimer::singleShot(delay, this, [this](){ BaseDeviceOperation::run(); });
}

}  // namespace
