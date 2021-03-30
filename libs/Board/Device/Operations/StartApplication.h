#pragma once

#include <Device/Operations/BaseDeviceOperation.h>

namespace strata::device::operation {

class StartApplication : public BaseDeviceOperation {

public:
    explicit StartApplication(const device::DevicePtr& device);
    ~StartApplication() = default;
};

}  // namespace
