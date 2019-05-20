#include "ResourcePath.h"

#include "logging/LoggingQtCategories.h"

#include <QStandardPaths>

QString ResourcePath::viewsResourcePath_ = QString();

ResourcePath::ResourcePath()
{
}

QString &ResourcePath::viewsResourcePath()
{
    if (viewsResourcePath_.isEmpty()) {
        viewsResourcePath_ =
            QStandardPaths::standardLocations(QStandardPaths::AppDataLocation).at(0);
        qCDebug(logCategoryStrataDevStudio(), "'Strata views' path: '%s'",
                qUtf8Printable(viewsResourcePath_));
    }

    return viewsResourcePath_;
}
