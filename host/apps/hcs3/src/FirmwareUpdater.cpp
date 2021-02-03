#include "FirmwareUpdater.h"

#include <QDir>
#include <QList>

#include <DownloadManager.h>

#include <Device/Operations/SetAssistedPlatformId.h>

#include "logging/LoggingQtCategories.h"

using strata::DownloadManager;
using strata::FlasherConnector;

namespace deviceOperation = strata::device::operation;

FirmwareUpdater::FirmwareUpdater(
        const strata::device::DevicePtr& devPtr,
        strata::DownloadManager *downloadManager,
        const QUrl& url,
        const QString& md5,
        bool programController)
    : running_(false),
      programController_(programController),
      device_(devPtr),
      deviceId_(devPtr->deviceId()),
      downloadManager_(downloadManager),
      firmwareUrl_(url),
      firmwareMD5_(md5),
      firmwareFile_(QDir(QDir::tempPath()).filePath(QStringLiteral("hcs_new_firmware"))),
      flasherFinished_(false)
{
    connect(this, &FirmwareUpdater::flashFirmware, this, &FirmwareUpdater::handleFlashFirmware, Qt::QueuedConnection);
    connect(this, &FirmwareUpdater::setFirmwareClassId, this, &FirmwareUpdater::handleSetFirmwareClassId, Qt::QueuedConnection);
}

FirmwareUpdater::~FirmwareUpdater()
{
    if (flasherConnector_.isNull() == false) {
        flasherConnector_->disconnect();
        flasherConnector_->stop();
        flasherConnector_->deleteLater();
    }

    if (setAssistPlatfIdOper_.isNull() == false) {
        setAssistPlatfIdOper_->disconnect();
        setAssistPlatfIdOper_->deleteLater();
    }
}

void FirmwareUpdater::updateFirmware()
{
    if (running_) {
        QString errStr("Cannot update firmware, update is already running.");
        qCCritical(logCategoryHcsFwUpdater) << device_ << errStr;
        emit updaterError(deviceId_, errStr);
        return;
    }

    if (firmwareFile_.open() == false) {
        QString errStr("Cannot create temporary file for firmware download.");
        qCCritical(logCategoryHcsFwUpdater) << device_ << errStr;
        emit updaterError(deviceId_, errStr);
        return;
    }
    // file is created on disk, no need to keep descriptor open
    firmwareFile_.close();

    running_ = true;

    downloadFirmware();
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

    qCDebug(logCategoryHcsFwUpdater).nospace().noquote() << "Downloading new firmware for device 0x"
        << hex << static_cast<uint>(deviceId_) << " to '" << firmwareFile_.fileName() << "'. Download ID: '" << downloadId_ <<"'.";
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

    if (programController_) {
        // clear firmware Class ID - set it to null UUID v4
        emit setFirmwareClassId(QStringLiteral("00000000-0000-4000-0000-000000000000"), QPrivateSignal());
    } else {
        emit flashFirmware(QPrivateSignal());
    }
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
    Q_ASSERT(flasherConnector_.isNull());

    flasherConnector_ = new FlasherConnector(device_, firmwareFile_.fileName(), firmwareMD5_, this);

    connect(flasherConnector_, &FlasherConnector::finished, this, &FirmwareUpdater::handleFlasherFinished);
    connect(flasherConnector_, &FlasherConnector::flashProgress, this, &FirmwareUpdater::handleFlashProgress);
    connect(flasherConnector_, &FlasherConnector::backupProgress, this, &FirmwareUpdater::handleBackupProgress);
    connect(flasherConnector_, &FlasherConnector::restoreProgress, this, &FirmwareUpdater::handleRestoreProgress);
    connect(flasherConnector_, &FlasherConnector::operationStateChanged, this, &FirmwareUpdater::handleOperationStateChanged);

    // if we are flashing new firmware to assisted controller (dongle) there is no need to backup old firmware
    bool backupOldFirmware = (programController_ == false);
    flasherConnector_->flash(backupOldFirmware);
}

void FirmwareUpdater::handleSetFirmwareClassId(QString fwClassId)
{
    Q_ASSERT(setAssistPlatfIdOper_.isNull());

    qCDebug(logCategoryHcsFwUpdater) << device_ << "Going to set '" << fwClassId << "' as firmware class ID.";

    FirmwareUpdateController::UpdateOperation updateOperation = (flasherFinished_)
        ? FirmwareUpdateController::UpdateOperation::SetFwClassId
        : FirmwareUpdateController::UpdateOperation::ClearFwClassId;

    setAssistPlatfIdOper_ = new deviceOperation::SetAssistedPlatformId(device_);
    setAssistPlatfIdOper_->setFwClassId(fwClassId);

    connect(setAssistPlatfIdOper_, &deviceOperation::SetAssistedPlatformId::finished, this, &FirmwareUpdater::handleSetFirmwareClassIdFinished);

    emit updateProgress(deviceId_, updateOperation, FirmwareUpdateController::UpdateStatus::Running);

    setAssistPlatfIdOper_->run();
}

void FirmwareUpdater::handleFlasherFinished(FlasherConnector::Result result)
{
    flasherConnector_->deleteLater();

    firmwareFile_.remove();

    flasherFinished_ = true;

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

    if (programController_ && (result == FlasherConnector::Result::Success)) {
        QString classId = device_->classId();
        if (classId.isEmpty() == false) {
            emit setFirmwareClassId(classId, QPrivateSignal());
        } else {
            QString errStr("Device has no class ID, cannot set firmware class ID.");
            qCWarning(logCategoryHcsFwUpdater) << device_ << errStr;
            emit updateProgress(deviceId_, FirmwareUpdateController::UpdateOperation::SetFwClassId, FirmwareUpdateController::UpdateStatus::Failure, -1, -1, errStr);
            updateFinished(FirmwareUpdateController::UpdateStatus::Unsuccess);
        }
    } else {
        updateFinished(status);
    }
}

void FirmwareUpdater::handleSetFirmwareClassIdFinished(deviceOperation::Result result, int status, QString errorString)
{
    Q_UNUSED(status)

    setAssistPlatfIdOper_->deleteLater();

    FirmwareUpdateController::UpdateOperation updateOperation = (flasherFinished_)
        ? FirmwareUpdateController::UpdateOperation::SetFwClassId
        : FirmwareUpdateController::UpdateOperation::ClearFwClassId;

    if (result == deviceOperation::Result::Success) {
        if (flasherFinished_) {
            updateFinished(FirmwareUpdateController::UpdateStatus::Success);
        } else {
            emit flashFirmware(QPrivateSignal());
        }
    } else {
        QString errorMessage = QStringLiteral("Cannot set firmware class ID. ") + errorString;
        qCWarning(logCategoryHcsFwUpdater) << device_ << errorMessage;
        emit updateProgress(deviceId_, updateOperation, FirmwareUpdateController::UpdateStatus::Failure, -1, -1, errorMessage);
        updateFinished(FirmwareUpdateController::UpdateStatus::Unsuccess);
    }
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
        if (operation != FlasherConnector::Operation::Preparation) {
            // We do not care about start of any operation except 'Preparation',
            // other operations will be covered by xyProgress() signals.
            return;
        }
        updStatus = FirmwareUpdateController::UpdateStatus::Running;
        break;
    case FlasherConnector::State::Finished :
        return;  // We do not care about end of any operation.
    case FlasherConnector::State::Cancelled :
        updStatus = FirmwareUpdateController::UpdateStatus::Unsuccess;
        break;
    case FlasherConnector::State::Failed :
    case FlasherConnector::State::NoFirmware :
        updStatus = FirmwareUpdateController::UpdateStatus::Failure;
        break;
    }

    FirmwareUpdateController::UpdateOperation updOperation;

    switch (operation) {
    case FlasherConnector::Operation::Preparation :
        updOperation = FirmwareUpdateController::UpdateOperation::Prepare;
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
    default :
        // other cases are related to OTA and they are handled in develop-ota branch
        return;
    }

    emit updateProgress(deviceId_, updOperation, updStatus, -1, -1, errorString);
}
