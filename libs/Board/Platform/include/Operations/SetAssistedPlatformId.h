#pragma once

#include <Operations/BasePlatformOperation.h>
#include <PlatformOperationsData.h>

namespace strata::platform::command {
    class CmdSetAssistedPlatformId;
}

namespace strata::platform::operation {

class SetAssistedPlatformId : public BasePlatformOperation {

public:
    explicit SetAssistedPlatformId(const device::DevicePtr &device);

    ~SetAssistedPlatformId() = default;

    void setBaseData(const command::CmdSetPlatformIdData &data);
    void setControllerData(const command::CmdSetPlatformIdData &controllerData);
    void setFwClassId(const QString &fwClassId);

private:
    command::CmdSetAssistedPlatformId* cmdSetAssistPlatfId_;
};

}  // namespace
