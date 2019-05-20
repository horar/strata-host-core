#include "ResourcePath.h"

#include "logging/LoggingQtCategories.h"

#include <QCoreApplication>
#include <QDir>

QString ResourcePath::viewsResourcePath_ = QString();

ResourcePath::ResourcePath()
{
}

QString &ResourcePath::viewsResourcePath()
{
    if (viewsResourcePath_.isEmpty()) {
#ifdef Q_OS_MACOS
        QDir applicationDir(QCoreApplication::applicationDirPath());
        applicationDir.cdUp();
        applicationDir.cdUp();
        applicationDir.cdUp();

        viewsResourcePath_ = applicationDir.path();
#else
        viewsResourcePath_ = QCoreApplication::applicationDirPath();
#endif
        qCDebug(logCategoryStrataDevStudio(), "'Strata views' path: '%s'",
                qUtf8Printable(viewsResourcePath_));
    }

    return viewsResourcePath_;
}
