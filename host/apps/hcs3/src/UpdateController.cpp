#include <QtAlgorithms>

#include "UpdateController.h"
#include "FirmwareUpdater.h"
#include "BoardController.h"

#include <Device/Device.h>

#include "logging/LoggingQtCategories.h"

UpdateController::UpdateController() :
    boardController_(nullptr), downloadManager_(nullptr)
{
}

UpdateController::~UpdateController()
{
    for (auto it = updates_.constBegin(); it != updates_.constEnd(); ++it) {
        FirmwareUpdater *fwUpdater = it.value()->fwUpdater;
        fwUpdater->disconnect();
        delete fwUpdater;
        delete it.value();
    }
}

void UpdateController::initialize(const BoardController* boardController, strata::DownloadManager* downloadManager)
{
    boardController_ = boardController;
    downloadManager_ = downloadManager;
}

void UpdateController::updateFirmware(const QByteArray& clientId, const int deviceId, const QUrl& firmwareUrl, const QString& firmwareMD5)
{
    if (boardController_ == nullptr || downloadManager_ == nullptr) {
        QString errStr("UpdateController is not properly initialized.");
        qCCritical(logCategoryHcsFwUpdater).noquote() << errStr;
        emit updaterError(deviceId, errStr);
        return;
    }

    auto it = updates_.constFind(deviceId);
    if (it != updates_.constEnd()) {
        QString errStr("Cannot update, another update is running.");
        qCCritical(logCategoryHcsFwUpdater).noquote() << errStr;
        emit updaterError(deviceId, errStr);
        return;
    }

    strata::device::DevicePtr device = boardController_->getDevice(deviceId);
    if (device == nullptr) {
        QString errStr("Incorrect device ID for update.");
        qCCritical(logCategoryHcsFwUpdater).noquote() << errStr;
        emit updaterError(deviceId, errStr);
        return;
    }

    FirmwareUpdater *fwUpdater = new FirmwareUpdater(device, downloadManager_, firmwareUrl, firmwareMD5);
    UpdateData *updateData = new UpdateData(clientId, fwUpdater);
    updates_.insert(deviceId, updateData);

    connect(fwUpdater, &FirmwareUpdater::updateProgress, this, &UpdateController::handleUpdateProgress);
    connect(fwUpdater, &FirmwareUpdater::updaterError, this, &UpdateController::updaterError);

    fwUpdater->updateFirmware();
}

void UpdateController::handleUpdateProgress(int deviceId, UpdateOperation operation, UpdateStatus status, int complete, int total, QString errorString)
{
    if (updates_.contains(deviceId) == false) {
        return;
    }

    UpdateData *updateData = updates_.value(deviceId);
    UpdateProgress *progress = &(updateData->updateProgress);

    progress->operation = operation;
    progress->status = status;
    progress->complete = complete;
    progress->total = total;

    if (errorString.isEmpty() == false) {
        switch (operation) {
        case UpdateOperation::Download :
            progress->downloadError = errorString;
            break;
        case UpdateOperation::Prepare :
            break;
        case UpdateOperation::Backup :
            progress->backupError = errorString;
            break;
        case UpdateOperation::Flash :
            progress->flashError = errorString;
            break;
        case UpdateOperation::Restore :
            progress->restoreError = errorString;
            break;
        case UpdateOperation::Finished :
            break;
        }
    }

    emit progressOfUpdate(deviceId, updateData->clientId, *progress);

    if (operation == UpdateOperation::Finished) {
        updateData->fwUpdater->deleteLater();
        delete updateData;
        updates_.remove(deviceId);
    }
}

UpdateController::UpdateData::UpdateData(const QByteArray& client, FirmwareUpdater* updater) :
    clientId(client), fwUpdater(updater)
{
}
