/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#pragma once

#include "DeviceCommand.h"

namespace strata
{
class Flasher;
}

namespace strata::flashercli::commands
{
class FlasherCommand : public DeviceCommand
{
    Q_OBJECT
    Q_DISABLE_COPY(FlasherCommand)

public:
    enum class CmdType { FlashFirmware, FlashBootloader, BackupFirmware };
    FlasherCommand(const QString &fileName, int deviceNumber, CmdType command);
    ~FlasherCommand() override;
    void process() override;

private slots:
    virtual void handlePlatformOpened() override;
    void handleCriticalDeviceError();

private:
    std::unique_ptr<Flasher> flasher_;
    const QString fileName_;
    const CmdType command_;
};

}  // namespace strata::flashercli::commands
