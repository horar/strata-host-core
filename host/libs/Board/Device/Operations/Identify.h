#pragma once

#include <chrono>

#include <Device/Operations/BaseDeviceOperation.h>

namespace strata::device::operation {

class Identify : public BaseDeviceOperation {

public:
    Identify(const device::DevicePtr& device, bool requireFwInfoResponse);
    ~Identify() = default;
    void runWithDelay(std::chrono::milliseconds delay);
};

}  // namespace
