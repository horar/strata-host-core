/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#include "ListCommand.h"
#include "SerialPortList.h"

#include "logging/LoggingQtCategories.h"

namespace strata::flashercli::commands
{
ListCommand::ListCommand()
{
}

void ListCommand::process()
{
    flashercli::SerialPortList serialPorts;
    auto const portList = serialPorts.list();
    QString message(QStringLiteral("List of available boards (serial devices):"));
    if (portList.isEmpty()) {
        message.append(QStringLiteral("\nNo board is conected."));
    } else {
        for (int i = 0; i < portList.size(); ++i) {
            message.append('\n');
            message.append(QString::number(i + 1));
            message.append(QStringLiteral(". "));
            message.append(portList.at(i));
        }
    }
    qCInfo(lcFlasherCli).noquote() << message;
    emit finished(EXIT_SUCCESS);
}

}  // namespace strata::flashercli::commands
