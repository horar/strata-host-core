#pragma once

#include <Operations/BasePlatformOperation.h>
#include <PlatformOperationsData.h>

namespace strata::device::operation {

class SetPlatformId : public BaseDeviceOperation {

public:
    SetPlatformId(
            const device::DevicePtr& device,
            const command::CmdSetPlatformIdData &data);

    ~SetPlatformId() = default;
};

}  // namespace
