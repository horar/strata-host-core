/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SDSModel.h"

#include "DocumentManager.h"
#include "SGNewControlView.h"
#include "HcsNode.h"
#include "ResourceLoader.h"
#include "FileDownloader.h"
#include "PlatformInterfaceGenerator.h"
#include "VisualEditorUndoStack.h"
#include "logging/LoggingQtCategories.h"
#ifdef APPS_FEATURE_BLE
#include "BleDeviceModel.h"
#endif // APPS_FEATURE_BLE
#include "FirmwareUpdater.h"
#include "PlatformOperation.h"

#include <PlatformInterface/core/CoreInterface.h>
#include <StrataRPC/StrataClient.h>

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
      strataClient_(new strata::strataRPC::StrataClient(dealerAddress.toString(), QByteArray(), strata::strataRPC::default_check_reply_interval, strata::strataRPC::default_reply_expiration_time, this)),
      coreInterface_(new CoreInterface(strataClient_, this)),
      documentManager_(new DocumentManager(strataClient_, coreInterface_, this)),
      resourceLoader_(new ResourceLoader(this)),
      fileDownloader_(new FileDownloader(strataClient_, coreInterface_, this)),
      newControlView_(new SGNewControlView(this)),
      firmwareUpdater_(new FirmwareUpdater(strataClient_, coreInterface_, this)),
      platformInterfaceGenerator_(new PlatformInterfaceGenerator(this)),
      visualEditorUndoStack_(new VisualEditorUndoStack(this)),
      remoteHcsNode_(new HcsNode(this)),
      urlConfig_(new strata::sds::config::UrlConfig(configFilePath, this)),
      platformOperation_(new PlatformOperation(strataClient_, this)),
#ifdef APPS_FEATURE_BLE
      bleDeviceModel_(new BleDeviceModel(strataClient_, coreInterface_, this)),
#endif // APPS_FEATURE_BLE
      hcsIdentifier_(QRandomGenerator::global()->bounded(0x00000001u, 0xFFFFFFFFu)) // skips 0
{
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
    delete firmwareUpdater_;
    delete urlConfig_;
    delete strataClient_;
    delete platformOperation_;
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
        hcsConfigPath = QDir::cleanPath(QString("%1/onsemi/HCS/hcs.config").arg(programDataPath));
        qCInfo(lcDevStudio) << QStringLiteral("hcsConfigPath:") << hcsConfigPath;
    }else{
        qCCritical(lcDevStudio) << "Failed to get ProgramData path using windows API call...";
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

        qCDebug(lcDevStudio) << "Starting HCS:" << hcsPath << "(" << hcsConfigPath << "), identifier:" << hcsIdentifier_;

        hcsProcess_->start(hcsPath, arguments, QIODevice::ReadWrite);
        if (hcsProcess_->waitForStarted() == false) {
            qCWarning(lcDevStudio) << "Process does not started yet (state:" << hcsProcess_->state() << ")";
            return false;
        }
    } else {
        qCCritical(lcDevStudio) << "Failed to start HCS: does not exist";
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
        qCDebug(lcDevStudio) << "waiting for HCS gracefull finish...";
        if (hcsProcess_->waitForFinished(5000) == true) {
            return true;
        }

#ifdef Q_OS_UNIX
        qCDebug(lcDevStudio) << "terminating HCS...";
        hcsProcess_->terminate();
        QThread::msleep(100);   //This needs to be here, otherwise 'waitForFinished' waits until timeout
        if (hcsProcess_->waitForFinished(5000) == true) {
            return true;
        }
        qCWarning(lcDevStudio) << "Failed to terminate the server";
#endif

        qCDebug(lcDevStudio) << "killing HCS...";
        hcsProcess_->kill();
        if (hcsProcess_->waitForFinished(5000) == true) {
            return true;
        }
        qCCritical(lcDevStudio) << "Failed to kill HCS server";
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

FileDownloader *SDSModel::fileDownloader() const
{
    return fileDownloader_;
}

SGNewControlView *SDSModel::newControlView() const
{
    return newControlView_;
}

FirmwareUpdater *SDSModel::firmwareUpdater() const
{
    return firmwareUpdater_;
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

#ifdef APPS_FEATURE_BLE
BleDeviceModel *SDSModel::bleDeviceModel() const
{
    return bleDeviceModel_;
}
#endif // APPS_FEATURE_BLE

strata::strataRPC::StrataClient *SDSModel::strataClient() const
{
    return strataClient_;
}

PlatformOperation *SDSModel::platformOperation() const
{
    return platformOperation_;
}

bool SDSModel::debugFeaturesEnabled()
{
    return debugFeaturesEnabled_;
}

void SDSModel::setDebugFeaturesEnabled(bool enabled)
{
    if (debugFeaturesEnabled_ != enabled) {
        debugFeaturesEnabled_ = enabled;
        emit debugFeaturesEnabledChanged();
    }
}

void SDSModel::shutdownService()
{
    remoteHcsNode_->shutdownService(hcsIdentifier_);
}

void SDSModel::startedProcess()
{
    qCInfo(lcDevStudio) << "HCS started";

    setHcsConnected(true);
}

void SDSModel::finishHcsProcess(int exitCode, QProcess::ExitStatus exitStatus)
{
    qCDebug(lcDevStudio)
        << "exitStatus=" << exitStatus
        << "exitCode=" << exitCode;

    hcsProcess_->deleteLater();
    hcsProcess_.clear();

    if (exitStatus == QProcess::NormalExit && exitCode == (EXIT_FAILURE + 1)) {
        // LC: todo; there was another HCS instance; new one is going down
        qCDebug(lcDevStudio) << "Quitting - another HCS instance was running";
        return;
    }

    if (killHcsSilently == false) {
        setHcsConnected(false);
    }
}

void SDSModel::handleHcsProcessError(QProcess::ProcessError error)
{
    qCDebug(lcDevStudio) << error << hcsProcess_->errorString();
}

void SDSModel::setHcsConnected(bool hcsConnected)
{
    if (hcsConnected_ == hcsConnected) {
        return;
    }

    hcsConnected_ = hcsConnected;

    if (true == hcsConnected_) {
        strataClient_->initializeAndConnect();
    } else {
        strataClient_->disconnect();
    }

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
        qCCritical(lcDevStudio) << "Log Viewer at location " + logViewerPath + " does not exist.";
        return "Log Viewer not found.";
    }
    if (logViewerInfo.isExecutable() == false) {
        qCCritical(lcDevStudio) << "Log Viewer at location " + logViewerPath + " is not executable file.";
        return  "Log Viewer is not executable file.";
    }

    QDir logDir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));
    logDir.cdUp();
    const QString sdsLog = QDir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)).filePath("Strata Developer Studio.log");
    const QString hcsLog = logDir.filePath("Host Controller Service/Host Controller Service.log");
    if (QProcess::startDetached(logViewerPath, {sdsLog, hcsLog}) == false) {
        qCCritical(lcDevStudio) << "Log Viewer from location " + logViewerPath + " with log files " + sdsLog + " and " + hcsLog + " failed to start.";
        return "Log Viewer failed to start.";
    }

    return "";
}

void SDSModel::handleQmlWarning(const QList<QQmlError> &warnings)
{
    QStringList msg;
    foreach (const QQmlError &error, warnings) {
        msg << error.toString();
    }
    emit notifyQmlError(msg.join(QStringLiteral("\n")));
}
