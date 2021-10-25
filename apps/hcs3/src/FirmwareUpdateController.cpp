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

void FirmwareUpdateController::initialize(PlatformController *platformController, strata::DownloadManager *downloadManager)
{
    platformController_ = platformController;
    downloadManager_ = downloadManager;
}

void FirmwareUpdateController::updateFirmware(const QByteArray& clientId, const QByteArray& deviceId, const QUrl& firmwareUrl, const QString& firmwareMD5)
{
    if (platformController_.isNull() || downloadManager_.isNull()) {
        QString errStr("FirmwareUpdateController is not properly initialized.");
        qCCritical(lcHcsFwUpdater).noquote() << errStr;
        emit updaterError(deviceId, errStr);
        return;
    }

    auto it = updates_.constFind(deviceId);
    if (it != updates_.constEnd()) {
        QString errStr("Cannot update, another update is running on this device.");
        qCCritical(lcHcsFwUpdater).noquote() << errStr;
        emit updaterError(deviceId, errStr);
        return;
    }

    strata::platform::PlatformPtr platform = platformController_->getPlatform(deviceId);
    if (platform == nullptr) {
        QString errStr("Incorrect device ID for update.");
        qCCritical(lcHcsFwUpdater).noquote() << errStr;
        emit updaterError(deviceId, errStr);
        return;
    }

    FirmwareUpdater *fwUpdater = new FirmwareUpdater(platform, downloadManager_, firmwareUrl, firmwareMD5);
    UpdateData *updateData = new UpdateData(clientId, fwUpdater);
    updates_.insert(deviceId, updateData);

    connect(fwUpdater, &FirmwareUpdater::updateProgress, this, &FirmwareUpdateController::handleUpdateProgress);
    connect(fwUpdater, &FirmwareUpdater::updaterError, this, &FirmwareUpdateController::updaterError);
    connect(fwUpdater, &FirmwareUpdater::bootloaderActive, this, &FirmwareUpdateController::bootloaderActive);
    connect(fwUpdater, &FirmwareUpdater::applicationActive, this, &FirmwareUpdateController::applicationActive);

    fwUpdater->updateFirmware();
}

void FirmwareUpdateController::handleUpdateProgress(const QByteArray& deviceId, UpdateOperation operation, UpdateStatus status, int complete, int total, QString errorString)
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
            progress->prepareError = errorString;
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

FirmwareUpdateController::UpdateData::UpdateData(const QByteArray& client, FirmwareUpdater* updater) :
    clientId(client), fwUpdater(updater)
{
}
