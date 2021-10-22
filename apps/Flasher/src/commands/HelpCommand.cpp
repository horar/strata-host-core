/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#include "HelpCommand.h"
#include "logging/LoggingQtCategories.h"

#include <cstdlib>

namespace strata::flashercli::commands
{
HelpCommand::HelpCommand(const QString& helpText) : helpText_(helpText)
{
}

void HelpCommand::process()
{
    qCInfo(logCategoryFlasherCli).noquote() << helpText_;
    emit finished(EXIT_SUCCESS);
}

}  // namespace strata::flashercli::commands
