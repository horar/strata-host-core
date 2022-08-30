/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <chrono>

#include "BasePlatformCommand.h"

namespace strata::platform::command {

// This is special command used for waiting between commands in command list.
// This command has also its own implementation of sendCommand method.

class CmdWait : public BasePlatformCommand
{
public:
    CmdWait(const PlatformPtr& platform,
            std::chrono::milliseconds waitTime,
            const QString& description);

    void sendCommand(quintptr lockId) override;
    QByteArray message() override;
    bool processNotification(const rapidjson::Document& doc, CommandResult& result) override;
    CommandResult onTimeout() override;

    void setWaitTime(std::chrono::milliseconds waitTime);

private slots:
    void deviceErrorOccured(device::Device::ErrorCode errCode, QString errStr);

private:
    std::chrono::milliseconds waitTime_;
    const QString description_;
};

}  // namespace
