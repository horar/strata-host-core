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
    complete(-1), total(-1), jobUuid(QString()), workWithController(false)
{
}

FirmwareUpdateController::UpdateProgress::UpdateProgress(const QString& jobUuid, bool workWithController) :
    complete(-1), total(-1), jobUuid(jobUuid), workWithController(workWithController)
{
}

void FirmwareUpdateController::updateFirmware(UpdateFirmwareData updateData)
{
    FlashData data;
    data.action = Action::UpdateFirmware;
    data.clientId = updateData.clientId;
    data.deviceId = updateData.deviceId;
    data.firmwareUrl = updateData.firmwareUrl;
    data.firmwareMD5 = updateData.firmwareMD5;
    data.jobUuid = updateData.jobUuid;

    runUpdate(data);
}

void FirmwareUpdateController::programController(ProgramControllerData programData)
{
    if (programData.firmwareClassId.isNull()) {
        logAndEmitError(programData.deviceId,
                        QStringLiteral("Cannot program controller - firmware class ID was not provided."));
        return;
    }

    FlashData data;
    data.action = Action::ProgramController;
    data.clientId = programData.clientId;
    data.deviceId = programData.deviceId;
    data.firmwareUrl = programData.firmwareUrl;
    data.firmwareMD5 = programData.firmwareMD5;
    data.firmwareClassId = programData.firmwareClassId;
    data.jobUuid = programData.jobUuid;

    runUpdate(data);
}

void FirmwareUpdateController::setControllerFwClassId(ProgramControllerData programData)
{
    if (programData.firmwareClassId.isNull()) {
        logAndEmitError(programData.deviceId,
                        QStringLiteral("Cannot set controller firmware class ID - it is not provided."));
        return;
    }

    FlashData data;
    data.action = Action::SetControllerFwClassId;
    data.clientId = programData.clientId;
    data.deviceId = programData.deviceId;
    data.firmwareClassId = programData.firmwareClassId;
    data.jobUuid = programData.jobUuid;

    runUpdate(data);
}

void FirmwareUpdateController::runUpdate(const FlashData& data)
{
    if (boardController_.isNull() || downloadManager_.isNull()) {
        logAndEmitError(data.deviceId, QStringLiteral("FirmwareUpdateController is not properly initialized."));
        return;
    }

    auto it = updates_.constFind(data.deviceId);
    if (it != updates_.constEnd()) {
        logAndEmitError(data.deviceId, QStringLiteral("Cannot update, another update is running on this device."));
        return;
    }

    strata::device::DevicePtr device = boardController_->getDevice(data.deviceId);
    if (device == nullptr) {
        logAndEmitError(data.deviceId, QStringLiteral("Incorrect device ID for update."));
        return;
    }

    FirmwareUpdater *fwUpdater;
    bool workWithController = false;

    switch(data.action) {
    case Action::UpdateFirmware :
        fwUpdater = new FirmwareUpdater(device, downloadManager_, data.firmwareUrl, data.firmwareMD5);
        break;
    case Action::ProgramController :
        fwUpdater = new FirmwareUpdater(device, downloadManager_, data.firmwareUrl, data.firmwareMD5, data.firmwareClassId);
        workWithController = true;
        break;
    case Action::SetControllerFwClassId :
        fwUpdater = new FirmwareUpdater(device, data.firmwareClassId);
        workWithController = true;
        break;
    }

    UpdateInfo *updateData = new UpdateInfo(data.clientId, fwUpdater, data.jobUuid, workWithController);
    updates_.insert(data.deviceId, updateData);

    connect(fwUpdater, &FirmwareUpdater::updateProgress, this, &FirmwareUpdateController::handleUpdateProgress);
    connect(fwUpdater, &FirmwareUpdater::updaterError, this, &FirmwareUpdateController::updaterError);

    switch(data.action) {
    case Action::UpdateFirmware :
    case Action::ProgramController :
        fwUpdater->updateFirmware();
        break;
    case Action::SetControllerFwClassId :
        fwUpdater->setFwClassId();
        break;
    }
}

void FirmwareUpdateController::handleUpdateProgress(int deviceId, UpdateOperation operation, UpdateStatus status, int complete, int total, QString errorString)
{
    if (updates_.contains(deviceId) == false) {
        return;
    }

    UpdateInfo *updateData = updates_.value(deviceId);
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

void FirmwareUpdateController::logAndEmitError(int deviceId, const QString& errorString)
{
    qCCritical(logCategoryHcsFwUpdater).noquote() << errorString;
    emit updaterError(deviceId, errorString);
}

FirmwareUpdateController::UpdateInfo::UpdateInfo(const QByteArray& client, FirmwareUpdater* updater, const QString& jobUuid, bool workWithController) :
    clientId(client), fwUpdater(updater), updateProgress(jobUuid, workWithController)
{
}
