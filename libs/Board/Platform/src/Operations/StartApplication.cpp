/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <Operations/StartApplication.h>
#include <PlatformOperationsStatus.h>
#include "Commands/PlatformCommands.h"
#include "PlatformOperationsConstants.h"

namespace strata::platform::operation {

using command::CmdStartApplication;
using command::CmdRequestPlatformId;
using command::CmdGetFirmwareInfo;
using command::CommandResult;

StartApplication::StartApplication(const PlatformPtr& platform) :
    BasePlatformOperation(platform, Type::StartApplication)
{
    commandList_.reserve(3);

    // BasePlatformOperation member platform_ must be used as a parameter for commands!
    commandList_.emplace_back(std::make_unique<CmdStartApplication>(platform_));                                // 0
    commandList_.emplace_back(std::make_unique<CmdGetFirmwareInfo>(platform_, true, MAX_GET_FW_INFO_RETRIES));  // 1
    commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(platform_));                               // 2

    initCommandList();

    // After calling 'request_platform_id' command, we need to check if board
    // is already in application mode. If no, we set data for 'finished' signal
    // to 'FIRMWARE_UNABLE_START' in method 'postCommandActions()'.
    reqPlatfIdCmdIter_ = commandList_.begin() + 2;
    postCommandHandler_ = std::bind(&StartApplication::postCommandActions, this, std::placeholders::_1, std::placeholders::_2);
}

void StartApplication::postCommandActions(CommandResult& result, int& status)
{
    Q_UNUSED(result)

    if (currentCommand_ == reqPlatfIdCmdIter_) {
        if (BasePlatformOperation::bootloaderMode() == true) {
            // set status for 'finished' signal
            status = FIRMWARE_UNABLE_TO_START;
        }
    }
}

}  // namespace
