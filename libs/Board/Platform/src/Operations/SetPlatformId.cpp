/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
