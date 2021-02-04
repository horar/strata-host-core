#include <QtAlgorithms>

#include "FirmwareUpdateController.h"
#include "FirmwareUpdater.h"
#include "BoardController.h"

#include <Device/Device.h>
#include <DownloadManager.h>

#include "logging/LoggingQtCategories.h"

FirmwareUpdateController::FirmwareUpdateController(QObject *parent)
    : QObject(parent)
{
}

FirmwareUpdateController::~FirmwareUpdateController()
{
    for (auto it = updates_.constBegin(); it != updates_.constEnd(); ++it) {
        FirmwareUpdater *fwUpdater = it.value()->fwUpdater;
        fwUpdater->disconnect();
        delete fwUpdater;
        delete it.value();
    }
}

void FirmwareUpdateController::initialize(BoardController *boardController, strata::DownloadManager *downloadManager)
{
    boardController_ = boardController;
    downloadManager_ = downloadManager;
}

FirmwareUpdateController::UpdateProgress::UpdateProgress() :
    complete(-1), total(-1), jobUuid(QString()), programController(false)
{
}

FirmwareUpdateController::UpdateProgress::UpdateProgress(const QString& jobUuid, bool programController) :
    complete(-1), total(-1), jobUuid(jobUuid), programController(programController)
{
}

void FirmwareUpdateController::updateFirmware(UpdateFirmwareData updateData)
{
    runUpdate(updateData.clientId,
              updateData.deviceId,
              updateData.firmwareUrl,
              updateData.firmwareMD5,
              QString(),
              updateData.jobUuid);
}

void FirmwareUpdateController::programController(ProgramControllerData programData)
{
    runUpdate(programData.clientId,
              programData.deviceId,
              programData.firmwareUrl,
              programData.firmwareMD5,
              programData.firmwareClassId,
              programData.jobUuid);
}

void FirmwareUpdateController::runUpdate(const QByteArray& clientId, const int deviceId, const QUrl& firmwareUrl,
                                         const QString& firmwareMD5, const QString& firmwareClassId, const QString& jobUuid)
{
    if (boardController_.isNull() || downloadManager_.isNull()) {
        QString errStr("FirmwareUpdateController is not properly initialized.");
        qCCritical(logCategoryHcsFwUpdater).noquote() << errStr;
        emit updaterError(deviceId, errStr);
        return;
    }

    auto it = updates_.constFind(deviceId);
    if (it != updates_.constEnd()) {
        QString errStr("Cannot update, another update is running on this device.");
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

    FirmwareUpdater *fwUpdater;

    bool programController = false;
    if (firmwareClassId.isNull()) {  // update firmware
        fwUpdater = new FirmwareUpdater(device, downloadManager_, firmwareUrl, firmwareMD5);
    } else {  // program controller
        fwUpdater = new FirmwareUpdater(device, downloadManager_, firmwareUrl, firmwareMD5, firmwareClassId);
        programController = true;
    }
    UpdateData *updateData = new UpdateData(clientId, fwUpdater, jobUuid, programController);
    updates_.insert(deviceId, updateData);

    connect(fwUpdater, &FirmwareUpdater::updateProgress, this, &FirmwareUpdateController::handleUpdateProgress);
    connect(fwUpdater, &FirmwareUpdater::updaterError, this, &FirmwareUpdateController::updaterError);

    fwUpdater->updateFirmware();
}

void FirmwareUpdateController::handleUpdateProgress(int deviceId, UpdateOperation operation, UpdateStatus status, int complete, int total, QString errorString)
{
    if (updates_.contains(deviceId) == false) {
        return;
    }

    UpdateData *updateData = updates_.value(deviceId);
    UpdateProgress *progress = &(updateData->updateProgress);

    progress->operation = operation;
    progress->status = status;
    // 'updateProgress' signal has 'camplete' and 'total' set to -1 when status is 'Failure'.
    // Preserve previous progress value in this case.
    if (status != UpdateStatus::Failure) {
        progress->complete = complete;
        progress->total = total;
    }
    // UpdateOperation::Finished is special case - it has always empty errorString because
    // this operation is bind to FlasherConnector 'finished' signal which doesn't have any
    // error string. So, in this case preserve previous error string.
    if (operation != UpdateOperation::Finished) {
        progress->error = errorString;
    }

    emit progressOfUpdate(deviceId, updateData->clientId, *progress);

    if (operation == UpdateOperation::Finished) {
        updateData->fwUpdater->deleteLater();
        delete updateData;
        updates_.remove(deviceId);
    }
}

FirmwareUpdateController::UpdateData::UpdateData(const QByteArray& client, FirmwareUpdater* updater, const QString& jobUuid, bool programController) :
    clientId(client), fwUpdater(updater), updateProgress(jobUuid, programController)
{
}
