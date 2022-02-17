/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "ResourceLoader.h"

#include "ResourcePath.h"
#include "logging/LoggingQtCategories.h"
#include "SGVersionUtils.h"
#include "SGUtilsCpp.h"

#include "Version.h"

#include <QDirIterator>
#include <QResource>
#include <QFileInfo>
#include <QTimer>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QRegularExpression>

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
    viewsRegistered_.clear();
}

bool ResourceLoader::registerResource(const QString &path, const QString &prefix) {
    QFileInfo resourceInfo(path);

    if (resourceInfo.exists()) {
        qCDebug(lcResourceLoader) << "Loading resource" << resourceInfo.filePath() << "into virtual directory:" << prefix;

        /*********
         * Virtual directory prefix avoids conflicts when registering resources with same internal names or structure
         * Ex: qrc:/<prefix>/Control.qml
         *********/
        if (QResource::registerResource(resourceInfo.filePath(), prefix)) {
            qCDebug(lcResourceLoader) << "Successfully registered resource.";
            return true;
        } else {
            qCCritical(lcResourceLoader) << "Failed to register resource" << resourceInfo.fileName();
            return false;
        }
    } else {
        qCCritical(lcResourceLoader) << "Could not find resource file. Looked in" << resourceInfo.filePath();
        return false;
    }
}

bool ResourceLoader::registerControlViewResource(const QString &rccPath, const QString &class_id, const QString &version) {
    if (rccPath.isEmpty() || class_id.isEmpty() || version.isEmpty()) {
        return false;
    }

    QMultiHash<QString, ResourceItem*>::const_iterator itr = viewsRegistered_.constFind(class_id);
    while (itr != viewsRegistered_.cend() && itr.key() == class_id) {
        if (itr.value()->filepath == rccPath && itr.value()->version == version) {
            qCWarning(lcResourceLoader).nospace() << "Resource already loaded for class id: " << class_id
                                                           << ", rccPath: " << rccPath << ", version: " << version;
            return true;
        }
        ++itr;
    }

    if (registerResource(rccPath, getQResourcePrefix(class_id, version))) {
        // `gitTaggedVersion` is created at build time. It incorporates the git tag version into the rcc file.
        // The reason we store both is to double check that the metadata version shipped from OTA is the same as the
        //      version that is created at build time.

        QString gitTaggedVersion = getVersionJson(class_id, version);
        ResourceItem *info = new ResourceItem(rccPath, version, gitTaggedVersion);

        if (version != "static" && !SGVersionUtils::equalTo(version, gitTaggedVersion)) {
            // TODO: Handle the case where gitTaggedVersion is different from the OTA version
            qCWarning(lcResourceLoader) << "Build version is different from OTA version for" << class_id << "- built in version:"
                                                 << gitTaggedVersion << ", OTA version:" << version;
        }

        viewsRegistered_.insert(class_id, info);
        return true;
    } else {
        return false;
    }
}

void ResourceLoader::requestUnregisterDeleteViewResource(const QString class_id, const QString rccPath, const QString version, QObject *parent, const bool removeFromSystem) {
    if (removeFromSystem) {
        qCDebug(lcResourceLoader) << "Requesting unregistration and deletion of RCC:" << rccPath;
    } else {
        qCDebug(lcResourceLoader) << "Requesting unregistration of RCC:" << rccPath;
    }
    QTimer::singleShot(1, this, [=]{
        if (unregisterDeleteViewResource(class_id, rccPath, version, parent, removeFromSystem) == false) {
            qCWarning(lcResourceLoader).nospace() << "Resource not unregistered/deleted, might remain stored in memory/HDD, class id: " << class_id << ", rccPath: " << rccPath << ", version: " << version;
        }
    });
}

bool ResourceLoader::unregisterDeleteViewResource(const QString &class_id, const QString &rccPath, const QString &version, QObject *parent, const bool removeFromSystem) {
    if (rccPath.isEmpty() || class_id.isEmpty() || version.isEmpty()) {
        qCCritical(lcResourceLoader).nospace() << "Invalid data provided, class id: " << class_id << ", rccPath: " << rccPath << ", version: " << version;
        return false;
    }

    trimComponentCache(parent);

    QFile resourceInfo(rccPath);

    bool success = true;
    if (resourceInfo.exists()) {
        if (QResource::unregisterResource(resourceInfo.fileName(), getQResourcePrefix(class_id, version))) {
            qCDebug(lcResourceLoader) << "Successfully unregistered resource version" << version << "for" << resourceInfo.fileName();
        } else {
            qCWarning(lcResourceLoader) << "Unable to unregister resource. Resource" << resourceInfo.fileName() << "either wasn't registered or is still in use for class id:" << class_id;
            success = false;
        }

        if (removeFromSystem) {
            if (resourceInfo.remove() == false) {
                qCCritical(lcResourceLoader) << "Could not delete the resource" << resourceInfo.fileName();
                success = false;
            }
        }

        auto ret = viewsRegistered_.equal_range(class_id);
        for (auto itr = ret.first; itr != ret.second; ++itr) {
            ResourceItem* info = itr.value();
            if (info->filepath == resourceInfo.fileName() && info->version == version) {
                viewsRegistered_.erase(itr);
                delete info;
                break;
            }
        }
    } else {
        qCCritical(lcResourceLoader) << "Attempted to delete control view that doesn't exist -" << resourceInfo.fileName();
        success = false;
    }

    return success;
}

void ResourceLoader::requestUnregisterResource(const QString &path, const QString &prefix, QObject *parent, const bool removeFromSystem) {
    if (removeFromSystem) {
        qCDebug(lcResourceLoader) << "Requesting unregistration and deletion of RCC:" << path;
    } else {
        qCDebug(lcResourceLoader) << "Requesting unregistration of RCC:" << path;
    }
    QTimer::singleShot(1, this, [=]{
        if (unregisterResource(path, prefix, parent, removeFromSystem) == false) {
            qCWarning(lcResourceLoader).nospace() << "Resource not unregistered/deleted, might remain stored in memory/HDD, path: " << path << ", prefix: " << prefix;
        }
    });
}

bool ResourceLoader::unregisterResource(const QString &path, const QString &prefix, QObject *parent, const bool removeFromSystem) {
    if (path.isEmpty() || prefix.isEmpty()) {
        qCCritical(lcResourceLoader).nospace() << "Invalid data provided, path: " << path << ", prefix: " << prefix;
        return false;
    }

    trimComponentCache(parent);

    QFileInfo resourceInfo(path);

    bool success = true;
    if (resourceInfo.exists()) {
        if (QResource::unregisterResource(resourceInfo.filePath(), prefix)) {
            qCDebug(lcResourceLoader) << "Successfully unregistered resource" << resourceInfo.fileName() << "with prefix" << prefix;
        } else {
            qCWarning(lcResourceLoader) << "Unable to unregister resource. Resource" << resourceInfo.fileName() << "either wasn't registered or is still in use with prefix:" << prefix;
            success = false;
        }

        if (removeFromSystem) {
            QFile resourceFile(path);
            if (resourceFile.remove() == false) {
                qCCritical(lcResourceLoader) << "Could not delete the resource" << resourceInfo.fileName();
                success = false;
            }
        }
    } else {
        qCCritical(lcResourceLoader) << "Attempted to delete control view that doesn't exist -" << resourceInfo.fileName();
        success = false;
    }

    return success;
}

void ResourceLoader::loadCoreResources()
{
    for (const auto& resourceName : coreResources_) {
        const QString resourceFile(
            QString("%1/%2").arg(ResourcePath::coreResourcePath()).arg(resourceName));

        if (QFile::exists(resourceFile) == false) {
            qCCritical(lcDevStudio(), "Missing '%s' resource file!!",
                       qUtf8Printable(resourceName));
            continue;
        }
        qCDebug(lcDevStudio(), "Loading '%s: %d': ", qUtf8Printable(resourceFile),
                QResource::registerResource(resourceFile));
    }
}


void ResourceLoader::loadPluginResources()
{
    QStringList supportedPlugins{QString(std::string(AppInfo::supportedPlugins_).c_str()).split(QChar(':'))};
    supportedPlugins.removeAll(QString(""));
    if (supportedPlugins.empty()) {
        qCDebug(lcDevStudio) << "No supported plugins";
        return;
    }

    for (const auto& pluginName : qAsConst(supportedPlugins)) {
        QString resourceFile(
            QStringLiteral("%1/plugins/sds-%2.rcc").arg(ResourcePath::coreResourcePath(), pluginName));

        if (QFile::exists(resourceFile) == false) {
            resourceFile = QStringLiteral("%1/plugins/%2.rcc").arg(ResourcePath::coreResourcePath(), pluginName);
            if (QFile::exists(resourceFile) == false) {
                qCDebug(lcDevStudio(), "Skipping '%s' plugin resource file...",
                        qUtf8Printable(pluginName));
                continue;
            }
        }
        qCDebug(lcDevStudio(), "Loading '%s: %d': ", qUtf8Printable(resourceFile),
                QResource::registerResource(resourceFile));
    }
}

void ResourceLoader::unregisterAllViews(QObject *parent)
{
    QHashIterator<QString, ResourceItem*> itr(viewsRegistered_);
    while (itr.hasNext()) {
        itr.next();
        ResourceItem* info = itr.value();

        requestUnregisterDeleteViewResource(itr.key(), info->filepath, info->version, parent, false);
        delete info;
    }
    viewsRegistered_.clear();
}

void ResourceLoader::unregisterAllRelatedViews(const QString &class_id, QObject *parent)
{
    auto ret = viewsRegistered_.equal_range(class_id);
    QMultiHash<QString, ResourceItem*>::iterator itr = ret.first;
    while (itr != ret.second) {
        ResourceItem* info = itr.value();

        requestUnregisterDeleteViewResource(class_id, info->filepath, info->version, parent, false);
        itr = viewsRegistered_.erase(itr);
        delete info;
    }
}

bool ResourceLoader::isViewRegistered(const QString &class_id)
{
    return viewsRegistered_.contains(class_id);
}

QString ResourceLoader::getVersionRegistered(const QString &class_id)
{
    // will get the most recent value
    QMultiHash<QString, ResourceItem*>::const_iterator itr = viewsRegistered_.constFind(class_id);
    if (itr != viewsRegistered_.cend()) {
        return itr.value()->version;
    } else {
        return QString();
    }
}

QString ResourceLoader::getGitTaggedVersion(const QString &class_id)
{
    // will get the most recent value
    QMultiHash<QString, ResourceItem*>::const_iterator itr = viewsRegistered_.constFind(class_id);
    if (itr != viewsRegistered_.cend()) {
        return itr.value()->gitTaggedVersion;
    } else {
        return QString();
    }
}

QString ResourceLoader::getVersionJson(const QString &class_id, const QString &version)
{
    QString filepath = ":" + getQResourcePrefix(class_id, version) + "/version.json";
    QFile versionJsonFile(filepath);

    qCDebug(lcResourceLoader) << "Looking in" << filepath << "for version.json";
    if (!versionJsonFile.exists()) {
        qCCritical(lcResourceLoader) << "Could not find version.json." << filepath << "does not exist.";
        return QString();
    }

    if (!versionJsonFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qCCritical(lcResourceLoader) << "Could not open version.json for" << class_id << "version" << version;
        return QString();
    }

    QByteArray fileText = versionJsonFile.readAll();
    versionJsonFile.close();
    QJsonDocument doc = QJsonDocument::fromJson(fileText);
    QJsonObject docObj = doc.object();

    if (!docObj.contains(QString("version"))) {
        qCWarning(lcResourceLoader) << "version.json does not have 'version' key.";
        return QString();
    }
    QJsonValue versionJson = docObj.value(QString("version"));

    qCInfo(lcResourceLoader) << "Found version of" << versionJson.toString() << "for class id" << class_id;
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
    qCWarning(lcDevStudio) << error_str;
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
    if ((QDir::separator() != '/') && qrcFilePath.startsWith('/')) {
        qrcFilePath.remove(0, 1);
    }

    QFile qrcFile(qrcFilePath);
    if (!qrcFile.exists()) {
        QString error_str = "Could not find QRC file at " + qrcFilePath;
        qCWarning(lcDevStudio) << error_str;
        setLastLoggedError(error_str);
        emit finishedRecompiling(QString());
        return;
    }

    QFileInfo qrcFileInfo = QFileInfo(qrcFile);
    QDir qrcFileParent = qrcFileInfo.dir();
    QString compiledRccFile = qrcFileParent.path() + QDir::separator() + "build" + QDir::separator();
    QDir qrcDevControlView(compiledRccFile);

    if (qrcDevControlView.exists()) {
        qrcDevControlView.setFilter(QDir::NoDotAndDotDot | QDir::Files);
        foreach (QString dirItem, qrcDevControlView.entryList()) {
            if (!qrcDevControlView.remove(dirItem)) {
                QString error_str = "Error: could not delete " + dirItem;
                qCWarning(lcDevStudio) << error_str;
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
                qCWarning(lcDevStudio) << error_str;
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
    qCCritical(lcDevStudio) << error_str;
    setLastLoggedError(error_str);
}

void ResourceLoader::recompileFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    Q_UNUSED(exitCode);

    if (exitStatus == QProcess::CrashExit || lastLoggedError_ != "") {
        emit finishedRecompiling(QString());
    } else {
        qCDebug(lcResourceLoader) << "Wrote compiled resource file to" << lastCompiledRccResource_;
        emit finishedRecompiling(lastCompiledRccResource_);
    }
}

void ResourceLoader::clearLastLoggedError() {
    lastLoggedError_ = "";
}

void ResourceLoader::setLastLoggedError(const QString &error_str) {
    lastLoggedError_ = error_str;
}

QString ResourceLoader::getLastLoggedError() {
    return lastLoggedError_;
}

void ResourceLoader::trimComponentCache(QObject *parent) {
    if (parent != nullptr) {
        QQmlEngine *eng = qmlEngine(parent);
        if (eng != nullptr) {
            eng->collectGarbage();
            eng->trimComponentCache();
        } else {
            qCWarning(lcResourceLoader) << "There is no QQmlEngine associated with object" << parent;
        }
    }
}

QList<QString> ResourceLoader::getQrcPaths(const QString &path) {
    QList<QString> pathList;
    QDirIterator it(path, QDirIterator::Subdirectories);
    while (it.hasNext()) {
        pathList.append(it.next());
    }
    return pathList;
}

QString ResourceLoader::getProjectNameFromCmake(const QString &qrcPath) {
    const QFile qrcFile(qrcPath);
    if (!qrcFile.exists()) {
        qCCritical(lcResourceLoader) << "Unable to find QRC file at:" << qrcPath;
        return QString();
    }

    // Find QRC file's parent directory, then read CMakeLists.txt in it
    const QDir parentDir(SGUtilsCpp::parentDirectoryPath(qrcPath));
    const QString cmakePath = parentDir.filePath("CMakeLists.txt");
    const QString cmakeText = SGUtilsCpp::readTextFileContent(cmakePath);
    if (cmakeText.isEmpty()) {
        return QString();
    }

    // Regex to get 'project_name' out of 'project(project_name)'
    const QRegularExpression re("(?<=project\\()(\\w+)");
    const QRegularExpressionMatch match = re.match(cmakeText);
    return match.captured();
}
