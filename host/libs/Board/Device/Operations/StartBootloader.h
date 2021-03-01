#pragma once

#include <chrono>

#include <Device/Operations/BaseDeviceOperation.h>

namespace strata::device::command {
    class CmdWait;
}

namespace strata::device::operation {

class StartBootloader : public BaseDeviceOperation {

public:
    explicit StartBootloader(const device::DevicePtr& device);
    ~StartBootloader() = default;

    /*! Set wait time for bootloader to start.
     * \param waitTime time in milliseconds
     */
    void setWaitTime(const std::chrono::milliseconds& waitTime);

private:
    void skipCommands(command::CommandResult& result, int& status);
    std::vector<std::unique_ptr<command::BaseDeviceCommand>>::iterator beforeStartBootloader_;
    command::CmdWait* cmdWait_;
};

}  // namespace
