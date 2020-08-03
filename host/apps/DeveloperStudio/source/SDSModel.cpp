#include "SDSModel.h"
#include "DocumentManager.h"
#include "HcsNode.h"
#include <PlatformInterface/core/CoreInterface.h>

#include "logging/LoggingQtCategories.h"

#include <QFile>
#include <QDir>
#include <QThread>
#include <QIcon>
#include <QMessageBox>
#include <QInputDialog>
#include <QVersionNumber>
#include <QCoreApplication>

#ifdef Q_OS_WIN
#include <Shlwapi.h>
#include <ShlObj.h>
#endif


SDSModel::SDSModel(QObject *parent)
    : QObject(parent), remoteHcsNode_{nullptr}
{
    coreInterface_ = new CoreInterface(this);
    documentManager_ = new DocumentManager(coreInterface_, this);

    connect(coreInterface_, &CoreInterface::latestReleaseVersionAcquireFinished, this, &SDSModel::latestReleaseVersionAcquireFinishedHandler);
    connect(coreInterface_, &CoreInterface::updateApplicationExecutionFinished, this, &SDSModel::updateApplicationExecutionFinishedHandler);
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

void SDSModel::latestReleaseVersionAcquireFinishedHandler(const QJsonObject &payload)
{
    QString errorString = payload["error_string"].toString();

    if (errorString.isEmpty() == false) {
        qCCritical(logCategoryStrataDevStudio) << "acquisition of latest release version finished with error: " << errorString;
        // TODO: display to user some error message if he initiated the update
        return;
    }

    QString currentVersion = payload["current_version"].toString();
    QString latestVersion = payload["latest_version"].toString();

    if(currentVersion.isEmpty() || currentVersion == "N/A" || latestVersion.isEmpty() || latestVersion == "N/A") {
        qCCritical(logCategoryStrataDevStudio) << "acquisition of latest release version failed, currentVersion: " << currentVersion << ", latestVersion: " << latestVersion;
        // TODO: display to user some error message if he initiated the update
        return;
    }

    int suffixIndexCurrent;
    int suffixIndexLatest;
    QVersionNumber currentVersionParsed = QVersionNumber::fromString(currentVersion, &suffixIndexCurrent);
    QVersionNumber latestVersionParsed = QVersionNumber::fromString(latestVersion, &suffixIndexLatest);

    if(currentVersionParsed.isNull() || latestVersionParsed.isNull()) {
        qCCritical(logCategoryStrataDevStudio) << "parsing of latest release version failed, currentVersion: " << currentVersion << ", latestVersion: " << latestVersion;
        // TODO: display to user some error message if he initiated the update
        return;
    }

    if(currentVersionParsed < latestVersionParsed) {
        // Ask user confirmation
        QMessageBox msgBox;
        msgBox.setText("A new version of Strata is available.");
        msgBox.setInformativeText("Do you wish to update now?");
        QPushButton* yesButton = msgBox.addButton(tr("Yes"), QMessageBox::YesRole);
        QPushButton* laterButton = msgBox.addButton(tr("Later"), QMessageBox::NoRole);
        //QPushButton* neverButton = msgBox.addButton(tr("Never"), QMessageBox::RejectRole);
        msgBox.setDefaultButton(yesButton);

        msgBox.exec();

        if (msgBox.clickedButton() == (QAbstractButton*)laterButton) {
            qCDebug(logCategoryStrataDevStudio) << "UPDATE posponed, currentVersion: " << currentVersion << ", latestVersion: " << latestVersion;
            return;
        }

        //if (msgBox.clickedButton() == (QAbstractButton*)neverButton) {
        //    return; // TBD: disable updates (in .ini file), unless manually invoked
        //}

        // Execute update
        qCDebug(logCategoryStrataDevStudio) << "UPDATE required, currentVersion: " << currentVersion << ", latestVersion: " << latestVersion;
        coreInterface_->updateApplication();
    } else {
        qCDebug(logCategoryStrataDevStudio) << "UPDATE not required, currentVersion: " << currentVersion << ", latestVersion: " << latestVersion;
    }
}

void SDSModel::updateApplicationExecutionFinishedHandler(const QJsonObject &payload)
{
    QString errorString = payload["error_string"].toString();

    if (errorString.isEmpty() == false) {
        qCCritical(logCategoryStrataDevStudio) << "execution of application update process finished with error: " << errorString;

        // Display to user some error message since he accepted update
        QMessageBox msgBox;
        msgBox.setText("The update failed.");
        msgBox.setInformativeText(errorString);
        msgBox.exec();

        return;
    }

    qCDebug(logCategoryStrataDevStudio) << "UPDATE initiated, terminating application";


    QCoreApplication::exit();
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
