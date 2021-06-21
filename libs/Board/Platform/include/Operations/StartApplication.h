#pragma once

#include <Operations/BasePlatformOperation.h>

namespace strata::platform::operation {

class StartApplication : public BasePlatformOperation {

public:
    explicit StartApplication(const PlatformPtr& platform);
    ~StartApplication() = default;

private:
    void postCommandActions(command::CommandResult& result, int& status);
    std::vector<std::unique_ptr<command::BasePlatformCommand>>::iterator reqPlatfIdCmdIter_;
};

}  // namespace
