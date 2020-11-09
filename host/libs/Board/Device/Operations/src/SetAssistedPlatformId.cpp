#include <Device/Operations/SetAssistedPlatformId.h>
#include "Commands/include/DeviceCommands.h"
#include "DeviceOperationsConstants.h"
#include "logging/LoggingQtCategories.h"


namespace strata::device::operation {

using command::CmdSetAssistedPlatformId;

SetAssistedPlatformId::SetAssistedPlatformId(const DevicePtr &device)
    : BaseDeviceOperation(device, Type::SetAssistedPlatformId)
{
    commandList_.emplace_back(std::make_unique<CmdSetAssistedPlatformId>(device_));

    currentCommand_ = commandList_.end();
}

void SetAssistedPlatformId::setBaseData(const command::CmdSetPlatformIdData &data)
{
    CmdSetAssistedPlatformId *cmd =  dynamic_cast<CmdSetAssistedPlatformId*>(commandList_.front().get());
    if (cmd == nullptr) {
        qCCritical(logCategoryDeviceOperations()) << "cannot cast CmdSetAssistedPlatformId";
        return;
    }

    cmd->setBaseData(data);
}

void SetAssistedPlatformId::setControllerData(const command::CmdSetPlatformIdData &controllerData)
{
    CmdSetAssistedPlatformId *cmd =  dynamic_cast<CmdSetAssistedPlatformId*>(commandList_.front().get());
    if (cmd == nullptr) {
        qCCritical(logCategoryDeviceOperations()) << "cannot cast CmdSetAssistedPlatformId";
        return;
    }

    cmd->setControllerData(controllerData);
}

void SetAssistedPlatformId::setFwClassId(const QString &fwClassId)
{
    CmdSetAssistedPlatformId *cmd =  dynamic_cast<CmdSetAssistedPlatformId*>(commandList_.front().get());
    if (cmd == nullptr) {
        qCCritical(logCategoryDeviceOperations()) << "cannot cast CmdSetAssistedPlatformId";
        return;
    }

    cmd->setFwClassId(fwClassId);
}

}  // namespace
