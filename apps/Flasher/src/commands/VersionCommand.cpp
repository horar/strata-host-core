/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "VersionCommand.h"

#include "logging/LoggingQtCategories.h"

namespace strata::flashercli::commands
{
VersionCommand::VersionCommand(const QString &appName, const QString &appDescription, const QString &appVersion)
    : appName_(appName), appDescription_(appDescription), appVersion_(appVersion)
{
}

void VersionCommand::process()
{
    qCInfo(lcFlasherCli).noquote().nospace() << appName_ << " (" << appDescription_ << ") " << appVersion_;
    emit finished(EXIT_SUCCESS);
}

}  // namespace strata::flashercli::commands
