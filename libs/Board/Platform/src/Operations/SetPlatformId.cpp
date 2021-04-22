#include <Operations/SetPlatformId.h>
#include "Commands/PlatformCommands.h"

namespace strata::platform::operation {

using command::CmdSetPlatformId;
using command::CmdRequestPlatformId;

SetPlatformId::SetPlatformId(
        const PlatformPtr& platform,
        const command::CmdSetPlatformIdData &data)
    : BasePlatformOperation(platform, Type::SetPlatformId)
{
    commandList_.reserve(2);

    // BasePlatformOperation member platform_ must be used as a parameter for commands!
    commandList_.emplace_back(std::make_unique<CmdSetPlatformId>(platform_, data));
    commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(platform_));

    initCommandList();
}

}  // namespace
