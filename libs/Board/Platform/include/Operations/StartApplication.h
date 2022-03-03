/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
