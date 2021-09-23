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

class QSocketNotifier;


class SignalHandlers final : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SignalHandlers)

public:
    explicit SignalHandlers(QObject *parent = nullptr);
    ~SignalHandlers() = default;

    static void intSignalHandler(int);
    static void termSignalHandler(int);

public slots:
    void handleSigInt();
    void handleSigTerm();

signals:

private:
    static int sigintFd[2];
    static int sigtermFd[2];

    QSocketNotifier *snInt_;
    QSocketNotifier *snTerm_;
};
