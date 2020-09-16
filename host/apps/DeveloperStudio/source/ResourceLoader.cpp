#include "ResourceLoader.h"

#include "ResourcePath.h"
#include "logging/LoggingQtCategories.h"

#include <QDirIterator>
#include <QResource>
#include <QFileInfo>
#include <QTimer>

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
        ResourceItem *info = new ResourceItem(rccPath, version);
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

QString ResourceLoader::getQResourcePrefix(const QString &class_id, const QString &version) {
    if (class_id.isEmpty()) {
        return "/";
    } else {
        return "/" + class_id + (version.isEmpty() ? "" : "/" + version);
    }
}

QString ResourceLoader::recompileControlViewQrc(QString qrcFilePath, const double &prefix)
{
    // Hard-coded for now
    // Mac OS: "/Users/***/Qt/5.12.2/clang_64/bin/rcc"
    const QString rccExecutablePath = "";

    qrcFilePath.replace("file://", "");

    QFile rccExecutable(rccExecutablePath);
    QFile qrcFile(qrcFilePath);

    if (!rccExecutable.exists()) {
        qCWarning(logCategoryStrataDevStudio) << "Could not find RCC executable at " << rccExecutablePath;
        return QString();
    }

    if (!qrcFile.exists()) {
        qCWarning(logCategoryStrataDevStudio) << "Could not find QRC file at " << qrcFilePath;
        return QString();
    }

    QFileInfo qrcFileInfo = QFileInfo(qrcFile);
    QDir qrcFileParent = qrcFileInfo.dir();
    QString compiledRccFile = qrcFileParent.path() + QDir::separator() + "DEV-CONTROLVIEW" + QDir::separator();
    QDir qrcDevControlView(compiledRccFile);

    if (qrcDevControlView.exists()) {
        if (!qrcDevControlView.removeRecursively()) {
            qCWarning(logCategoryStrataDevStudio) << "Could not delete directory " << compiledRccFile;
            return QString();
        }
    }

    QString timestampPrefix = QString::number(prefix, 'f', 0);

    // Make timestampPrefix directory for compiled RCC file
    QDir().mkdir(compiledRccFile);
    QDir().mkdir(compiledRccFile + timestampPrefix);

    // Split qrcFilePath for filename
    QFileInfo fileInfo(qrcFile.fileName());
    QString qrcFileName(fileInfo.fileName());

    // Add timestampPrefix directory to binary object path
    compiledRccFile += timestampPrefix;
    compiledRccFile += QDir::separator();
    compiledRccFile += qrcFileName;

    const auto arguments = (QList<QString>() << "-binary" << qrcFilePath << "-o" << compiledRccFile);

    rccCompilerProcess_.setProgram(rccExecutablePath);
    rccCompilerProcess_.setArguments(arguments);

    connect(&rccCompilerProcess_, SIGNAL(readyReadStandardError()), this, SLOT(onOutputRead()));

    rccCompilerProcess_.start();
    rccCompilerProcess_.waitForFinished();

    qCDebug(logCategoryResourceLoader) << "Wrote compiled resource file to " << compiledRccFile;
    return compiledRccFile;
}

void ResourceLoader::onOutputRead() {
    qDebug() << rccCompilerProcess_.readAllStandardError();
}