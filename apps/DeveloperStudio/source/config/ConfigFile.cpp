/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "ConfigFile.h"

#include "logging/LoggingQtCategories.h"
#include <QDir>
#include <QStandardPaths>

namespace strata::sds::config
{

strata::sds::config::ConfigFile::ConfigFile(const QString &name, QObject *parent)
    : QFile(parent)
{
    #if WINDOWS_INSTALLER_BUILD
        this->setFileName(QDir(QStandardPaths::standardLocations(QStandardPaths::AppConfigLocation).at(1)).filePath("sds.config"));
    #else
        this->setFileName(name);
    #endif
}

std::tuple<QByteArray, bool> strata::sds::config::ConfigFile::loadData()
{
    qCInfo(logCategoryDevStudioConfig) << "loading configuration from" << fileName();

    QByteArray data;
    if (open(QIODevice::ReadOnly | QIODevice::Text) == false) {
        qCCritical(logCategoryDevStudioConfig) << "opening failed:" << errorString();
        return std::make_tuple(std::move(data), false);
    }

    if (size() == 0) {
        qCCritical(logCategoryDevStudioConfig) << "empty file";
        return std::make_tuple(std::move(data), false);
    }

    data = readAll();
    return std::make_tuple(std::move(data), true);
}

}  // namespace strata::sds::config
