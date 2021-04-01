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
    cmdSetAssistPlatfId_ = cmdSetAssistPlatfId.get();

    // special case, firmware takes too long to send ACK (see CS-1722)
    cmdSetAssistPlatfId_->setAckTimeout(std::chrono::milliseconds(2000));

    commandList_.emplace_back(std::move(cmdSetAssistPlatfId));
    commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(device_));

    initCommandList();
}

void SetAssistedPlatformId::setBaseData(const command::CmdSetPlatformIdData &data)
{
    cmdSetAssistPlatfId_->setBaseData(data);
}

void SetAssistedPlatformId::setControllerData(const command::CmdSetPlatformIdData &controllerData)
{
    cmdSetAssistPlatfId_->setControllerData(controllerData);
}

void SetAssistedPlatformId::setFwClassId(const QString &fwClassId)
{
    cmdSetAssistPlatfId_->setFwClassId(fwClassId);
}

}  // namespace
