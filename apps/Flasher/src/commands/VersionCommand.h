/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#pragma once

#include "Command.h"

namespace strata::flasher::commands
{
class VersionCommand : public Command
{
    Q_OBJECT
    Q_DISABLE_COPY(VersionCommand)

public:
    VersionCommand(const QString &appName, const QString &appDescription, const QString &appVersion);
    void process() override;

private:
    const QString appName_;
    const QString appDescription_;
    const QString appVersion_;
};

}  // namespace strata::flasher::commands
