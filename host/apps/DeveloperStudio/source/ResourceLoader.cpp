#include "ResourceLoader.h"

#include "ResourcePath.h"
#include "logging/LoggingQtCategories.h"

#include <QDirIterator>
#include <QResource>

ResourceLoader::ResourceLoader()
{
    loadCoreResources();
//    loadViewResources();
}

ResourceLoader::~ResourceLoader()
{
}

bool ResourceLoader::registerResource(const QString &fileName, const QString &root) {
    QString path = ResourcePath::viewsResourcePath() + "/" + fileName;
    qDebug(logCategoryResourceLoader) << "Registering resource: " << path;
    return QResource::registerResource(path, root);
}

bool ResourceLoader::unregisterResource(const QString &fileName, const QString &root) {
    QString path = ResourcePath::viewsResourcePath() + "/" + fileName;
    qDebug(logCategoryResourceLoader) << "Unregistering resource: " << path;
    return QResource::unregisterResource(path, root);
}

void ResourceLoader::loadCoreResources()
{
    for (const auto& resourceName : coreResources_) {
        const QString resourceFile(
            QString("%1/%2").arg(ResourcePath::coreResourcePath()).arg(resourceName));

        if (QFile::exists(resourceFile) == false) {
            qCCritical(logCategoryStrataDevStudio(), "Missing '%s' resource file!!",
                       qUtf8Printable(resourceName));
            continue;
        }
        qCDebug(logCategoryStrataDevStudio(), "Loading '%s: %d': ", qUtf8Printable(resourceFile),
                QResource::registerResource(resourceFile));
    }
}

void ResourceLoader::loadViewResources()
{
    QDirIterator it(ResourcePath::viewsResourcePath(), {QStringLiteral("views-*.rcc")},
                    QDir::Files);
    while (it.hasNext()) {
        const QString resourceFile(it.next());
        qCDebug(logCategoryStrataDevStudio(), "Loading '%s: %d': ", qUtf8Printable(resourceFile),
                QResource::registerResource(resourceFile));
    }
}
