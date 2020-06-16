#include "FirmwareUpdater.h"

#include <QDir>
#include <QList>

#include <DownloadManager.h>

#include "logging/LoggingQtCategories.h"

using strata::DownloadManager;
using strata::FlasherConnector;

FirmwareUpdater::FirmwareUpdater(const strata::device::DevicePtr& devPtr, DownloadManager* downloadManager, const QUrl& url, const QString& md5) :
    running_(false), device_(devPtr), deviceId_(devPtr->deviceId()), downloadManager_(downloadManager), firmwareUrl_(url), firmwareMD5_(md5),
    firmwareFile_(QDir(QDir::tempPath()).filePath(QStringLiteral("hcs_new_firmware")))
{
    connect(this, &FirmwareUpdater::flashFirmware, this, &FirmwareUpdater::handleFlashFirmware, Qt::QueuedConnection);
}

FirmwareUpdater::~FirmwareUpdater()
{
    if (flasherConnector_.isNull() == false) {
        flasherConnector_->disconnect();
        flasherConnector_->stop();
        flasherConnector_->deleteLater();
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

    running_ = true;

    downloadFirmware();
}

void FirmwareUpdater::downloadFirmware()
{
    if (firmwareFile_.open() == false) {
        QString errStr("Cannot create temporary file for firmware download.");
        qCCritical(logCategoryHcsFwUpdater) << device_ << errStr;
        emit updaterError(deviceId_, errStr);
        running_ = false;
        return;
    }

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

    connect(downloadManager_, &DownloadManager::groupDownloadFinished, this, &FirmwareUpdater::handleDownloadFinished);
    connect(downloadManager_, &DownloadManager::singleDownloadProgress, this, &FirmwareUpdater::handleSingleDownloadProgress);

    downloadId_ = downloadManager_->download(downloadRequestList, settings);

    qDebug(logCategoryHcsFwUpdater).nospace().noquote() << "Downloading new firmware for device 0x"
        << hex << static_cast<uint>(deviceId_) << " to '" << firmwareFile_.fileName() << "'. Download ID: '" << downloadId_ <<"'.";
}

void FirmwareUpdater::handleDownloadFinished(QString downloadId, QString errorString)
{
    if (downloadId != downloadId_) {
        return;
    }

    disconnect(downloadManager_, nullptr, this, nullptr);

    if (errorString.isEmpty() == false) {
        emit updateProgress(deviceId_, UpdateController::UpdateOperation::Download, UpdateController::UpdateStatus::Failure, -1, -1, errorString);
        emit updateProgress(deviceId_, UpdateController::UpdateOperation::Finished, UpdateController::UpdateStatus::Unsuccess);
        running_ = false;
        return;
    }

    emit flashFirmware(QPrivateSignal());
}

void FirmwareUpdater::handleSingleDownloadProgress(QString downloadId, QString filePath, qint64 bytesReceived, qint64 bytesTotal)
{
    Q_UNUSED(filePath)

    if (downloadId == downloadId_) {
        emit updateProgress(deviceId_, UpdateController::UpdateOperation::Download, UpdateController::UpdateStatus::Running, bytesReceived, bytesTotal);
    }
}

void FirmwareUpdater::handleFlashFirmware()
{
    if (flasherConnector_.isNull() == false) {
        QString errStr("Cannot create firmware flasher, other one already exists.");
        qCCritical(logCategoryHcsFwUpdater) << device_ << errStr;
        emit updateProgress(deviceId_, UpdateController::UpdateOperation::Finished, UpdateController::UpdateStatus::Unsuccess);
        emit updaterError(deviceId_, errStr);
        return;
    }

    flasherConnector_ = new FlasherConnector(device_, firmwareFile_.fileName() , this);

    connect(flasherConnector_.data(), &FlasherConnector::finished, this, &FirmwareUpdater::handleFlasherFinished);
    connect(flasherConnector_.data(), &FlasherConnector::flashProgress, this, &FirmwareUpdater::handleFlashProgress);
    connect(flasherConnector_.data(), &FlasherConnector::backupProgress, this, &FirmwareUpdater::handleBackupProgress);
    connect(flasherConnector_.data(), &FlasherConnector::restoreProgress, this, &FirmwareUpdater::handleRestoreProgress);
    connect(flasherConnector_.data(), &FlasherConnector::operationStateChanged, this, &FirmwareUpdater::handleOperationStateChanged);

    flasherConnector_->flash(true);
}

void FirmwareUpdater::handleFlasherFinished(FlasherConnector::Result result)
{
    flasherConnector_->deleteLater();

    firmwareFile_.remove();

    UpdateController::UpdateStatus status;
    switch (result) {
    case FlasherConnector::Result::Success :
        status = UpdateController::UpdateStatus::Success;
        break;
    case FlasherConnector::Result::Unsuccess :
        status = UpdateController::UpdateStatus::Unsuccess;
        break;
    case FlasherConnector::Result::Failure :
        status = UpdateController::UpdateStatus::Failure;
        break;
    }

    emit updateProgress(deviceId_, UpdateController::UpdateOperation::Finished, status);

    running_ = false;
}

void FirmwareUpdater::handleFlashProgress(int chunk, int total)
{
    emit updateProgress(deviceId_, UpdateController::UpdateOperation::Flash, UpdateController::UpdateStatus::Running, chunk, total);
}

void FirmwareUpdater::handleBackupProgress(int chunk)
{
    emit updateProgress(deviceId_, UpdateController::UpdateOperation::Backup, UpdateController::UpdateStatus::Running, chunk);
}

void FirmwareUpdater::handleRestoreProgress(int chunk, int total)
{
    emit updateProgress(deviceId_, UpdateController::UpdateOperation::Restore, UpdateController::UpdateStatus::Running, chunk, total);
}

void FirmwareUpdater::handleOperationStateChanged(FlasherConnector::Operation operation, FlasherConnector::State state, QString errorString)
{
    UpdateController::UpdateStatus updStatus = UpdateController::UpdateStatus::Running;

    switch (state) {
    case FlasherConnector::State::Started :
        if (operation != FlasherConnector::Operation::Preparation) {
            // We do not care about strat of any operation except 'Preparation',
            // other operations will be covered by xyProgress() signals.
            return;
        }
        break;
    case FlasherConnector::State::Finished :
        return;  // We do not care about end of any operation.
    case FlasherConnector::State::Cancelled :
        updStatus = UpdateController::UpdateStatus::Unsuccess;
        break;
    case FlasherConnector::State::Failed :
        updStatus = UpdateController::UpdateStatus::Failure;
        break;
    }

    UpdateController::UpdateOperation updOperation;

    switch (operation) {
    case FlasherConnector::Operation::Preparation :
        updOperation = UpdateController::UpdateOperation::Prepare;
        break;
    case FlasherConnector::Operation::Flash :
        updOperation = UpdateController::UpdateOperation::Flash;
        break;
    case FlasherConnector::Operation::Backup :
    case FlasherConnector::Operation::BackupBeforeFlash :
        updOperation = UpdateController::UpdateOperation::Backup;
        break;
    case FlasherConnector::Operation::RestoreFromBackup :
        updOperation = UpdateController::UpdateOperation::Restore;
        break;
    }

    emit updateProgress(deviceId_, updOperation, updStatus, -1, -1, errorString);
}
