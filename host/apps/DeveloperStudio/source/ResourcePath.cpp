#include "ResourcePath.h"

#include "logging/LoggingQtCategories.h"

#include <QCoreApplication>
#include <QDir>

QString ResourcePath::coreResourcePath_ = QString();
QString ResourcePath::viewsPhysicalPath_ = QString();

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

QString &ResourcePath::viewsPhysicalPath()
{
    if (viewsResourcePath_.isEmpty()) {
        viewsResourcePath_ = QStringLiteral("%1/views").arg(coreResourcePath());
        qCDebug(logCategoryStrataDevStudio(), "app views resources path: '%s'",
                qUtf8Printable(viewsResourcePath_));
    }

    return viewsPhysicalPath_;
}
