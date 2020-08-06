#include "ResourcePath.h"

#include "logging/LoggingQtCategories.h"

#include <QCoreApplication>
#include <QDir>
#include <QStandardPaths>

QString ResourcePath::coreResourcePath_ = QString();
QString ResourcePath::viewsResourcePath_ = QString();
QString ResourcePath::hcsDocumentsCachePath_ = QString();

ResourcePath::ResourcePath()
{
}

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
        qCDebug(logCategoryStrataDevStudio(), "app core resources path: '%s'",
                qUtf8Printable(coreResourcePath_));
    }

    return coreResourcePath_;
}

QString &ResourcePath::viewsResourcePath()
{
    if (viewsResourcePath_.isEmpty()) {
        viewsResourcePath_ = coreResourcePath();
        qCDebug(logCategoryStrataDevStudio(), "app views resources path: '%s'",
                qUtf8Printable(viewsResourcePath_));
    }

    return viewsResourcePath_;
}

QString &ResourcePath::hcsDocumentsCachePath()
{
    if (hcsDocumentsCachePath_.isEmpty()) {
        QDir documentsDir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));

        // Go up to ON Semiconductor Dir
        documentsDir.cdUp();

        // Go to HCS Dir
        documentsDir.cd("Host Controller Service");

        // Go to documents dir
        documentsDir.cd("documents");

        hcsDocumentsCachePath_ = documentsDir.path();
    }
    return hcsDocumentsCachePath_;
}
