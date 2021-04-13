#pragma once

#include <Operations/BasePlatformOperation.h>

namespace strata::platform::operation {

class StartApplication : public BasePlatformOperation {

public:
    explicit StartApplication(const PlatformPtr& platform);
    ~StartApplication() = default;
};

}  // namespace
