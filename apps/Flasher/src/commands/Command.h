/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#pragma once

#include <QObject>

namespace strata::flashercli::commands
{
class Command : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(Command)

public:
    Command() = default;
    virtual ~Command() = default;
    virtual void process() = 0;

signals:
    void finished(int returnCode);
};

}  // namespace strata::flashercli::commands
