#include "ResourceLoader.h"

#include "ResourcePath.h"
#include "logging/LoggingQtCategories.h"

#include <QDirIterator>
#include <QResource>

ResourceLoader::ResourceLoader(QObject *parent) : QObject(parent)
{
    loadCoreResources();
//    loadViewResources();
}

ResourceLoader::~ResourceLoader()
{
}

bool ResourceLoader::registerControlViewResources(const QString &class_id) {
    QDir controlViewsDir(ResourcePath::hcsDocumentsCachePath() + "/control_views/" + class_id + "/control_views");

    if (controlViewsDir.exists()) {
        QStringList listOfVersions = controlViewsDir.entryList(QDir::Filter::Dirs);

        // If we have more than one version, remove the older version(s)
        if (listOfVersions.length() > 1) {
            QString latestVersion = getLatestVersion(listOfVersions);
            QStringList newListOfVersions;

            for (QString version : listOfVersions) {
                if (version != latestVersion) {
                    QDir dir(controlViewsDir.path()+ "/" + version);
                    if (dir.removeRecursively() == false) {
                        qCCritical(logCategoryResourceLoader) << "Unable to delete old version of control view " << class_id;
                    }
                } else {
                    newListOfVersions.push_back(version);
                }
            }

            listOfVersions = newListOfVersions;
        }

        // Now we have deleted all old versions
        controlViewsDir.cd(listOfVersions[0]);

        QStringList nameFiters = {"*.rcc"};

        controlViewsDir.setNameFilters(nameFiters);

        for (QString resource : controlViewsDir.entryList(QDir::Filter::Files)) {
            QDir dir(controlViewsDir.path() + "/" + resource);
            qCDebug(logCategoryResourceLoader) << "Loading resource " << resource << " for class id: " << class_id;
            if (registerResource(dir.path()) == false) {
                qCCritical(logCategoryResourceLoader) << "Failed to load resource " << resource << " for class id: " << class_id;
                // not sure if we want to return false indicating a failure here or not
            }
        }

        return true;
    } else {
        qCCritical(logCategoryResourceLoader) << "Could not find control_views directory. Looked in " << controlViewsDir.path();
        return false;
    }
}

bool ResourceLoader::registerResource(const QString &path, const QString &root) {
    qDebug(logCategoryResourceLoader) << "Registering resource: " << path;
    return QResource::registerResource(path, root);
}

bool ResourceLoader::unregisterResource(const QString &path, const QString &root) {
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

QString ResourceLoader::getLatestVersion(const QStringList &versions) {
    QString latestVersion = "0.0.0";

    for (QString version : versions) {
        QStringList latestVersionSeparated = latestVersion.split(".");
        QStringList versionSeparated = version.split(".");
        bool versionIsGreater = false;

        while (latestVersionSeparated.length() < 3) {
            latestVersionSeparated.push_back("0");
        }

        while (versionSeparated.length() < 3) {
            versionSeparated.push_back("0");
        }

        for (int i = 0; i < 3; i++) {
            if (versionSeparated[i].toInt() > latestVersionSeparated[i].toInt()) {
                versionIsGreater = true;
                break;
            } else if (versionSeparated[i].toInt() < latestVersionSeparated[i].toInt()) {
                versionIsGreater = false;
                break;
            }
        }

        if (versionIsGreater) {
            latestVersion = version;
        }
    }

    return latestVersion;
}
