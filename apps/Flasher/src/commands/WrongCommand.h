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

namespace strata::flashercli::commands
{
class WrongCommand : public Command
{
    Q_OBJECT
    Q_DISABLE_COPY(WrongCommand)

public:
    WrongCommand(const QString &message);
    void process() override;

private:
    const QString message_;
};

}  // namespace strata::flashercli::commands
