/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#pragma once

#include "DeviceCommand.h"

#include <Operations/Identify.h>

namespace strata::flasher::commands
{
class InfoCommand : public DeviceCommand
{
    Q_OBJECT
    Q_DISABLE_COPY(InfoCommand)

public:
    explicit InfoCommand(int deviceNumber);
    ~InfoCommand() override;
    void process() override;

private slots:
    virtual void handlePlatformOpened() override;
    void handleIdentifyOperationFinished(platform::operation::Result result, int status, QString errStr);
    void handleCriticalDeviceError();

private:
    std::unique_ptr<platform::operation::Identify> identifyOperation_;
};

}  // namespace strata::flasher::commands
