#include "SDSModel.h"

#include "DocumentManager.h"
#include "SGNewControlView.h"
#include "HcsNode.h"
#include "ResourceLoader.h"
#include "PlatformInterfaceGenerator.h"
#include "VisualEditorUndoStack.h"
#include "logging/LoggingQtCategories.h"
#include "ProgramControllerManager.h"
#include "FirmwareManager.h"

#include <PlatformInterface/core/CoreInterface.h>

#include <QThread>

#include <QStandardPaths>
#include <QRandomGenerator>

#include <memory>

#ifdef Q_OS_WIN
#include <ShlObj.h>
#include <Shlwapi.h>
#endif

SDSModel::SDSModel(const QUrl &dealerAddress, const QString &configFilePath, QObject *parent)
    : QObject(parent),
      strataClient_(new strata::strataRPC::StrataClient(dealerAddress.toString(), "", this)),
      coreInterface_(new CoreInterface(strataClient_, this)),
      documentManager_(new DocumentManager(strataClient_, coreInterface_, this)),
      resourceLoader_(new ResourceLoader(this)),
      newControlView_(new SGNewControlView(this)),
      programControllerManager_(new ProgramControllerManager(strataClient_, coreInterface_, this)),
      firmwareManager_(new FirmwareManager(strataClient_, coreInterface_, this)),
      platformInterfaceGenerator_(new PlatformInterfaceGenerator(this)),
      visualEditorUndoStack_(new VisualEditorUndoStack(this)),
      remoteHcsNode_(new HcsNode(this)),
      urlConfig_(new strata::sds::config::UrlConfig(configFilePath, this)),
      hcsIdentifier_(QRandomGenerator::global()->bounded(0x00000001u, 0xFFFFFFFFu)) // skips 0
{
    strataClient_->connect();
    connect(remoteHcsNode_, &HcsNode::hcsConnectedChanged, this, &SDSModel::setHcsConnected);
    if (urlConfig_->parseUrl() == false) {
        delete urlConfig_;
        urlConfig_ = nullptr;
    }
}

SDSModel::~SDSModel()
{
    delete documentManager_;
    delete coreInterface_;
    delete resourceLoader_;
    delete newControlView_;
    delete platformInterfaceGenerator_;
    delete visualEditorUndoStack_;
    delete remoteHcsNode_;
    delete programControllerManager_;
    delete firmwareManager_;
    delete urlConfig_;
    delete strataClient_;
}

bool SDSModel::startHcs()
{
    if (hcsProcess_.isNull() == false) {
        return false;
    }

    const QString appDirPath = QCoreApplication::applicationDirPath();

#ifdef Q_OS_WIN
    const QString hcsPath{ QDir::cleanPath(QString("%1/hcs.exe").arg(appDirPath)) };
#if WINDOWS_INSTALLER_BUILD
    QString hcsConfigPath;
    TCHAR programDataPath[MAX_PATH];
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_APPDATA, NULL, 0, programDataPath))) {
        hcsConfigPath = QDir::cleanPath(QString("%1/ON Semiconductor/Strata Developer Studio/HCS/hcs.config").arg(programDataPath));
        qCInfo(logCategoryStrataDevStudio) << QStringLiteral("hcsConfigPath:") << hcsConfigPath;
    }else{
        qCCritical(logCategoryStrataDevStudio) << "Failed to get ProgramData path using windows API call...";
        return false;
    }
#else
    const QString hcsConfigPath{ QDir::cleanPath(QString("%1/hcs.config").arg(appDirPath)) };
#endif
#endif

#ifdef Q_OS_MACOS
    const QString hcsPath{ QDir::cleanPath(QString("%1/../../../hcs").arg(appDirPath)) };
    const QString hcsConfigPath{ QDir::cleanPath( QString("%1/../../../hcs.config").arg(appDirPath)) };
#endif

#ifdef Q_OS_LINUX
    const QString hcsPath{ QDir::cleanPath(QString("%1/hcs").arg(appDirPath)) };
    const QString hcsConfigPath{ QDir::cleanPath(QString("%1/hcs.config").arg(appDirPath))};
#endif

    // Start HCS before handling events for Qt

    if (QFile::exists(hcsPath)) {
        hcsProcess_ = new QProcess(this);

        hcsProcess_->setStandardOutputFile(QProcess::nullDevice());
        hcsProcess_->setStandardErrorFile(QProcess::nullDevice());

        connect(hcsProcess_, &QProcess::started,
            this, &SDSModel::startedProcess);

        connect(hcsProcess_, qOverload<int, QProcess::ExitStatus>(&QProcess::finished),
                this, &SDSModel::finishHcsProcess);

        connect(hcsProcess_, &QProcess::errorOccurred,
                this, &SDSModel::handleHcsProcessError);

        QStringList arguments;
        arguments << "-f" << hcsConfigPath;
        arguments << "-i" << QString::number(hcsIdentifier_);

        qCDebug(logCategoryStrataDevStudio) << "Starting HCS:" << hcsPath << "(" << hcsConfigPath << "), identifier:" << hcsIdentifier_;

        hcsProcess_->start(hcsPath, arguments, QIODevice::ReadWrite);
        if (hcsProcess_->waitForStarted() == false) {
            qCWarning(logCategoryStrataDevStudio) << "Process does not started yet (state:" << hcsProcess_->state() << ")";
            return false;
        }
    } else {
        qCCritical(logCategoryStrataDevStudio) << "Failed to start HCS: does not exist";
        return false;
    }

    return true;
}

bool SDSModel::killHcs()
{
    if (hcsProcess_.isNull()) {
        return false;
    }

    if (hcsProcess_->state() == QProcess::Running) {
        qCDebug(logCategoryStrataDevStudio) << "waiting for HCS gracefull finish...";
        if (hcsProcess_->waitForFinished(5000) == true) {
            return true;
        }

#ifdef Q_OS_UNIX
        qCDebug(logCategoryStrataDevStudio) << "terminating HCS...";
        hcsProcess_->terminate();
        QThread::msleep(100);   //This needs to be here, otherwise 'waitForFinished' waits until timeout
        if (hcsProcess_->waitForFinished(5000) == true) {
            return true;
        }
        qCWarning(logCategoryStrataDevStudio) << "Failed to terminate the server";
#endif

        qCDebug(logCategoryStrataDevStudio) << "killing HCS...";
        hcsProcess_->kill();
        if (hcsProcess_->waitForFinished(5000) == true) {
            return true;
        }
        qCCritical(logCategoryStrataDevStudio) << "Failed to kill HCS server";
        return false;
    }

    return true;
}

bool SDSModel::hcsConnected() const
{
    return hcsConnected_;
}

DocumentManager *SDSModel::documentManager() const
{
    return documentManager_;
}

CoreInterface *SDSModel::coreInterface() const
{
    return coreInterface_;
}

ResourceLoader *SDSModel::resourceLoader() const
{
    return resourceLoader_;
}

SGNewControlView *SDSModel::newControlView() const
{
    return newControlView_;
}

ProgramControllerManager *SDSModel::programControllerManager() const
{
    return programControllerManager_;
}

FirmwareManager *SDSModel::firmwareManager() const
{
    return firmwareManager_;
}

PlatformInterfaceGenerator *SDSModel::platformInterfaceGenerator() const
{
    return platformInterfaceGenerator_;
}

VisualEditorUndoStack *SDSModel::visualEditorUndoStack() const
{
    return visualEditorUndoStack_;
}

strata::sds::config::UrlConfig *SDSModel::urls() const
{
    return urlConfig_;
}

strata::loggers::QtLogger *SDSModel::qtLogger() const
{
    return std::addressof(strata::loggers::QtLogger::instance());
}

strata::strataRPC::StrataClient *SDSModel::strataClient() const
{
    return strataClient_;
}

void SDSModel::shutdownService()
{
    remoteHcsNode_->shutdownService(hcsIdentifier_);
}

void SDSModel::startedProcess()
{
    qCInfo(logCategoryStrataDevStudio) << "HCS started";

    setHcsConnected(true);
}

void SDSModel::finishHcsProcess(int exitCode, QProcess::ExitStatus exitStatus)
{
    qCDebug(logCategoryStrataDevStudio)
        << "exitStatus=" << exitStatus
        << "exitCode=" << exitCode;

    hcsProcess_->deleteLater();
    hcsProcess_.clear();

    if (exitStatus == QProcess::NormalExit && exitCode == (EXIT_FAILURE + 1)) {
        // LC: todo; there was another HCS instance; new one is going down
        qCDebug(logCategoryStrataDevStudio) << "Quitting - another HCS instance was running";
        return;
    }

    if (killHcsSilently == false) {
        setHcsConnected(false);
    }
}

void SDSModel::handleHcsProcessError(QProcess::ProcessError error)
{
    qCDebug(logCategoryStrataDevStudio) << error << hcsProcess_->errorString();
}

void SDSModel::setHcsConnected(bool hcsConnected)
{
    if (hcsConnected_ == hcsConnected) {
        return;
    }

    hcsConnected_ = hcsConnected;
    emit hcsConnectedChanged();
}

QString SDSModel::openLogViewer()
{
    QDir applicationDir(QCoreApplication::applicationDirPath());
    #ifdef Q_OS_MACOS
        applicationDir.cdUp();
        applicationDir.cdUp();
        applicationDir.cdUp();
        const QString logViewerPath = applicationDir.filePath("Log Viewer.app/Contents/MacOS/Log Viewer");
    #elif defined(Q_OS_WIN)
        const QString logViewerPath = applicationDir.filePath("Log Viewer.exe");
    #else
        const QString logViewerPath = applicationDir.filePath("Log Viewer");
    #endif

    QFileInfo logViewerInfo(logViewerPath);
    if (logViewerInfo.exists() == false) {
        qCCritical(logCategoryStrataDevStudio) << "Log Viewer at location " + logViewerPath + " does not exist.";
        return "Log Viewer not found.";
    }
    if (logViewerInfo.isExecutable() == false) {
        qCCritical(logCategoryStrataDevStudio) << "Log Viewer at location " + logViewerPath + " is not executable file.";
        return  "Log Viewer is not executable file.";
    }

    QDir logDir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));
    logDir.cdUp();
    const QString sdsLog = QDir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)).filePath("Strata Developer Studio.log");
    const QString hcsLog = logDir.filePath("Host Controller Service/Host Controller Service.log");
    if (QProcess::startDetached(logViewerPath, {sdsLog, hcsLog}) == false) {
        qCCritical(logCategoryStrataDevStudio) << "Log Viewer from location " + logViewerPath + " with log files " + sdsLog + " and " + hcsLog + " failed to start.";
        return "Log Viewer failed to start.";
    }

    return "";
}
