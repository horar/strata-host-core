#include <Device/Operations/StartBootloader.h>
#include "Commands/include/DeviceCommands.h"
#include "DeviceOperationsConstants.h"

#include "logging/LoggingQtCategories.h"

namespace strata::device::operation {

using command::CmdRequestPlatformId;
using command::CmdGetFirmwareInfo;
using command::CmdStartBootloader;
using command::CommandResult;

StartBootloader::StartBootloader(const device::DevicePtr& device) :
    BaseDeviceOperation(device, Type::StartBootloader)
{
    // BaseDeviceOperation member device_ must be used as a parameter for commands!
    commandList_.emplace_back(std::make_unique<CmdGetFirmwareInfo>(device_, false));  // 0
    commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(device_));       // 1
    commandList_.emplace_back(std::make_unique<CmdStartBootloader>(device_));         // 2
    commandList_.emplace_back(std::make_unique<CmdGetFirmwareInfo>(device_, false));  // 3
    commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(device_));       // 4

    currentCommand_ = commandList_.end();

    // Before calling 'start_bootloader' command, we need to check if board is already
    // in bootloader mode. If so, we skip rest of commands in command list and set
    // data for 'finished' signal to ALREADY_IN_BOOTLOADER. This is done by modifications
    // in method skipCommands().
    beforeStartBootloader_ = commandList_.begin() + 1;
    postCommandHandler_ = std::bind(&StartBootloader::skipCommands, this, std::placeholders::_1, std::placeholders::_2);
}

void StartBootloader::skipCommands(CommandResult& result, int& data)
{
    if ((currentCommand_ == beforeStartBootloader_) && (result == CommandResult::Done)) {
        if (device_->property(device::DeviceProperties::verboseName) == QSTR_BOOTLOADER) {
            // skip rest of commands - set result to 'FinaliseOperation'
            result = CommandResult::FinaliseOperation;
            // set data for 'finished' signal
            data = ALREADY_IN_BOOTLOADER;
            qCInfo(logCategoryDeviceOperations) << device_ << "Platform already in bootloader mode.";
        }
    }
}

}  // namespace
