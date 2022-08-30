/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "WgModel.h"
#include "logging/LoggingQtCategories.h"

WgModel::WgModel(QObject *parent) : QObject(parent)
{
}

WgModel::~WgModel()
{
}

void WgModel::handleQmlWarning(const QList<QQmlError> &warnings)
{
    QStringList msg;
    foreach (const QQmlError &error, warnings) {
        msg << error.toString();
    }
    emit notifyQmlError(msg.join(QStringLiteral("\n")));
}
