#include <Operations/StartApplication.h>
#include "Commands/PlatformCommands.h"
#include "PlatformOperationsConstants.h"

namespace strata::platform::operation {

using command::CmdStartApplication;
using command::CmdRequestPlatformId;
using command::CmdGetFirmwareInfo;

StartApplication::StartApplication(const PlatformPtr& platform) :
    BasePlatformOperation(platform, Type::StartApplication)
{
    commandList_.reserve(3);

    // BasePlatformOperation member platform_ must be used as a parameter for commands!
    commandList_.emplace_back(std::make_unique<CmdStartApplication>(platform_));
    commandList_.emplace_back(std::make_unique<CmdGetFirmwareInfo>(platform_, true, MAX_GET_FW_INFO_RETRIES));
    commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(platform_));

    initCommandList();
}

}  // namespace
