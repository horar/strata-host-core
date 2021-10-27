/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "LcuModel.h"
#include "logging/LoggingQtCategories.h"

#include <QCoreApplication>
#include <QStandardPaths>
#include <QSettings>
#include <QDirIterator>

LcuModel::LcuModel(QObject *parent)
    : QObject(parent)
{

}
LcuModel::~LcuModel()
{

}
void LcuModel::configFileSelectionChanged(QString fileName)
{
    qCInfo(logCategoryLoggingConfigurationUtility()) << "Selected INI file changed to: " << fileName;
}
void LcuModel::reload()
{
    qCInfo(logCategoryLoggingConfigurationUtility()) << "Reload button clicked ";
}
QStringList LcuModel::getIniFiles()
{
    QStringList iniFiles;
    QString path = QStandardPaths::standardLocations(QStandardPaths::HomeLocation).at(0) + "/strata-root/strata-host-core-internal/assets/config";
    //QString standardPath = QStandardPaths::standardLocations(QStandardPaths::AppConfigLocation).at(0);
    //this locations doesnt work, it gives me following path: /User/Library/Preferences/onsemi/Logging Configuration Utility

    QDirIterator it(path, {"*.ini","*.config"}, QDir::Files, QDirIterator::Subdirectories);
    while (it.hasNext()){
        iniFiles << it.next().remove(0, path.count());
    }
    if (iniFiles.empty())
        qCInfo(logCategoryLoggingConfigurationUtility()) << "No ini files were found";
    // To do : disable combo box

    for(int i=0; i < iniFiles.count(); i++){
        iniFiles.at(i);
    }
    return iniFiles;
}
