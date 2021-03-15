#include <Device/Operations/SetAssistedPlatformId.h>
#include "Commands/include/DeviceCommands.h"
#include "DeviceOperationsConstants.h"
#include "logging/LoggingQtCategories.h"


namespace strata::device::operation {

using command::CmdSetAssistedPlatformId;
using command::CmdRequestPlatformId;

SetAssistedPlatformId::SetAssistedPlatformId(const DevicePtr &device)
    : BaseDeviceOperation(device, Type::SetAssistedPlatformId)
{
    commandList_.reserve(2);

    // BaseDeviceOperation member device_ must be used as a parameter for commands!

    std::unique_ptr<CmdSetAssistedPlatformId> cmdSetAssistPlatfId = std::make_unique<CmdSetAssistedPlatformId>(device_);
    cmdSetAssistPlatfid_ = cmdSetAssistPlatfId.get();

    commandList_.emplace_back(std::move(cmdSetAssistPlatfId));
    commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(device_));

    currentCommand_ = commandList_.end();
}

void SetAssistedPlatformId::setBaseData(const command::CmdSetPlatformIdData &data)
{
    cmdSetAssistPlatfid_->setBaseData(data);
}

void SetAssistedPlatformId::setControllerData(const command::CmdSetPlatformIdData &controllerData)
{
    cmdSetAssistPlatfid_->setControllerData(controllerData);
}

void SetAssistedPlatformId::setFwClassId(const QString &fwClassId)
{
    cmdSetAssistPlatfid_->setFwClassId(fwClassId);
}

}  // namespace
