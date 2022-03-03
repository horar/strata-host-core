/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>

namespace strata::loggers
{
class QtLogger final : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(QtLogger)
    Q_PROPERTY(bool visualEditorReloading MEMBER visualEditorReloading NOTIFY visualEditorReloadingChanged)

    explicit QtLogger(QObject* parent = nullptr);

public:
    static QtLogger& instance();

    static void MsgHandler(QtMsgType type, const QMessageLogContext& context, const QString& msg);

private:
    static bool visualEditorReloading;

signals:
    void logMsg(QtMsgType type, const QString& msg);
    void visualEditorReloadingChanged();
};

}  // namespace strata::loggers
