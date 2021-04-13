#pragma once

#include <chrono>

#include <Operations/BasePlatformOperation.h>

namespace strata::platform::command {
    class CmdWait;
}

namespace strata::platform::operation {

class StartBootloader : public BasePlatformOperation {

public:
    explicit StartBootloader(const PlatformPtr& platform);
    ~StartBootloader() = default;

    /*! Set wait time for bootloader to start.
     * \param waitTime time in milliseconds
     */
    void setWaitTime(const std::chrono::milliseconds& waitTime);

private:
    void skipCommands(command::CommandResult& result, int& status);
    std::vector<std::unique_ptr<command::BasePlatformCommand>>::iterator beforeStartBootloader_;
    command::CmdWait* cmdWait_;
};

}  // namespace
