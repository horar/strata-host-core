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

StartBootloader::StartBootloader(const device::DevicePtr& device) :
    BasePlatformOperation(device, Type::StartBootloader)
{
    commandList_.reserve(6);

    // BasePlatformOperation member device_ must be used as a parameter for commands!

    // Legacy note related to EFM boards:
    // Bootloader takes 5 seconds to start (known issue related to clock source).
    // Platform and bootloader uses the same setting for clock source.
    // Clock source for bootloader and application must match. Otherwise when application
    // jumps to bootloader, it will have a hardware fault which requires board to be reset.
    std::unique_ptr<CmdWait> cmdWait = std::make_unique<CmdWait>(
                device_,
                BOOTLOADER_5_SEC_BOOT_TIME,
                QStringLiteral("Waiting for bootloader to start"));
    cmdWait_ = cmdWait.get();

    commandList_.emplace_back(std::make_unique<CmdGetFirmwareInfo>(device_, true, MAX_GET_FW_INFO_RETRIES)); // 0
    commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(device_));      // 1
    commandList_.emplace_back(std::make_unique<CmdStartBootloader>(device_));        // 2
    commandList_.emplace_back(std::move(cmdWait));                                   // 3
    commandList_.emplace_back(std::make_unique<CmdGetFirmwareInfo>(device_, true));  // 4
    commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(device_));      // 5

    initCommandList();

    // Before calling 'start_bootloader' command, we need to check if board is already
    // in bootloader mode. If so, we skip rest of commands in command list and set
    // data for 'finished' signal to ALREADY_IN_BOOTLOADER. This is done by modifications
    // in method skipCommands().
    beforeStartBootloader_ = commandList_.begin() + 1;
    postCommandHandler_ = std::bind(&StartBootloader::skipCommands, this, std::placeholders::_1, std::placeholders::_2);
}

void StartBootloader::setWaitTime(const std::chrono::milliseconds& waitTime)
{
    cmdWait_->setWaitTime(waitTime);
}

void StartBootloader::skipCommands(CommandResult& result, int& status)
{
    if ((currentCommand_ == beforeStartBootloader_) && (result == CommandResult::Done)) {
        if (BasePlatformOperation::bootloaderMode() == true) {
            // skip rest of commands - set result to 'FinaliseOperation'
            result = CommandResult::FinaliseOperation;
            // set status for 'finished' signal
            status = ALREADY_IN_BOOTLOADER;
            qCInfo(logCategoryPlatformOperation) << device_ << "Platform already in bootloader mode.";
        }
    }
}

}  // namespace
