/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
    void postCommandActions(command::CommandResult& result, int& status);
    std::vector<std::unique_ptr<command::BasePlatformCommand>>::iterator firstReqPlatfIdIter_;
    std::vector<std::unique_ptr<command::BasePlatformCommand>>::iterator waitCmdIter_;
    command::CmdWait* cmdWait_;
};

}  // namespace
