#include "SDSModel.h"
#include "DocumentManager.h"
#include "ResourceLoader.h"
#include "SGNewControlView.h"
#include "HcsNode.h"
#include <PlatformInterface/core/CoreInterface.h>

#include "logging/LoggingQtCategories.h"

#include <QFile>
#include <QDir>
#include <QThread>

#ifdef Q_OS_WIN
#include <Shlwapi.h>
#include <ShlObj.h>
#endif


SDSModel::SDSModel(QObject *parent)
    : QObject(parent), remoteHcsNode_{nullptr}
{
    resourceLoader_ = new ResourceLoader(this);
    coreInterface_ = new CoreInterface(this);
    newControlView_ = new SGNewControlView(this);
    documentManager_ = new DocumentManager(coreInterface_, this);
}

SDSModel::~SDSModel()
{
    delete documentManager_;
    delete coreInterface_;
    delete resourceLoader_;
    delete newControlView_;
}

void SDSModel::init(const QString &appDirPath)
{
    appDirPath_ = appDirPath;

    remoteHcsNode_ = new HcsNode(this);

    connect(remoteHcsNode_, &HcsNode::hcsConnectedChanged,
            this, &SDSModel::setHcsConnected);
}

bool SDSModel::startHcs()
{
    if (hcsProcess_.isNull() == false) {
        return false;
    }

    if (appDirPath_.isEmpty()) {
        return false;
    }

#ifdef Q_OS_WIN
    const QString hcsPath{ QDir::cleanPath(QString("%1/hcs.exe").arg(appDirPath_)) };
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
    const QString hcsConfigPath{ QDir::cleanPath(QString("%1/hcs.config").arg(appDirPath_)) };
#endif
#endif

#ifdef Q_OS_MACOS
    const QString hcsPath{ QDir::cleanPath(QString("%1/../../../hcs").arg(appDirPath_)) };
    const QString hcsConfigPath{ QDir::cleanPath( QString("%1/../../../hcs.config").arg(appDirPath_)) };
#endif

#ifdef Q_OS_LINUX
    const QString hcsPath{ QDir::cleanPath(QString("%1/hcs").arg(appDirPath_)) };
    const QString hcsConfigPath{ QDir::cleanPath(QString("%1/hcs.config").arg(appDirPath_))};
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

        qCDebug(logCategoryStrataDevStudio) << "Starting HCS: " << hcsPath << "(" << hcsConfigPath << ")";

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

void SDSModel::shutdownService()
{
    if (externalHcsConnected_) {
        qCDebug(logCategoryStrataDevStudio) << "connected to externally started HCS; skipping shutdown request";
        return;
    }

    remoteHcsNode_->shutdownService();
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

    if (exitStatus == QProcess::NormalExit && exitCode == (EXIT_FAILURE + 1))
    {
        // LC: todo; there was another HCS instance; new one is going down
        qCDebug(logCategoryStrataDevStudio) << "Quitting - another HCS instance was running";
        externalHcsConnected_ = true;
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
