#include "ResourcePath.h"

#include "logging/LoggingQtCategories.h"

#include <QCoreApplication>
#include <QDir>

QString ResourcePath::coreResourcePath_ = QString();
QString ResourcePath::viewsResourcePath_ = QString();
QString ResourcePath::viewsPhysicalPath_ = QString();

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

QString &ResourcePath::viewsPhysicalPath()
{
    QDir* dir;
    if(viewsPhysicalPath_.isEmpty()) {
        dir = new QDir(coreResourcePath());
        dir->cdUp();
        dir->cdUp();
        dir->cd("host");
        dir->cd("components");
        dir->cd("views");
        viewsPhysicalPath_ = dir->absolutePath();
        qDebug() << viewsPhysicalPath_;
    }

    return viewsPhysicalPath_;
}
