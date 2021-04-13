#pragma once

#include <Device/Operations/BaseDeviceOperation.h>
#include <Device/Operations/include/DeviceOperationsData.h>

namespace strata::device::command {
    class CmdSetAssistedPlatformId;
}

namespace strata::device::operation {

class SetAssistedPlatformId : public BaseDeviceOperation {

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
