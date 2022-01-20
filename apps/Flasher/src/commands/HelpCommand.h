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
class HelpCommand : public Command
{
    Q_OBJECT
    Q_DISABLE_COPY(HelpCommand)

public:
    HelpCommand(const QString &helpText);
    void process() override;

private:
    const QString helpText_;
};

}  // namespace strata::flashercli::commands
