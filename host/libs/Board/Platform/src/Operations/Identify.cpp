#include <Operations/Identify.h>
#include "Commands/PlatformCommands.h"

#include <QTimer>

namespace strata::platform::operation {

using command::CmdGetFirmwareInfo;
using command::CmdRequestPlatformId;
using command::CmdWait;

Identify::Identify(const device::DevicePtr& device,
                   bool requireFwInfoResponse,
                   uint maxFwInfoRetries,
                   std::chrono::milliseconds delay)
    : BasePlatformOperation(device, Type::Identify)
{
    commandList_.reserve(3);

    // BasePlatformOperation member device_ must be used as a parameter for commands!
    commandList_.emplace_back(std::make_unique<CmdWait>(device_, delay, QStringLiteral("Waiting for board to boot.")));
    commandList_.emplace_back(std::make_unique<CmdGetFirmwareInfo>(device_, requireFwInfoResponse, maxFwInfoRetries));
    commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(device_));

    currentCommand_ = commandList_.end();
}

Identify::BoardMode Identify::boardMode()
{
    if (BasePlatformOperation::isSuccessfullyFinished()) {
        if (BasePlatformOperation::bootloaderMode()) {
            return BoardMode::Bootloader;
        } else {
            return BoardMode::Application;
        }
    }

    return BoardMode::Unknown;
}

}  // namespace
