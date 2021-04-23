#include <Operations/SetAssistedPlatformId.h>
#include "Commands/PlatformCommands.h"
#include "logging/LoggingQtCategories.h"

namespace strata::platform::operation {

using command::CmdSetAssistedPlatformId;
using command::CmdRequestPlatformId;

SetAssistedPlatformId::SetAssistedPlatformId(const PlatformPtr& platform)
    : BasePlatformOperation(platform, Type::SetAssistedPlatformId)
{
    commandList_.reserve(2);

    // BasePlatformOperation member platform_ must be used as a parameter for commands!

    std::unique_ptr<CmdSetAssistedPlatformId> cmdSetAssistPlatfId = std::make_unique<CmdSetAssistedPlatformId>(platform_);
    cmdSetAssistPlatfId_ = cmdSetAssistPlatfId.get();

    // special case, firmware takes too long to send ACK (see CS-1722)
    cmdSetAssistPlatfId_->setAckTimeout(std::chrono::milliseconds(2000));

    commandList_.emplace_back(std::move(cmdSetAssistPlatfId));
    commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(platform_));

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
