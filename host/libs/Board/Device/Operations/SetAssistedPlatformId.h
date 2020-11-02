#pragma once

#include <Device/Operations/BaseDeviceOperation.h>
#include <DeviceOperationsData.h>

namespace strata::device::operation {

class SetAssistedPlatformId : public BaseDeviceOperation {

public:
    explicit SetAssistedPlatformId(
            const device::DevicePtr &device,
            const command::CmdSetAssistedPlatformIdData &data);

    ~SetAssistedPlatformId() = default;
};

}  // namespace
