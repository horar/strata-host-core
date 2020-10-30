#pragma once

#include <Device/Operations/BaseDeviceOperation.h>

namespace strata::device::operation {

class SetPlatformId : public BaseDeviceOperation {

public:
    explicit SetPlatformId(
            const device::DevicePtr& device,
            const QString &classId,
            const QString &platformId,
            int boardCount);

    ~SetPlatformId() = default;
};

}  // namespace
