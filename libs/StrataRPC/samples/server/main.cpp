/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "Server.h"

#include <QtLoggerSetup.h>
#include <QCoreApplication>
#include <QSettings>
#include <QtCore>

int main(int argc, char* argv[])
{
    QCoreApplication::setApplicationName(QStringLiteral("strataRPC Server Sample"));
    QCoreApplication::setOrganizationName(QStringLiteral("onsemi"));
    QCoreApplication theApp(argc, argv);

    QSettings::setDefaultFormat(QSettings::IniFormat);

    const strata::loggers::QtLoggerSetup loggerInitialization(theApp);

    std::shared_ptr<Server> server_(new Server);
    QObject::connect(server_.get(), &Server::appDone, &theApp, &QCoreApplication::exit);

    server_->init();
    server_->start();

    return theApp.exec();
}
