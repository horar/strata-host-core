/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "ResourcePath.h"

#include "logging/LoggingQtCategories.h"

#include <QCoreApplication>
#include <QDir>

QString ResourcePath::coreResourcePath_ = QString();
QString ResourcePath::viewsResourcePath_ = QString();

QString &ResourcePath::coreResourcePath()
{
    if (coreResourcePath_.isEmpty()) {
#ifdef Q_OS_MACOS
        QDir applicationDir(QCoreApplication::applicationDirPath());
        applicationDir.cdUp();
        applicationDir.cdUp();
        applicationDir.cdUp();

        coreResourcePath_ = applicationDir.path();
#else
        coreResourcePath_ = QCoreApplication::applicationDirPath();
#endif
        qCDebug(logCategoryDevStudio(), "app core resources path: '%s'",
                qUtf8Printable(coreResourcePath_));
    }

    return coreResourcePath_;
}

QString &ResourcePath::viewsResourcePath()
{
    if (viewsResourcePath_.isEmpty()) {
        viewsResourcePath_ = QStringLiteral("%1/views").arg(coreResourcePath());
        qCDebug(logCategoryDevStudio(), "app views resources path: '%s'",
                qUtf8Printable(viewsResourcePath_));
    }

    return viewsResourcePath_;
}
