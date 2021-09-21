/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <Operations/StartBootloader.h>
#include <PlatformOperationsStatus.h>
#include "Commands/PlatformCommands.h"
#include "PlatformOperationsConstants.h"

#include "logging/LoggingQtCategories.h"

namespace strata::platform::operation {

using command::CmdRequestPlatformId;
using command::CmdGetFirmwareInfo;
using command::CmdStartBootloader;
using command::CmdWait;
using command::CommandResult;

StartBootloader::StartBootloader(const PlatformPtr& platform) :
    BasePlatformOperation(platform, Type::StartBootloader)
{
    commandList_.reserve(6);
    std::chrono::milliseconds bootingDelay = (platform_->deviceType() == device::Device::Type::MockDevice) ? BOOTLOADER_MOCK_BOOT_TIME : BOOTLOADER_BOOT_TIME;

    // BasePlatformOperation member platform_ must be used as a parameter for commands!

    // Legacy note related to EFM boards:
    // Bootloader takes 5 seconds to start (known issue related to clock source).
    // Platform and bootloader uses the same setting for clock source.
    // Clock source for bootloader and application must match. Otherwise when application
    // jumps to bootloader, it will have a hardware fault which requires board to be reset.
    std::unique_ptr<CmdWait> cmdWait = std::make_unique<CmdWait>(
                platform_,
                bootingDelay,
                QStringLiteral("Waiting for bootloader to start"));
    cmdWait_ = cmdWait.get();

    commandList_.emplace_back(std::make_unique<CmdGetFirmwareInfo>(platform_, true, MAX_GET_FW_INFO_RETRIES)); // 0
    commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(platform_));      // 1
    commandList_.emplace_back(std::make_unique<CmdStartBootloader>(platform_));        // 2
    commandList_.emplace_back(std::move(cmdWait));                                     // 3
    commandList_.emplace_back(std::make_unique<CmdGetFirmwareInfo>(platform_, true));  // 4
    commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(platform_));      // 5

    initCommandList();

    // Before calling 'start_bootloader' command, we need to check if board is already
    // in bootloader mode. If so, we skip rest of commands in command list and set
    // data for 'finished' signal to ALREADY_IN_BOOTLOADER. This is done by modifications
    // in method postCommandActions().
    firstReqPlatfIdIter_ = commandList_.begin() + 1;
    waitCmdIter_ = commandList_.begin() + 3;
    postCommandHandler_ = std::bind(&StartBootloader::postCommandActions, this, std::placeholders::_1, std::placeholders::_2);
}

void StartBootloader::setWaitTime(const std::chrono::milliseconds& waitTime)
{
    cmdWait_->setWaitTime(waitTime);
}

void StartBootloader::postCommandActions(CommandResult& result, int& status)
{
    if ((currentCommand_ == firstReqPlatfIdIter_) && (result == CommandResult::Done)) {
        if (BasePlatformOperation::bootloaderMode() == true) {
            // skip rest of commands - set result to 'FinaliseOperation'
            result = CommandResult::FinaliseOperation;
            // set status for 'finished' signal
            status = ALREADY_IN_BOOTLOADER;
            qCInfo(logCategoryPlatformOperation) << platform_ << "Platform already in bootloader mode.";
        }
        return;
    }

    if (currentCommand_ == waitCmdIter_) {
        // platform could send part of message before rebooting,
        // so reset receiving to drop possible incomplete message
        platform_->resetReceiving();
    }
}

}  // namespace
