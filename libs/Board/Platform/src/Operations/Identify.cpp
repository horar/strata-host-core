#include <Operations/Identify.h>
#include "Commands/PlatformCommands.h"

#include <QTimer>

namespace strata::platform::operation {

using command::CmdGetFirmwareInfo;
using command::CmdRequestPlatformId;
using command::CmdWait;

Identify::Identify(const PlatformPtr& platform,
                   bool requireFwInfoResponse,
                   uint maxFwInfoRetries,
                   std::chrono::milliseconds delay)
    : BasePlatformOperation(platform, Type::Identify)
{
    commandList_.reserve(3);

    // BasePlatformOperation member platform_ must be used as a parameter for commands!
    if (delay > std::chrono::milliseconds(0)) {
        commandList_.emplace_back(std::make_unique<CmdWait>(platform_, delay, QStringLiteral("Waiting for board to boot")));
    }
    commandList_.emplace_back(std::make_unique<CmdGetFirmwareInfo>(platform_, requireFwInfoResponse, maxFwInfoRetries));
    commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(platform_));

    initCommandList();
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

void Identify::performPostOperationActions(Result result) {
    // do not emit recognized signal if operation was cancelled
    if (result != Result::Cancel) {
        platform_->identifyFinished(result == Result::Success);
    }
}

}  // namespace
