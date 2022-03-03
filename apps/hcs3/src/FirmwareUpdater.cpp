/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "FirmwareUpdater.h"

#include <QDir>
#include <QList>

#include <DownloadManager.h>

#include "logging/LoggingQtCategories.h"

using strata::DownloadManager;
using strata::FlasherConnector;

namespace deviceOperation = strata::device::operation;

FirmwareUpdater::FirmwareUpdater(
        const strata::platform::PlatformPtr& platform,
        strata::DownloadManager *downloadManager,
        const QUrl& url,
        const QString& md5,
        const QString& fwClassId)
    : running_(false),
      platform_(platform),
      deviceId_(platform->deviceId()),
      downloadManager_(downloadManager),
      firmwareUrl_(url),
      firmwareMD5_(md5),
      firmwareFile_(QDir(QDir::tempPath()).filePath(QStringLiteral("hcs_new_firmware"))),
      fwClassId_(fwClassId)
{
    connect(this, &FirmwareUpdater::flashFirmware, this, &FirmwareUpdater::handleFlashFirmware, Qt::QueuedConnection);
}

FirmwareUpdater::FirmwareUpdater(
        const strata::platform::PlatformPtr& platform,
        const QString& fwClassId)
    : FirmwareUpdater(platform, nullptr, QString(), QString(), fwClassId)
{ }

FirmwareUpdater::~FirmwareUpdater()
{
    if (flasherConnector_.isNull() == false) {
        flasherConnector_->disconnect();
        flasherConnector_->stop();
        flasherConnector_->deleteLater();
    }
}

void FirmwareUpdater::updateFirmware(bool backupOldFirmware)
{
    if (running_) {
        logAndEmitError(QStringLiteral("Cannot update firmware, update is already running."));
        return;
    }

    if (downloadManager_.isNull()) {
        logAndEmitError(QStringLiteral("Download manager is not set."));
        return;
    }

    if (firmwareUrl_.isEmpty()) {
        logAndEmitError(QStringLiteral("Firmware URL was not provided."));
        return;
    }

    if (firmwareFile_.open() == false) {
        logAndEmitError(QStringLiteral("Cannot create temporary file for firmware download."));
        return;
    }
    // file is created on disk, no need to keep descriptor open
    firmwareFile_.close();

    running_ = true;
    backupOldFirmware_ = backupOldFirmware;

    downloadFirmware();
}

void FirmwareUpdater::setFwClassId()
{
    if (fwClassId_.isNull()) {
        logAndEmitError(QStringLiteral("Firmware class ID was not provided."));
        running_ = false;
        return;
    }

    running_ = true;

    flasherConnector_ = new FlasherConnector(fwClassId_, platform_, this);

    connect(flasherConnector_, &FlasherConnector::finished, this, &FirmwareUpdater::handleFlasherFinished);
    connect(flasherConnector_, &FlasherConnector::operationStateChanged, this, &FirmwareUpdater::handleOperationStateChanged);
    connect(flasherConnector_, &FlasherConnector::bootloaderActive, this, &FirmwareUpdater::handleBootloaderActive);
    connect(flasherConnector_, &FlasherConnector::applicationActive, this, &FirmwareUpdater::handleApplicationActive);

    flasherConnector_->setFwClassId(strata::Flasher::FinalAction::StartApplication);
}

void FirmwareUpdater::updateFinished(FirmwareUpdateController::UpdateStatus status)
{
    emit updateProgress(deviceId_, FirmwareUpdateController::UpdateOperation::Finished, status);
    running_ = false;
}

void FirmwareUpdater::downloadFirmware()
{
    QList<DownloadManager::DownloadRequestItem> downloadRequestList;

    DownloadManager::DownloadRequestItem firmwareItem;
    firmwareItem.url = firmwareUrl_;
    firmwareItem.md5 = firmwareMD5_;
    firmwareItem.filePath = firmwareFile_.fileName();
    downloadRequestList << firmwareItem;

    DownloadManager::Settings settings;
    settings.notifySingleDownloadProgress = true;
    settings.keepOriginalName = true;
    settings.oneFailsAllFail = true;
    settings.removeCorruptedFile = false;

    connect(downloadManager_, &DownloadManager::groupDownloadFinished, this, &FirmwareUpdater::handleDownloadFinished);
    connect(downloadManager_, &DownloadManager::singleDownloadProgress, this, &FirmwareUpdater::handleSingleDownloadProgress);

    downloadId_ = downloadManager_->download(downloadRequestList, settings);

    qCDebug(lcHcsFwUpdater).nospace().noquote() << "Downloading new firmware for device"
        << deviceId_ << " to '" << firmwareFile_.fileName() << "'. Download ID: '" << downloadId_ <<"'.";
}

void FirmwareUpdater::handleDownloadFinished(QString downloadId, QString errorString)
{
    if (downloadId != downloadId_) {
        return;
    }

    disconnect(downloadManager_, nullptr, this, nullptr);

    if (errorString.isEmpty() == false) {
        emit updateProgress(deviceId_, FirmwareUpdateController::UpdateOperation::Download, FirmwareUpdateController::UpdateStatus::Failure, -1, -1, errorString);
        updateFinished(FirmwareUpdateController::UpdateStatus::Unsuccess);
        return;
    }

    emit flashFirmware(QPrivateSignal());
}

void FirmwareUpdater::handleSingleDownloadProgress(QString downloadId, QString filePath, qint64 bytesReceived, qint64 bytesTotal)
{
    Q_UNUSED(filePath)

    if (downloadId == downloadId_) {
        emit updateProgress(deviceId_, FirmwareUpdateController::UpdateOperation::Download, FirmwareUpdateController::UpdateStatus::Running, bytesReceived, bytesTotal);
    }
}

void FirmwareUpdater::handleFlashFirmware()
{
    if (flasherConnector_.isNull() == false) {
        QString errStr("Cannot create firmware flasher, other one already exists.");
        qCCritical(lcHcsFwUpdater) << platform_ << errStr;
        emit updateProgress(deviceId_, FirmwareUpdateController::UpdateOperation::Finished, FirmwareUpdateController::UpdateStatus::Unsuccess);
        emit updaterError(deviceId_, errStr);
        return;
    }

    if (fwClassId_.isNull()) {
        flasherConnector_ = new FlasherConnector(platform_, firmwareFile_.fileName(), firmwareMD5_, this);
    } else {
        flasherConnector_ = new FlasherConnector(platform_, firmwareFile_.fileName(), firmwareMD5_, fwClassId_, this);
    }

    connect(flasherConnector_, &FlasherConnector::finished, this, &FirmwareUpdater::handleFlasherFinished);
    connect(flasherConnector_, &FlasherConnector::flashProgress, this, &FirmwareUpdater::handleFlashProgress);
    connect(flasherConnector_, &FlasherConnector::backupProgress, this, &FirmwareUpdater::handleBackupProgress);
    connect(flasherConnector_, &FlasherConnector::restoreProgress, this, &FirmwareUpdater::handleRestoreProgress);
    connect(flasherConnector_, &FlasherConnector::operationStateChanged, this, &FirmwareUpdater::handleOperationStateChanged);
    connect(flasherConnector_, &FlasherConnector::bootloaderActive, this, &FirmwareUpdater::handleBootloaderActive);
    connect(flasherConnector_, &FlasherConnector::applicationActive, this, &FirmwareUpdater::handleApplicationActive);

    flasherConnector_->flash(backupOldFirmware_);
}

void FirmwareUpdater::handleFlasherFinished(FlasherConnector::Result result)
{
    flasherConnector_->deleteLater();

    firmwareFile_.remove();

    FirmwareUpdateController::UpdateStatus status = FirmwareUpdateController::UpdateStatus::Failure;
    switch (result) {
    case FlasherConnector::Result::Success :
        status = FirmwareUpdateController::UpdateStatus::Success;
        break;
    case FlasherConnector::Result::Unsuccess :
        status = FirmwareUpdateController::UpdateStatus::Unsuccess;
        break;
    case FlasherConnector::Result::Failure :
        status = FirmwareUpdateController::UpdateStatus::Failure;
        break;
    }

    updateFinished(status);
}

void FirmwareUpdater::handleFlashProgress(int chunk, int total)
{
    emit updateProgress(deviceId_, FirmwareUpdateController::UpdateOperation::Flash, FirmwareUpdateController::UpdateStatus::Running, chunk, total);
}

void FirmwareUpdater::handleBackupProgress(int chunk, int total)
{
    emit updateProgress(deviceId_, FirmwareUpdateController::UpdateOperation::Backup, FirmwareUpdateController::UpdateStatus::Running, chunk, total);
}

void FirmwareUpdater::handleRestoreProgress(int chunk, int total)
{
    emit updateProgress(deviceId_, FirmwareUpdateController::UpdateOperation::Restore, FirmwareUpdateController::UpdateStatus::Running, chunk, total);
}

void FirmwareUpdater::handleOperationStateChanged(FlasherConnector::Operation operation, FlasherConnector::State state, QString errorString)
{
    FirmwareUpdateController::UpdateStatus updStatus = FirmwareUpdateController::UpdateStatus::Failure;

    switch (state) {
    case FlasherConnector::State::Started :
        updStatus = FirmwareUpdateController::UpdateStatus::Running;
        break;
    case FlasherConnector::State::Finished :
        // We do not care about end of any operation.
        return;
    case FlasherConnector::State::Cancelled :
    case FlasherConnector::State::Failed :
    case FlasherConnector::State::NoFirmware :
    case FlasherConnector::State::BadFirmware :
        updStatus = FirmwareUpdateController::UpdateStatus::Failure;
        break;
    }

    FirmwareUpdateController::UpdateOperation updOperation;
    bool withoutProgress = false;

    switch (operation) {
    case FlasherConnector::Operation::Preparation :
        updOperation = FirmwareUpdateController::UpdateOperation::Prepare;
        withoutProgress = true;
        break;
    case FlasherConnector::Operation::ClearFwClassId :
        updOperation = FirmwareUpdateController::UpdateOperation::ClearFwClassId;
        withoutProgress = true;
        break;
    case FlasherConnector::Operation::SetFwClassId :
        updOperation = FirmwareUpdateController::UpdateOperation::SetFwClassId;
        withoutProgress = true;
        break;
    case FlasherConnector::Operation::Flash :
        updOperation = FirmwareUpdateController::UpdateOperation::Flash;
        break;
    case FlasherConnector::Operation::Backup :
    case FlasherConnector::Operation::BackupBeforeFlash :
        updOperation = FirmwareUpdateController::UpdateOperation::Backup;
        break;
    case FlasherConnector::Operation::RestoreFromBackup :
        updOperation = FirmwareUpdateController::UpdateOperation::Restore;
        break;
    }

    // Operations with progress indication (flash, backup) are covered by handleXyProgress() slots,
    // so in this case do not emit updateProgress() signal with 'Running' status here.
    if (withoutProgress || (updStatus != FirmwareUpdateController::UpdateStatus::Running)) {
        emit updateProgress(deviceId_, updOperation, updStatus, -1, -1, errorString);
    }
}

void FirmwareUpdater::handleBootloaderActive()
{
    emit bootloaderActive(deviceId_);
}

void FirmwareUpdater::handleApplicationActive()
{
    emit applicationActive(deviceId_);
}

void FirmwareUpdater::logAndEmitError(const QString& errorString)
{
    qCCritical(lcHcsFwUpdater) << platform_ << errorString;
    emit updaterError(deviceId_, errorString);
}
