#include "SDSModel.h"
#include "DocumentManager.h"
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
    coreInterface_ = new CoreInterface(this);
    documentManager_ = new DocumentManager(coreInterface_, this);
}

SDSModel::~SDSModel()
{
    delete documentManager_;
    delete coreInterface_;
}

void SDSModel::init(const QString &appDirPath, const QString &configFilename)
{
    appDirPath_ = appDirPath;
    configFilename_ = configFilename;

    remoteHcsNode_ = new HcsNode(this);

    connect(remoteHcsNode_, &HcsNode::hcsConnectedChanged,
            this, &SDSModel::setHcsConnected);

}

bool SDSModel::startHcs()
{
    if (hcsProcess_.isNull() == false) {
        return false;
    }

    if (appDirPath_.isEmpty() || configFilename_.isEmpty()) {
        return false;
    }

#ifdef Q_OS_WIN
#if WINDOWS_INSTALLER_BUILD
    const QString hcsPath{ QDir::cleanPath(QString("%1/hcs.exe").arg(appDirPath_)) };
    QString hcsConfigPath;
    TCHAR programDataPath[MAX_PATH];
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_APPDATA, NULL, 0, programDataPath))) {
        hcsConfigPath = QDir::cleanPath(QString("%1/ON Semiconductor/Strata Developer Studio/HCS/hcs.config").arg(programDataPath));
        qCInfo(logCategoryStrataDevStudio) << QStringLiteral("hcsConfigPath:") << hcsConfigPath ;
    }else{
        qCCritical(logCategoryStrataDevStudio) << "Failed to get ProgramData path using windows API call...";
        return false;
    }
#else
    const QString hcsPath{ QDir::cleanPath(QString("%1/hcs.exe").arg(appDirPath_)) };
    const QString hcsConfigPath{ QDir::cleanPath(QString("%1/../../apps/hcs3/files/conf/%2").arg(appDirPath_, configFilename_))};
#endif
#endif
#ifdef Q_OS_MACOS
    const QString hcsPath{ QDir::cleanPath(QString("%1/../../../hcs").arg(appDirPath_)) };
    const QString hcsConfigPath{ QDir::cleanPath( QString("%1/../../../../../apps/hcs3/files/conf/%2").arg(appDirPath_, configFilename_))};
#endif
#ifdef Q_OS_LINUX
    const QString hcsPath{ QDir::cleanPath(QString("%1/hcs").arg(app.applicationDirPath())) };
    const QString hcsConfigPath{ QDir::cleanPath(QString("%1/../../apps/hcs3/files/conf/host_controller_service.config").arg(app.applicationDirPath()))};
#endif

    // Start HCS before handling events for Qt

    if (QFile::exists(hcsPath)) {
        hcsProcess_ = new QProcess(this);

        connect(hcsProcess_, qOverload<int, QProcess::ExitStatus>(&QProcess::finished),
                this, &SDSModel::finishHcsProcess);

        connect(hcsProcess_, &QProcess::errorOccurred,
                this, &SDSModel::handleHcsProcessError);

        forwardHcsOutput();

        QStringList arguments;
        arguments << "-f" << hcsConfigPath;

        qCDebug(logCategoryStrataDevStudio) << "Starting HCS: " << hcsPath << "(" << hcsConfigPath << ")";

        hcsProcess_->start(hcsPath, arguments, QIODevice::ReadWrite);
        if (hcsProcess_->waitForStarted() == false) {
            qCWarning(logCategoryStrataDevStudio) << "Process does not started yet (state:" << hcsProcess_->state() << ")";
            return false;
        }
        qCInfo(logCategoryStrataDevStudio) << "HCS started";
    } else {
        qCCritical(logCategoryStrataDevStudio) << "Failed to start HCS: does not exist";
        return false;
    }

    setHcsConnected(true);
    return true;
}

bool SDSModel::killHcs()
{
    if (hcsProcess_.isNull()) {
        return false;
    }

#ifdef Q_OS_WIN // windows check to kill hcs3
    // [PV] : In windows, QProcess terminate will not send any close message to QT non GUI application
    // Waiting for 10s before kill, if user runs an instance of SDS immediately after closing, hcs3
    // will not be terminated and new hcs insatnce will start, leaving two instances of hcs.
    if (hcsProcess_->state() == QProcess::Running) {
        qCDebug(logCategoryStrataDevStudio) << "killing HCS";
        hcsProcess_->kill();
        if (hcsProcess_->waitForFinished() == false) {
            qCWarning(logCategoryStrataDevStudio) << "Failed to kill HCS server";
            return false;
        }
    }
#else
    if (hcsProcess_->state() == QProcess::Running) {
        qCDebug(logCategoryStrataDevStudio) << "terminating HCS";
        hcsProcess_->terminate();
        QThread::msleep(100);   //This needs to be here, otherwise 'waitForFinished' waits until timeout
        if (hcsProcess_->waitForFinished(10000) == false) {
            qCDebug(logCategoryStrataDevStudio) << "termination failed, killing HCS";
            hcsProcess_->kill();
            if (hcsProcess_->waitForFinished() == false) {
                qCWarning(logCategoryStrataDevStudio) << "Failed to kill HCS server";
                return false;
            }
        }
    }
#endif

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

void SDSModel::shutdownService()
{
    remoteHcsNode_->shutdownService();
}

void SDSModel::finishHcsProcess(int exitCode, QProcess::ExitStatus exitStatus)
{
    qCDebug(logCategoryStrataDevStudio)
            << "exitCode=" << exitCode
            << "exitStatus=" << exitStatus;

    hcsProcess_->deleteLater();
    hcsProcess_.clear();

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

void SDSModel::forwardHcsOutput()
{
    // XXX: [LC] temporary solutions until Strata Monitor takeover 'hcs' service management
    QObject::connect(hcsProcess_, &QProcess::readyReadStandardOutput, [&]() {
        QByteArray stdOut = hcsProcess_->readAllStandardOutput();
        const QString hscMsg{QString::fromLatin1(stdOut)};
        for (const auto& line : hscMsg.split(QRegExp("\n|\r\n|\r"))) {
            qCDebug(logCategoryHcs) << line;
        }
    } );
    QObject::connect(hcsProcess_, &QProcess::readyReadStandardError, [&]() {
        const QString hscMsg{QString::fromLatin1(hcsProcess_->readAllStandardError())};
        for (const auto& line : hscMsg.split(QRegExp("\n|\r\n|\r"))) {
            qCCritical(logCategoryHcs) << line;
        }
    });
    // XXX: [LC] end
}
