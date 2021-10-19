/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "core/CoreInterface.h"
#include "LoggingQtCategories.h"

#include <QJsonDocument>

CoreInterface::CoreInterface(strata::strataRPC::StrataClient *strataClient, QObject *parent)
    : QObject(parent), strataClient_(strataClient)
{
    strataClient_->registerHandler(
        "all_platforms",
        std::bind(&CoreInterface::processAllPlatformsNotification, this, std::placeholders::_1));
    strataClient_->registerHandler("connected_platforms",
                                   std::bind(&CoreInterface::processConnectedPlatformsNotification,
                                             this, std::placeholders::_1));
    strataClient_->registerHandler(
        "platform_notification",
        std::bind(&CoreInterface::processPlatformNotification, this, std::placeholders::_1));
    strataClient_->registerHandler(
        "updates_available", std::bind(&CoreInterface::processUpdatesAvailableNotification, this,
                                       std::placeholders::_1));
    strataClient_->registerHandler(
        "program_controller_job", std::bind(&CoreInterface::processProgramControllerJobNotification, this,
                                         std::placeholders::_1));
    strataClient_->registerHandler(
        "update_firmware_job", std::bind(&CoreInterface::processUpdateFirmwareJobNotification, this,
                                         std::placeholders::_1));
    strataClient_->registerHandler(
        "control_view_download_progress",
        std::bind(&CoreInterface::processDownloadControlViewProgressNotification, this,
                  std::placeholders::_1));
    strataClient_->registerHandler(
        "download_view_finished", std::bind(&CoreInterface::processDownloadViewFinishedNotification,
                                            this, std::placeholders::_1));
    strataClient_->registerHandler(
        "download_platform_filepath_changed",
        std::bind(&CoreInterface::processDownloadPlatformFilepathChangedNotification, this,
                  std::placeholders::_1));
    strataClient_->registerHandler(
        "download_platform_single_file_progress",
        std::bind(&CoreInterface::processDownloadPlatformSingleFileProgressNotification, this,
                  std::placeholders::_1));
    strataClient_->registerHandler(
        "download_platform_single_file_finished",
        std::bind(&CoreInterface::processDownloadPlatformSingleFileFinishedNotification, this,
                  std::placeholders::_1));
    strataClient_->registerHandler(
        "download_platform_files_finished",
        std::bind(&CoreInterface::processDownloadPlatformFilesFinishedNotification, this,
                  std::placeholders::_1));
#ifdef APPS_CORESW_SDS_PLUGIN_BLE
    strataClient_->registerHandler(
        "bluetooth_scan",
        std::bind(&CoreInterface::processBluetoothScanNotification, this,
                  std::placeholders::_1));
#endif // APPS_CORESW_SDS_PLUGIN_BLE
    strataClient_->registerHandler(
        "connect_device",
        std::bind(&CoreInterface::processConnectDeviceNotification, this,
                  std::placeholders::_1));
    strataClient_->registerHandler(
        "disconnect_device",
        std::bind(&CoreInterface::processDisconnectDeviceNotification, this,
                  std::placeholders::_1));
}

CoreInterface::~CoreInterface()
{
}

void CoreInterface::processPlatformNotification(const QJsonObject &payload)
{
    QJsonDocument doc(payload);
    emit notification(doc.toJson(QJsonDocument::Compact));
}

void CoreInterface::sendCommand(const QString &)
{
    qCCritical(logCategoryCoreInterface) << "Deprecated method.";
}

void CoreInterface::sendNotification(const QString &method, const QJsonObject &payload)
{
    strataClient_->sendNotification(method, payload);
}

void CoreInterface::processAllPlatformsNotification(const QJsonObject &payload)
{
    QString newPlatformList = QJsonDocument(payload).toJson(QJsonDocument::Compact);
    if (platformList_ != newPlatformList) {
        platformList_ = newPlatformList;
    }
    emit platformListChanged(platformList_);
}

void CoreInterface::processConnectedPlatformsNotification(const QJsonObject &payload)
{
    QString newConnectedPlatformList = QJsonDocument(payload).toJson(QJsonDocument::Compact);
    if (connectedPlatformList_ != newConnectedPlatformList) {
        connectedPlatformList_ = newConnectedPlatformList;
        emit connectedPlatformListChanged(connectedPlatformList_);
    }

    emit connectedPlatformListMessage(payload);
}

void CoreInterface::processUpdatesAvailableNotification(const QJsonObject &payload)
{
    emit updateInfoReceived(payload);
}

void CoreInterface::processDownloadViewFinishedNotification(const QJsonObject &payload)
{
    emit downloadViewFinished(payload);
}

void CoreInterface::processDownloadControlViewProgressNotification(const QJsonObject &payload)
{
    emit downloadControlViewProgress(payload);
}

void CoreInterface::processProgramControllerJobNotification(const QJsonObject &payload)
{
    emit programControllerJobUpdate(payload);
}

void CoreInterface::processUpdateFirmwareJobNotification(const QJsonObject &payload)
{
    emit updateFirmwareJobUpdate(payload);
}

void CoreInterface::processDownloadPlatformFilepathChangedNotification(const QJsonObject &payload)
{
    emit downloadPlatformFilepathChanged(payload);
}

void CoreInterface::processDownloadPlatformSingleFileProgressNotification(const QJsonObject &payload)
{
    emit downloadPlatformSingleFileProgress(payload);
}

void CoreInterface::processDownloadPlatformSingleFileFinishedNotification(const QJsonObject &payload)
{
    emit downloadPlatformSingleFileFinished(payload);
}

void CoreInterface::processDownloadPlatformFilesFinishedNotification(const QJsonObject &payload)
{
    emit downloadPlatformFilesFinished(payload);
}

#ifdef APPS_CORESW_SDS_PLUGIN_BLE
void CoreInterface::processBluetoothScanNotification(const QJsonObject &payload)
{
    emit bluetoothScan(payload);
}
#endif // APPS_CORESW_SDS_PLUGIN_BLE

void CoreInterface::processConnectDeviceNotification(const QJsonObject &payload)
{
    emit connectDevice(payload);
}

void CoreInterface::processDisconnectDeviceNotification(const QJsonObject &payload)
{
    emit disconnectDevice(payload);
}
