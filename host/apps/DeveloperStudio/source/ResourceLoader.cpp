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
    if (path.isEmpty()) {
        return false;
    }

    QQmlEngine *eng = qmlEngine(loader);
    eng->trimComponentCache();
    eng->collectGarbage();

    QFile resourceInfo(path);

    if (resourceInfo.exists()) {
        if (QResource::unregisterResource(resourceInfo.fileName(), getQResourcePrefix(class_id, version)) == false) {
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

    QFileInfo rccFile(ResourcePath::viewsResourcePath() + "/views-" + displayName + ".rcc");
    return deleteViewResource(class_id, rccFile.filePath(), "", loader);
}

void ResourceLoader::registerControlViewResources(const QString &class_id, const QString &path, const QString &version) {
    QFileInfo viewFileInfo(path);

    if (viewFileInfo.exists()) {
        qCDebug(logCategoryResourceLoader) << "Loading resource " << viewFileInfo.fileName() << " for class id: " << class_id;

        /*********
         * We are currently using the class id and version to avoid conflicts when registering resources
         * Ex) version = 1.15.0 -> qrc:/<class_id>/1.15.0/views/.../views-<control_view_name>.qml
         *********/
        if (QResource::registerResource(viewFileInfo.filePath(), getQResourcePrefix(class_id, version)) == false) {
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
        bool registerResult = QResource::registerResource(resourceInfo.filePath());
        ResourceItem *info = new ResourceItem(resourceInfo.filePath(), "");
        viewsRegistered_.insert(class_id, info);
        return registerResult;
    } else {
        qCDebug(logCategoryResourceLoader) << "Did not find static resource file " << resourceInfo.filePath();
        return false;
    }
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
    if (itr != viewsRegistered_.end() && !itr.value()->filepath.isEmpty()) {
        return true;
    }
    return false;
}

QQuickItem* ResourceLoader::createViewObject(const QString &path, QQuickItem *parent, QVariantMap initialProperties) {
    QQmlEngine *e = qmlEngine(parent);
    if (e) {
        QQmlComponent component = QQmlComponent(e, path, QQmlComponent::CompilationMode::PreferSynchronous, parent);
        if (component.errors().count() > 0) {
            qCCritical(logCategoryResourceLoader) << component.errors();
            return NULL;
        }
        QQmlContext *context = qmlContext(parent);

        // From the Qt Docs:
        /*
         * When QQmlComponent constructs an instance, it occurs in three steps:
         *  1. The object hierarchy is created, and constant values are assigned.
         *  2. Property bindings are evaluated for the first time.
         *  3. If applicable, QQmlParserStatus::componentComplete() is called on objects.
         *
         * QQmlComponent::beginCreate() differs from QQmlComponent::create() in that it only performs step 1.
         * QQmlComponent::completeCreate() must be called to complete steps 2 and 3.
         */
        QObject* object = component.beginCreate(context);
        for (QString key : initialProperties.keys()) {
            object->setProperty(key.toLocal8Bit().data(), initialProperties.value(key));
        }
        component.completeCreate();

        QQuickItem* item = qobject_cast<QQuickItem*>( object );
        QQmlEngine::setObjectOwnership(item, QQmlEngine::JavaScriptOwnership);

        item->setParentItem(parent);
        return item;
    } else {
        return NULL;
    }
}

QString ResourceLoader::getVersionRegistered(const QString &class_id) {
    QHash<QString, ResourceItem*>::const_iterator itr = viewsRegistered_.find(class_id);
    if (itr != viewsRegistered_.end()) {
        return itr.value()->version;
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
