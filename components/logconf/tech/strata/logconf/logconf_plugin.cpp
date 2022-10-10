/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "logconf_plugin.h"
#include "ConfigFileSettings.h"
#include "LogFilesCompress.h"
#include "QtFilterRulesModel.h"

#include <QtQml>

void LogConfPlugin::registerTypes(const char *uri){
    qmlRegisterModule(uri, 1, 0);
    qmlRegisterType<ConfigFileSettings>("tech.strata.logconf", 1, 0, "ConfigFileSettings");
    qmlRegisterType<LogFilesCompress>("tech.strata.logconf", 1, 0, "LogFilesCompress");
    qmlRegisterType<QtFilterRulesModel>("tech.strata.logconf", 1, 0, "QtFilterRulesModel");
}
