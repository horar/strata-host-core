#pragma once

#include <Operations/BasePlatformOperation.h>
#include <PlatformOperationsData.h>

namespace strata::platform::operation {

class SetPlatformId : public BasePlatformOperation {

public:
    SetPlatformId(
            const PlatformPtr& platform,
            const command::CmdSetPlatformIdData &data);

    ~SetPlatformId() = default;
};

}  // namespace
