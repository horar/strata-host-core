#include "ResourceLoader.h"

#include "ResourcePath.h"
#include "logging/LoggingQtCategories.h"
#include "SGVersionUtils.h"

#include <QDirIterator>
#include <QResource>
#include <QFileInfo>
#include <QTimer>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>

const QStringList ResourceLoader::coreResources_{
    QStringLiteral("component-fonts.rcc"), QStringLiteral("component-theme.rcc"),
    QStringLiteral("component-pdfjs.rcc"), QStringLiteral("component-common.rcc"),
    QStringLiteral("component-sgwidgets.rcc")
};

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

void ResourceLoader::requestDeleteViewResource(const QString &class_id, const QString &rccPath, const QString &version, QObject *parent) {
    qDebug(logCategoryResourceLoader) << "Requesting unregistration and deletion of RCC:" << rccPath;
    QTimer::singleShot(100, this, [this, class_id, rccPath, version, parent]{ deleteViewResource(class_id, rccPath, version, parent); });
}

bool ResourceLoader::deleteViewResource(const QString &class_id, const QString &rccPath, const QString &version, QObject *parent) {
    if (rccPath.isEmpty() || class_id.isEmpty() || version.isEmpty()) {
        return false;
    }

    QQmlEngine *eng = qmlEngine(parent);
    eng->collectGarbage();
    eng->trimComponentCache();

    QFile resourceInfo(rccPath);

    if (resourceInfo.exists()) {
        if (QResource::unregisterResource(resourceInfo.fileName(), getQResourcePrefix(class_id, version)) == false) {
            qCWarning(logCategoryResourceLoader) << "Unable to unregister resource. Resource " << resourceInfo.fileName() << " either wasn't registered or is still in use for class id: " << class_id;
        } else {
            qCDebug(logCategoryResourceLoader) << "Successfully unregistered resource version " << version << " for " << resourceInfo.fileName();
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
    // Only reset this view in viewsRegistered if we have not already registered a different version
    // This most likely will be the case because we first register the new view's version under a different mapRoot and then asynchronously delete the old one.
    // In this case, the viewsRegistered_[class_id] will already contain the updated version
    if (itr != viewsRegistered_.end() && itr.value()->filepath == resourceInfo.fileName()) {
        ResourceItem *info = itr.value();
        info->filepath = "";
        info->gitTaggedVersion = "";
        info->version = "";
    }
    return true;
}

bool ResourceLoader::registerResource(const QString &path, const QString &prefix) {
    QFileInfo viewFileInfo(path);

    if (viewFileInfo.exists()) {
        qCDebug(logCategoryResourceLoader) << "Loading resource " << viewFileInfo.filePath() << " into virtual directory: " << prefix;

        /*********
         * Virtual directory prefix avoids conflicts when registering resources with same internal names or structure
         * Ex: qrc:/<prefix>/Control.qml
         *********/
        if (QResource::registerResource(viewFileInfo.filePath(), prefix) == false) {
            qCCritical(logCategoryResourceLoader) << "Failed to register resource " << viewFileInfo.fileName();
            return false;
        } else {
            qCDebug(logCategoryResourceLoader) << "Successfully registered resource.";
            return true;
        }
    } else {
        qCCritical(logCategoryResourceLoader) << "Could not find resource file. Looked in " << viewFileInfo.filePath();
        return false;
    }
}

bool ResourceLoader::registerControlViewResource(const QString &rccPath, const QString &class_id, const QString &version) {
    if (rccPath.isEmpty() || class_id.isEmpty() || version.isEmpty()) {
        return false;
    }

    if (registerResource(rccPath, getQResourcePrefix(class_id, version))) {
        // `gitTaggedVersion` is created at build time. It incorporates the git tag version into the rcc file.
        // The reason we store both is to double check that the metadata version shipped from OTA is the same as the
        //      version that is created at build time.

        QString gitTaggedVersion = getVersionJson(class_id, version);
        ResourceItem *info = new ResourceItem(rccPath, version, gitTaggedVersion);

        if (version != "static" && !SGVersionUtils::equalTo(version, gitTaggedVersion)) {
            // TODO: Handle the case where gitTaggedVersion is different from the OTA version
            qCWarning(logCategoryResourceLoader) << "Build version is different from OTA version for" << class_id << "- built in version:"
                                                 << gitTaggedVersion << ", OTA version:" << version;
        }

        viewsRegistered_.insert(class_id, info);
        return true;
    } else {
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

QString ResourceLoader::getStaticResourcesString() {
    return ResourcePath::viewsResourcePath();
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

QString ResourceLoader::getGitTaggedVersion(const QString &class_id)
{
    QHash<QString, ResourceItem*>::const_iterator itr = viewsRegistered_.find(class_id);
    if (itr != viewsRegistered_.end()) {
        return itr.value()->gitTaggedVersion;
    } else {
        return NULL;
    }
}

QString ResourceLoader::getVersionJson(const QString &class_id, const QString &version)
{
    QString filepath = ":" + getQResourcePrefix(class_id, version) + "/version.json";
    QFile versionJsonFile(filepath);

    qDebug(logCategoryResourceLoader) << "Looking in" << filepath << "for version.json";
    if (!versionJsonFile.exists()) {
        qCCritical(logCategoryResourceLoader) << "Could not find version.json." << filepath << "does not exist.";
        return QString();
    }

    if (!versionJsonFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qCCritical(logCategoryResourceLoader) << "Could not open version.json for" << class_id << "version" << version;
        return QString();
    }

    QString fileText = versionJsonFile.readAll();
    versionJsonFile.close();
    QJsonDocument doc = QJsonDocument::fromJson(fileText.toUtf8());
    QJsonObject docObj = doc.object();

    if (!docObj.contains(QString("version"))) {
        qCWarning(logCategoryResourceLoader) << "version.json does not have 'version' key.";
        return QString();
    }
    QJsonValue versionJson = docObj.value(QString("version"));

    qCInfo(logCategoryResourceLoader) << "Found version of " << versionJson.toString() << "for class id" << class_id;
    return versionJson.toString();
}

QString ResourceLoader::getQResourcePrefix(const QString &class_id, const QString &version) {
    if (class_id.isEmpty()) {
        return "/";
    } else {
        return "/" + class_id + (version.isEmpty() ? "" : "/" + version);
    }
}
