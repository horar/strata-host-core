/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SignalHandlers.h"

#include "logging/LoggingQtCategories.h"

#include <QCoreApplication>
#include <QSocketNotifier>
#include <QDebug>

#include <unistd.h>
#include <signal.h>
#include <sys/socket.h>


int SignalHandlers::sigintFd[2] = {0, 0};
int SignalHandlers::sigtermFd[2] = {0, 0};


static bool setup_unix_signal_handlers()
{
    struct sigaction hup_sa;

    hup_sa.sa_handler = SignalHandlers::intSignalHandler;
    sigemptyset(&hup_sa.sa_mask);
    hup_sa.sa_flags = 0;
    hup_sa.sa_flags |= SA_RESTART;

    if (sigaction(SIGINT, &hup_sa, 0)) {
        qCCritical(lcHcsSignals) << "Failed to setup INT signal action";
        return false;
    }

    struct sigaction term_sa;

    term_sa.sa_handler = SignalHandlers::termSignalHandler;
    sigemptyset(&term_sa.sa_mask);
    term_sa.sa_flags = 0;
    term_sa.sa_flags |= SA_RESTART;

    if (sigaction(SIGTERM, &term_sa, 0)) {
        qCCritical(lcHcsSignals) << "Failed to setup TERM signal action";
        return false;
    }

    return true;
}


SignalHandlers::SignalHandlers(QObject *parent) : QObject(parent)
{
    if (setup_unix_signal_handlers() != true) {
        return;
    }

    if (::socketpair(AF_UNIX, SOCK_STREAM, 0, sigintFd)) {
        qCCritical(lcHcsSignals) << QStringLiteral("Couldn't create INT socketpair");
    }
    snInt_ = new QSocketNotifier(sigintFd[1], QSocketNotifier::Read, this);
    connect(snInt_, SIGNAL(activated(int)), this, SLOT(handleSigInt()));

    if (::socketpair(AF_UNIX, SOCK_STREAM, 0, sigtermFd)) {
        qCCritical(lcHcsSignals) << QStringLiteral("Couldn't create TERM socketpair");
    }
    snTerm_ = new QSocketNotifier(sigtermFd[1], QSocketNotifier::Read, this);
    connect(snTerm_, SIGNAL(activated(int)), this, SLOT(handleSigTerm()));
}

void SignalHandlers::intSignalHandler(int)
{
    char a = 1;
    ::write(sigintFd[0], &a, sizeof(a));
}

void SignalHandlers::termSignalHandler(int)
{
    char a = 1;
    ::write(sigtermFd[0], &a, sizeof(a));
}

void SignalHandlers::handleSigTerm()
{
    snTerm_->setEnabled(false);
    char tmp;
    ::read(sigtermFd[1], &tmp, sizeof(tmp));

    qCWarning(lcHcsSignals) << "SIGTERM received; quitting..";
    QCoreApplication::quit();

    snTerm_->setEnabled(true);
}

void SignalHandlers::handleSigInt()
{
    snInt_->setEnabled(false);
    char tmp;
    ::read(sigintFd[1], &tmp, sizeof(tmp));

    qCWarning(lcHcsSignals) << "SIGINT received; quitting..";
    QCoreApplication::quit();

    snInt_->setEnabled(true);
}
