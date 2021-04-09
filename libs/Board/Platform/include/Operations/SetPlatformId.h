#pragma once

#include <Operations/BasePlatformOperation.h>
#include <PlatformOperationsData.h>

namespace strata::platform::operation {

class SetPlatformId : public BasePlatformOperation {

public:
    SetPlatformId(
            const device::DevicePtr& device,
            const command::CmdSetPlatformIdData &data);

    ~SetPlatformId() = default;
};

}  // namespace
