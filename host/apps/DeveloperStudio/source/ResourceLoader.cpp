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
    QHashIterator<QString, ResourceItem*> itr(viewsRegistered_);
    while (itr.hasNext()) {
        itr.next();
        delete itr.value();
    }
}

bool ResourceLoader::deleteViewResource(const QString &class_id, const QString &path, const QString &version, QObject *loader) {
    if (path.isEmpty() || version.isEmpty()) {
        return false;
    }

    QQmlEngine *eng = qmlEngine(loader);
    eng->trimComponentCache();
    eng->collectGarbage();

    QFile resourceInfo(path);

    if (resourceInfo.exists()) {
        if (unregisterResource(resourceInfo.fileName(), getQResourcePrefix(class_id, version)) == false) {
            qCWarning(logCategoryResourceLoader) << "Unable to unregister resource. Resource " << resourceInfo.fileName() << " still in use for class id: " << class_id;
        }
        if (resourceInfo.remove() == false) {
            qCCritical(logCategoryResourceLoader) << "Could not delete the resource " << resourceInfo.fileName();
            return false;
        }
    } else {
        qCCritical(logCategoryResourceLoader) << "Attempted to delete control view that doesn't exist - " << resourceInfo.fileName();
        return false;
    }

    QHash<QString, ResourceItem*>::iterator itr = viewsRegistered_.find(class_id);
    if (itr != viewsRegistered_.end() && itr.value()->filepath == resourceInfo.fileName()) {
        ResourceItem *info = itr.value();
        info->filepath = "";
        info->version = "";
    }
    return true;
}

bool ResourceLoader::deleteStaticViewResource(const QString &class_id, const QString &displayName, QObject *loader) {
    QQmlEngine *eng = qmlEngine(loader);
    eng->trimComponentCache();
    eng->collectGarbage();

    QFile rccFile(ResourcePath::viewsResourcePath() + "/views-" + displayName + ".rcc");

    qCDebug(logCategoryResourceLoader) << "Attempting to remove static resource file" << rccFile.fileName();
    if (rccFile.exists()) {
        if (!unregisterResource(rccFile.fileName())) {
            qCWarning(logCategoryResourceLoader) << "Resource " << rccFile.fileName() << " either does not exist or is still in use.";
        }
        if (!rccFile.remove()) {
            qCCritical(logCategoryResourceLoader) << "Could not delete static resource " << rccFile.fileName();
            return false;
        }

        QHash<QString, ResourceItem*>::iterator itr = viewsRegistered_.find(class_id);
        if (itr != viewsRegistered_.end() && itr.value()->filepath == rccFile.fileName()) {
            ResourceItem *info = itr.value();
            info->filepath = "";
            info->version = "";
        }
    }

    return true;
}

void ResourceLoader::registerControlViewResources(const QString &class_id, const QString &path, const QString &version) {
    if (isViewRegistered(class_id)) {
        qCDebug(logCategoryResourceLoader) << "View is already registered for " << class_id;
        emit resourceRegistered(class_id);
        return;
    }

    QFileInfo viewFileInfo(path);

    if (viewFileInfo.exists()) {
        qCDebug(logCategoryResourceLoader) << "Loading resource " << viewFileInfo.fileName() << " for class id: " << class_id;

        /*********
         * [HACK]
         * As of right now, (08/17/2020) there is a bug in Qt that prevents the unregistering of resources from memory.
         * This makes it impossible to overwrite versions of .rcc files that have the same name and use them without restarting the app.
         * In the meantime, we will use the version of the control view as the mapRoot.
         * Ex) version = 1.15.0 -> qrc:/1.15.0/views/.../views-<control_view_name>.qml
         *********/
        if (registerResource(viewFileInfo.filePath(), getQResourcePrefix(class_id, version)) == false) {
            qCCritical(logCategoryResourceLoader) << "Failed to register resource " << viewFileInfo.fileName() << " for class id: " << class_id;
            emit resourceRegisterFailed(class_id);
            return;
        } else {
            qCDebug(logCategoryResourceLoader) << "Successfully registered resource for class id: " << class_id;
            ResourceItem *info = new ResourceItem(viewFileInfo.filePath(), version);
            viewsRegistered_.insert(class_id, info);
            emit resourceRegistered(class_id);
        }
    } else {
        qCCritical(logCategoryResourceLoader) << "Could not find resource file. Looked in " << viewFileInfo.filePath();
        emit resourceRegisterFailed(class_id);
    }
}

bool ResourceLoader::registerStaticControlViewResources(const QString &class_id, const QString &displayName) {
    if (displayName.isEmpty()) {
        return false;
    }

    QFileInfo resourceInfo(ResourcePath::viewsResourcePath() + "/" + "views-" + displayName + ".rcc");

    if (resourceInfo.exists()) {
        qCDebug(logCategoryResourceLoader) << "Found static resource file, attempting to load resource " << resourceInfo.filePath() << " for class id: " << class_id;
        bool registerResult = registerResource(resourceInfo.filePath());
        ResourceItem *info = new ResourceItem(resourceInfo.filePath(), "");
        viewsRegistered_.insert(class_id, info);
        return registerResult;
    } else {
        qCDebug(logCategoryResourceLoader) << "Did not find static resource file " << resourceInfo.filePath();
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

QUrl ResourceLoader::getStaticResourcesUrl() {
    QUrl url;
    url.setScheme("file");
    url.setPath(ResourcePath::viewsResourcePath());
    return url;
}

bool ResourceLoader::isViewRegistered(const QString &class_id) {
    QHash<QString, ResourceItem*>::const_iterator itr = viewsRegistered_.find(class_id);
    return itr != viewsRegistered_.end() && !itr.value()->filepath.isEmpty();
}

QQmlComponent* ResourceLoader::createComponent(const QString &path, QQuickItem *parent) {
    QQmlEngine *e = qmlEngine(parent);
    if (e) {
        QQmlComponent *component = new QQmlComponent(e, path);
        if (component->errors().count() > 0) {
            qCCritical(logCategoryResourceLoader) << component->errorString();
        }
        return component;
    } else {
        return NULL;
    }
}

QQuickItem* ResourceLoader::createViewObject(const QString &path, QQuickItem *parent) {
    QQmlEngine *e = qmlEngine(parent);
    if (e) {
        QQmlComponent component = QQmlComponent(e, path);
        if (component.errors().count() > 0) {
            qCCritical(logCategoryResourceLoader) << component.errorString();
        }
        //todo 'if component/object null' error handling etc
        QObject* object = component.create();
        QQuickItem* item = qobject_cast<QQuickItem*>( object );
        QQmlEngine::setObjectOwnership(item, QQmlEngine::JavaScriptOwnership);

        item->setParentItem(parent);
        return item;
    } else {
        return NULL;
    }
}

QString ResourceLoader::getQResourcePrefix(const QString &class_id, const QString &version) {
    if (class_id.isEmpty()) {
        return "/";
    } else {
        return "/" + class_id + (version.isEmpty() ? "" : "/" + version);
    }
}
