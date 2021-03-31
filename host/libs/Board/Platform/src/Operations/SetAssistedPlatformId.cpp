#include <Operations/SetAssistedPlatformId.h>
#include "Commands/PlatformCommands.h"
#include "PlatformOperationsConstants.h"
#include "logging/LoggingQtCategories.h"


namespace strata::platform::operation {

using command::CmdSetAssistedPlatformId;
using command::CmdRequestPlatformId;

SetAssistedPlatformId::SetAssistedPlatformId(const device::DevicePtr &device)
    : BasePlatformOperation(device, Type::SetAssistedPlatformId)
{
    commandList_.reserve(2);

    // BasePlatformOperation member device_ must be used as a parameter for commands!

    std::unique_ptr<CmdSetAssistedPlatformId> cmdSetAssistPlatfId = std::make_unique<CmdSetAssistedPlatformId>(device_);
    cmdSetAssistPlatfid_ = cmdSetAssistPlatfId.get();

    cmdSetAssistPlatfid_->setResponseTimeout(std::chrono::milliseconds(2000));

    commandList_.emplace_back(std::move(cmdSetAssistPlatfId));
    commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(device_));

    initCommandList();
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
