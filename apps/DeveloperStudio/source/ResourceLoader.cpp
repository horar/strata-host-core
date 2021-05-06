#include "ResourceLoader.h"

#include "ResourcePath.h"
#include "logging/LoggingQtCategories.h"
#include "SGVersionUtils.h"

#include "Version.h"

#include <QDirIterator>
#include <QResource>
#include <QFileInfo>
#include <QTimer>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QQmlContext>

const QStringList ResourceLoader::coreResources_{
    QStringLiteral("component-fonts.rcc"), QStringLiteral("component-theme.rcc"),
    QStringLiteral("component-pdfjs.rcc"), QStringLiteral("component-common.rcc"),
    QStringLiteral("component-sgwidgets.rcc"),
    #ifdef QT_RCC_EXECUTABLE
        QStringLiteral("component-monaco.rcc"),
    #endif
};

ResourceLoader::ResourceLoader(QObject *parent) : QObject(parent)
{
    loadCoreResources();
    loadPluginResources();
}

ResourceLoader::~ResourceLoader()
{
    QHashIterator<QString, ResourceItem*> itr(viewsRegistered_);
    while (itr.hasNext()) {
        itr.next();
        delete itr.value();
    }
}

void ResourceLoader::requestUnregisterDeleteViewResource(const QString class_id, const QString rccPath, const QString version, QObject *parent, const bool removeFromSystem) {
    if (removeFromSystem) {
        qDebug(logCategoryResourceLoader) << "Requesting unregistration and deletion of RCC:" << rccPath;
    } else {
        qDebug(logCategoryResourceLoader) << "Requesting unregistration of RCC:" << rccPath;
    }
    QTimer::singleShot(100, this, [this, class_id, rccPath, version, parent, removeFromSystem]{ unregisterDeleteViewResource(class_id, rccPath, version, parent, removeFromSystem); });
}

bool ResourceLoader::unregisterDeleteViewResource(const QString &class_id, const QString &rccPath, const QString &version, QObject *parent, const bool removeFromSystem) {
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

        if (removeFromSystem) {
            if (resourceInfo.remove() == false) {
                qCCritical(logCategoryResourceLoader) << "Could not delete the resource " << resourceInfo.fileName();
                return false;
            }
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

        if (!SGVersionUtils::equalTo(version, gitTaggedVersion)) {
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

QUrl ResourceLoader::getStaticViewsPhysicalPathUrl() {
    return QUrl::fromLocalFile(ResourcePath::viewsPhysicalPath());
}

void ResourceLoader::loadPluginResources()
{
    const QStringList supportedPLugins{QString(std::string(AppInfo::supportedPlugins_).c_str()).split(QChar(':'))};
    if (supportedPLugins.empty()) {
        qCDebug(logCategoryStrataDevStudio) << "No supported plugins";
        return;
    }

    for (const auto& pluginName : qAsConst(supportedPLugins)) {
        const QString resourceFile(
            QStringLiteral("%1/plugins/sds-%2.rcc").arg(ResourcePath::coreResourcePath(), pluginName));

        if (QFile::exists(resourceFile) == false) {
            qCDebug(logCategoryStrataDevStudio(), "Skipping '%s' plugin resource file...",
                    qUtf8Printable(pluginName));
            continue;
        }
        qCDebug(logCategoryStrataDevStudio(), "Loading '%s: %d': ", qUtf8Printable(resourceFile),
                QResource::registerResource(resourceFile));
    }
}

QString ResourceLoader::returnQrcPath(const QString &filePath){

    QDirIterator dir(filePath);
    QString str = "";

    while(dir.hasNext()){
        QFileInfo fi(dir.next());
        if(fi.suffix() == "qrc"){
            str = fi.absoluteFilePath();
            break;
        }
    }

    return str;
}

void ResourceLoader::unregisterAllViews(QObject *parent)
{
    QHashIterator<QString, ResourceItem*> itr(viewsRegistered_);
    while (itr.hasNext()) {
        itr.next();
        ResourceItem* item = itr.value();

        requestUnregisterDeleteViewResource(itr.key(), item->filepath, item->version, parent, false);
    }
    viewsRegistered_.clear();
}

bool ResourceLoader::isViewRegistered(const QString &class_id) {
    QHash<QString, ResourceItem*>::const_iterator itr = viewsRegistered_.find(class_id);
    if (itr != viewsRegistered_.end() && !itr.value()->filepath.isEmpty()) {
        return true;
    }
    return false;
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

bool ResourceLoader::findRccCompiler() {
    QDir applicationDir(QCoreApplication::applicationDirPath());

#ifdef Q_OS_MACOS
    applicationDir.cdUp();
    applicationDir.cdUp();
    applicationDir.cdUp();
    const QString rccExecutablePath = applicationDir.filePath("rcc");
#else
    const QString rccExecutablePath = applicationDir.filePath("rcc.exe");
#endif

    const QFile rccExecutable(rccExecutablePath);
    if (rccExecutable.exists()) {
        rccCompilerPath_ = rccExecutablePath;
        return true;
    }

    QString error_str = "Could not find RCC executable at " + rccExecutablePath;
    qCWarning(logCategoryStrataDevStudio) << error_str;
    setLastLoggedError(error_str);
    emit finishedRecompiling(QString());
    return false;
}

void ResourceLoader::recompileControlViewQrc(QString qrcFilePath) {
    clearLastLoggedError();
    bool rccCompilerFound = false;

#ifdef QT_RCC_EXECUTABLE
    const QFile rccExecutable(QT_RCC_EXECUTABLE);
    if (rccExecutable.exists()) {
        rccCompilerPath_ = QT_RCC_EXECUTABLE;
        rccCompilerFound = true;
    } else {
        rccCompilerFound = findRccCompiler();
    }
#else
    rccCompilerFound = findRccCompiler();
#endif

    if (!rccCompilerFound) {
        return;
    }

    qrcFilePath.replace("file://", "");
    if (qrcFilePath.at(0) == "/" && qrcFilePath.at(0) != QDir::separator()) {
        qrcFilePath.remove(0, 1);
    }

    QFile qrcFile(qrcFilePath);
    if (!qrcFile.exists()) {
        QString error_str = "Could not find QRC file at " + qrcFilePath;
        qCWarning(logCategoryStrataDevStudio) << error_str;
        setLastLoggedError(error_str);
        emit finishedRecompiling(QString());
        return;
    }

    QFileInfo qrcFileInfo = QFileInfo(qrcFile);
    QDir qrcFileParent = qrcFileInfo.dir();
    QString compiledRccFile = qrcFileParent.path() + QDir::separator() + "DEV-CONTROLVIEW" + QDir::separator();
    QDir qrcDevControlView(compiledRccFile);

    if (qrcDevControlView.exists()) {
        qrcDevControlView.setFilter(QDir::NoDotAndDotDot | QDir::Files);
        foreach (QString dirItem, qrcDevControlView.entryList()) {
            if (!qrcDevControlView.remove(dirItem)) {
                QString error_str = "Error: could not delete " + dirItem;
                qCWarning(logCategoryStrataDevStudio) << error_str;
                setLastLoggedError(error_str);
                emit finishedRecompiling(QString());
                return;
            }
        }

        qrcDevControlView.setFilter(QDir::NoDotAndDotDot | QDir::Dirs);
        foreach (QString dirItem, qrcDevControlView.entryList()) {
            QDir subDir(qrcDevControlView.absoluteFilePath(dirItem));
            if (!subDir.removeRecursively()) {
                QString error_str = "Error: could not delete " + dirItem;
                qCWarning(logCategoryStrataDevStudio) << error_str;
                setLastLoggedError(error_str);
                emit finishedRecompiling(QString());
                return;
            }
        }
    }

    // Make directory for compiled RCC files
    QDir().mkdir(compiledRccFile);

    // Split qrcFile base name and add ".rcc" extension
    compiledRccFile += qrcFileInfo.baseName() + ".rcc";
    lastCompiledRccResource_ = compiledRccFile;

    // Set and launch rcc compiler process
    const auto arguments = (QList<QString>() << "-binary" << qrcFilePath << "-o" << compiledRccFile);

    rccCompilerProcess_ = std::make_unique<QProcess>();
    rccCompilerProcess_->setProgram(rccCompilerPath_);
    rccCompilerProcess_->setArguments(arguments);
    connect(rccCompilerProcess_.get(), SIGNAL(readyReadStandardError()), this, SLOT(onOutputRead()), Qt::UniqueConnection);
    connect(rccCompilerProcess_.get(), QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), this, &ResourceLoader::recompileFinished);

    rccCompilerProcess_->start();
}

void ResourceLoader::onOutputRead() {
    QString error_str = rccCompilerProcess_->readAllStandardError();
    qCCritical(logCategoryStrataDevStudio) << error_str;
    setLastLoggedError(error_str);
}

void ResourceLoader::recompileFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    Q_UNUSED(exitCode);

    if (exitStatus == QProcess::CrashExit || lastLoggedError_ != "") {
        emit finishedRecompiling(QString());
    } else {
        qCDebug(logCategoryResourceLoader) << "Wrote compiled resource file to " << lastCompiledRccResource_;
        emit finishedRecompiling(lastCompiledRccResource_);
    }
}

void ResourceLoader::clearLastLoggedError() {
    lastLoggedError_ = "";
}

void ResourceLoader::setLastLoggedError(QString &error_str) {
    lastLoggedError_ = error_str;
}

QString ResourceLoader::getLastLoggedError() {
    return lastLoggedError_;
}
