/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#pragma once

#include "Command.h"

#include <Platform.h>

namespace strata::flashercli::commands
{
class DeviceCommand : public Command
{
    Q_OBJECT
    Q_DISABLE_COPY(DeviceCommand)

public:
    explicit DeviceCommand(int deviceNumber);
    virtual ~DeviceCommand() override;

signals:
    void criticalDeviceError();

protected slots:
    virtual void handlePlatformOpened() = 0;
    void handleDeviceError(device::Device::ErrorCode errCode, QString errStr);

protected:
    bool createSerialDevice();

    const int deviceNumber_;
    unsigned int openCount_;
    platform::PlatformPtr platform_;
};

}  // namespace strata::flashercli::commands
