#include "ResourcePath.h"

#include "logging/LoggingQtCategories.h"

#include <QCoreApplication>
#include <QDir>
#include <QStandardPaths>

QString ResourcePath::coreResourcePath_ = QString();
QString ResourcePath::viewsResourcePath_ = QString();

ResourcePath::ResourcePath()
{
}

QString &ResourcePath::coreResourcePath()
{
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

    return coreResourcePath_;
}

QString &ResourcePath::viewsResourcePath()
{
    if (viewsResourcePath_.isEmpty()) {
        QDir applicationDir(QCoreApplication::applicationDirPath());
        applicationDir.cd(QStringLiteral("views"));
        viewsResourcePath_ = applicationDir.path();
        qCDebug(logCategoryStrataDevStudio(), "app views resources path: '%s'",
                qUtf8Printable(viewsResourcePath_));
    }

    return viewsResourcePath_;
}
