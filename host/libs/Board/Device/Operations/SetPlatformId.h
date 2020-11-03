#pragma once

#include <Device/Operations/BaseDeviceOperation.h>
#include <DeviceOperationsData.h>

namespace strata::device::operation {

class SetPlatformId : public BaseDeviceOperation {

public:
    SetPlatformId(
            const device::DevicePtr& device,
            const command::CmdSetPlatformIdData &data);

    ~SetPlatformId() = default;
};

}  // namespace
