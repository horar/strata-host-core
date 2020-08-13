#include "ResourceLoader.h"

#include "ResourcePath.h"
#include "logging/LoggingQtCategories.h"

#include <QDirIterator>
#include <QResource>
#include <QFileInfo>

ResourceLoader::ResourceLoader(QObject *parent) : QObject(parent)
{
    loadCoreResources();
}

ResourceLoader::~ResourceLoader()
{
}

bool ResourceLoader::deleteViewResource(const QString &class_id, const QString &version) {
    QDir controlViewsDir(ResourcePath::hcsDocumentsCachePath() + "/control_views/" + class_id + "/control_views");

    if (controlViewsDir.exists()) {
        if (version.isEmpty()) {
            // In this case, we want to delete all versions in the control_views directory
            QStringList listOfVersions = controlViewsDir.entryList(QDir::Filter::Dirs | QDir::Filter::NoDotAndDotDot);

            for (QString currentVersion : listOfVersions) {
                controlViewsDir.cd(currentVersion);
                // unregister resources
                for (QString resource : controlViewsDir.entryList(QDir::Filter::Files)) {
                    QFileInfo viewFileInfo(controlViewsDir.path() + "/" + resource);
                    if (unregisterResource(viewFileInfo.path()) == false) {
                        qCCritical(logCategoryResourceLoader) << "Failed to unregister resource " << resource << " for class id: " << class_id;
                    }
                }
                if (controlViewsDir.removeRecursively() == false) {
                    qCCritical(logCategoryResourceLoader) << "Could not delete the resource " << controlViewsDir.path();
                    return false;
                }
                controlViewsDir.cdUp();
            }
        } else {
            controlViewsDir.cd(version);
            for (QString resource : controlViewsDir.entryList(QDir::Filter::Files)) {
                QFileInfo viewFileInfo(controlViewsDir.path() + "/" + resource);
                if (unregisterResource(viewFileInfo.filePath()) == false) {
                    qCCritical(logCategoryResourceLoader) << "Failed to unregister resource " << resource << " for class id: " << class_id;
                }
            }
            if (controlViewsDir.removeRecursively() == false) {
                qCCritical(logCategoryResourceLoader) << "Could not delete the resource " << controlViewsDir.path();
                return false;
            }
        }
        viewsRegistered_.insert(class_id, false);
        return true;
    } else {
        qCCritical(logCategoryResourceLoader) << "Could not find control_views directory. Looked in " << controlViewsDir.path();
        return false;
    }
}

void ResourceLoader::registerControlViewResources(const QString &class_id, const QString &version) {
    if (isViewRegistered(class_id)) {
        qCDebug(logCategoryResourceLoader) << "View is already registered for " << class_id;
        emit resourceRegistered(class_id);
        return;
    }

    QDir controlViewsDir(ResourcePath::hcsDocumentsCachePath() + "/control_views/" + class_id + "/control_views");

    if (controlViewsDir.exists()) {
        QStringList listOfVersions = controlViewsDir.entryList(QDir::Filter::Dirs | QDir::Filter::NoDotAndDotDot);

        // If we have more than one version, remove the older version(s)
        if (listOfVersions.length() > 1) {
            bool foundMatchingVersion = false;
            QStringList dirsToRemove;

            for (QString currentVersion : listOfVersions) {
                if (currentVersion != version) {
                    dirsToRemove.append(controlViewsDir.path() + "/" + version);
                } else {
                    foundMatchingVersion = true;
                }
            }

            // If we found the matching version to install, then remove the rest of the directories
            if (foundMatchingVersion) {
                for (QString dirPath : dirsToRemove) {
                    QDir dir(dirPath);
                    if (dir.removeRecursively() == false) {
                        qCCritical(logCategoryResourceLoader) << "Unable to delete version of control view " << class_id;
                    }
                }
            } else {
                qCCritical(logCategoryResourceLoader) << "Could not find version " << version << " for control view " << class_id;
                emit resourceRegisterFailed(class_id);
                return;
            }
        }

        // Now we have deleted all old versions
        controlViewsDir.cd(version);

        qCDebug(logCategoryResourceLoader) << "Looking in resource path " << controlViewsDir.path();

        for (QString resource : controlViewsDir.entryList(QDir::Filter::Files)) {
            QFileInfo viewFileInfo(controlViewsDir.path() + "/" + resource);
            qCDebug(logCategoryResourceLoader) << "Loading resource " << resource << " for class id: " << class_id;
            if (registerResource(viewFileInfo.filePath()) == false) {
                qCCritical(logCategoryResourceLoader) << "Failed to load resource " << resource << " for class id: " << class_id;
                emit resourceRegisterFailed(class_id);
                return;
            } else {
                viewsRegistered_.insert(class_id, true);
            }
        }

        emit resourceRegistered(class_id);
    } else {
        emit resourceRegisterFailed(class_id);
        qCCritical(logCategoryResourceLoader) << "Could not find control_views directory. Looked in " << controlViewsDir.path();
    }
}

bool ResourceLoader::registerStaticControlViewResources(const QString &class_id, const QString &displayName) {
    if (displayName.isEmpty()) {
        return false;
    }

    QDirIterator it(ResourcePath::viewsResourcePath(), {QStringLiteral("views-*.rcc")},
                    QDir::Files);
    QString resourcePath;

    while (it.hasNext()) {
        QFileInfo resourceInfo(it.next());
        const QString resourceFile(resourceInfo.fileName());
        const int extIndex = resourceFile.indexOf(".rcc");

        if (resourceFile.mid(6, extIndex - 6) == displayName) {
            resourcePath = resourceInfo.filePath();
            break;
        }
    }

    if (resourcePath.isEmpty() == false) {
        deleteViewResource(class_id);
        viewsRegistered_.insert(class_id, true);

        bool registerResult = registerResource(resourcePath);
        viewsRegistered_.insert(class_id, registerResult);
        return registerResult;
    }
    return false;

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

bool ResourceLoader::isViewRegistered(const QString &class_id) {
    QHash<QString, bool>::const_iterator itr = viewsRegistered_.find(class_id);
    return itr != viewsRegistered_.end() && itr.value() == true;
}
