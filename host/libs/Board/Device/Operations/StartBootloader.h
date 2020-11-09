#pragma once

#include <Device/Operations/BaseDeviceOperation.h>

namespace strata::device::operation {

class StartBootloader : public BaseDeviceOperation {

public:
    explicit StartBootloader(const device::DevicePtr& device);
    ~StartBootloader() = default;
private:
    void skipCommands(command::CommandResult& result, int& status);
    std::vector<std::unique_ptr<command::BaseDeviceCommand>>::iterator beforeStartBootloader_;
};

}  // namespace
