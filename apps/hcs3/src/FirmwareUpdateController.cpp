/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <QtAlgorithms>

#include "FirmwareUpdateController.h"
#include "FirmwareUpdater.h"
#include "PlatformController.h"

#include <Platform.h>
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

void FirmwareUpdateController::initialize(
        PlatformController *platformController,
        strata::DownloadManager *downloadManager)
{
    platformController_ = platformController;
    downloadManager_ = downloadManager;
}

FirmwareUpdateController::UpdateProgress::UpdateProgress()
    : complete(-1),
      total(-1),
      jobUuid(QString()),
      programController(false)
{
}

FirmwareUpdateController::UpdateProgress::UpdateProgress(
        const QString& jobUuid,
        bool programController)
    : complete(-1),
      total(-1),
      jobUuid(jobUuid),
      programController(programController)
{
}

void FirmwareUpdateController::changeFirmware(const ChangeFirmwareData &data)
{
    switch (data.action) {
    case ChangeFirmwareAction::UpdateFirmware :
    case ChangeFirmwareAction::ProgramFirmware :
        break;
    case ChangeFirmwareAction::ProgramController :
        if (data.firmwareClassId.isNull()) {
            logAndEmitError(data.deviceId, QStringLiteral("Cannot program controller - firmware class ID was not provided."));
            return;
        }
        break;
    case ChangeFirmwareAction::SetControllerFwClassId :
        if (data.firmwareClassId.isNull()) {
            logAndEmitError(data.deviceId, QStringLiteral("Cannot set controller firmware class ID - it is not provided."));
            return;
        }
        break;
    }

    runUpdate(data);
}

void FirmwareUpdateController::runUpdate(const ChangeFirmwareData& data)
{
    if (platformController_.isNull() || downloadManager_.isNull()) {
        logAndEmitError(data.deviceId, QStringLiteral("FirmwareUpdateController is not properly initialized."));
        return;
    }

    auto it = updates_.constFind(data.deviceId);
    if (it != updates_.constEnd()) {
        logAndEmitError(data.deviceId, QStringLiteral("Cannot update, another update is running on this device."));
        return;
    }

    strata::platform::PlatformPtr platform = platformController_->getPlatform(data.deviceId);
    if (platform == nullptr) {
        logAndEmitError(data.deviceId, QStringLiteral("Incorrect device ID for update."));
        return;
    }

    FirmwareUpdater *fwUpdater;
    bool programController = true;

    switch(data.action) {
    case ChangeFirmwareAction::UpdateFirmware :
    case ChangeFirmwareAction::ProgramFirmware :
        programController = false;
        [[fallthrough]];
    case ChangeFirmwareAction::ProgramController :
        fwUpdater = new FirmwareUpdater(platform, downloadManager_, data.firmwareUrl, data.firmwareMD5, data.firmwareClassId);
        break;
    case ChangeFirmwareAction::SetControllerFwClassId :
        fwUpdater = new FirmwareUpdater(platform, data.firmwareClassId);
        break;
    }

    UpdateInfo *updateData = new UpdateInfo(data.clientId, fwUpdater, data.jobUuid, programController);
    updates_.insert(data.deviceId, updateData);

    connect(fwUpdater, &FirmwareUpdater::updateProgress, this, &FirmwareUpdateController::handleUpdateProgress);
    connect(fwUpdater, &FirmwareUpdater::updaterError, this, &FirmwareUpdateController::updaterError);
    connect(fwUpdater, &FirmwareUpdater::bootloaderActive, this, &FirmwareUpdateController::bootloaderActive);
    connect(fwUpdater, &FirmwareUpdater::applicationActive, this, &FirmwareUpdateController::applicationActive);

    switch(data.action) {
    case ChangeFirmwareAction::UpdateFirmware :
        fwUpdater->updateFirmware(true);
        break;
    case ChangeFirmwareAction::ProgramFirmware :
    case ChangeFirmwareAction::ProgramController :
        // there is no need to backup old firmware if programming embedded board without
        // firmware or if programming assisted controller (dongle)
        fwUpdater->updateFirmware(false);
        break;
    case ChangeFirmwareAction::SetControllerFwClassId :
        fwUpdater->setFwClassId();
        break;
    }
}

void FirmwareUpdateController::handleUpdateProgress(const QByteArray& deviceId, UpdateOperation operation, UpdateStatus status, int complete, int total, QString errorString)
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
    // - UpdateOperation::Finished is special case - it has always empty errorString because
    //   this operation is bind to FlasherConnector 'finished' signal which doesn't have any
    //   error string. So, do nothing with last error string in this case.
    // - Update last error string only if 'errorString' is not empty.
    if ((operation != UpdateOperation::Finished) && (errorString.isEmpty() == false)) {
        progress->lastError = errorString;
    }

    emit progressOfUpdate(deviceId, updateData->clientId, *progress);

    if (operation == UpdateOperation::Finished) {
        updateData->fwUpdater->deleteLater();
        delete updateData;
        updates_.remove(deviceId);
    }
}

void FirmwareUpdateController::logAndEmitError(const QByteArray& deviceId, const QString& errorString)
{
    qCCritical(logCategoryHcsFwUpdater).noquote() << errorString;
    emit updaterError(deviceId, errorString);
}

FirmwareUpdateController::UpdateInfo::UpdateInfo(
        const QByteArray& client,
        FirmwareUpdater* updater,
        const QString& jobUuid,
        bool programController)
    : clientId(client),
      fwUpdater(updater),
      updateProgress(jobUuid, programController)
{
}
