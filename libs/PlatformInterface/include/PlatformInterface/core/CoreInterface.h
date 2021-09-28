/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <StrataRPC/StrataClient.h>
#include <QJsonObject>
#include <QObject>
#include <QString>

class CoreInterface : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(CoreInterface)
    Q_PROPERTY(QString platformList_ READ platformList NOTIFY platformListChanged)
    Q_PROPERTY(QString connectedPlatformList_ READ connectedPlatformList NOTIFY
                   connectedPlatformListChanged)

public:
    /**
     * CoreInterface constructor
     * @param [in] strataClient pointer to strataClient
     */
    explicit CoreInterface(strata::strataRPC::StrataClient *strataClient,
                           QObject *parent = nullptr);

    /**
     * CoreInterface destructor
     */
    virtual ~CoreInterface();

    /**
     * Function to send commands to platforms
     * @param [in] cmd platform command in json string format
     * @note This is a deprecated function and left here for API compatibility with older views.
     */
    Q_INVOKABLE void sendCommand(const QString &cmd);

    /**
     * Function to send notifications to HCS
     * @param [in] handler The handler name in StrataServer.
     * @param [in] payload QJsonObject of the request payload.
     */
    Q_INVOKABLE void sendNotification(const QString &handler, const QJsonObject &payload);

    /**
     * Function to access PlatformList_
     * @return QString of all platform list.
     */
    QString platformList() const
    {
        return platformList_;
    }

    /**
     * Function to access connectedPlatformList_
     * @return QString of all connected platforms.
     */
    QString connectedPlatformList() const
    {
        return connectedPlatformList_;
    }

signals:
    /**
     * Signal emitted when platformList_ is updated.
     * @param [in] platformList QString of the all platform
     */
    void platformListChanged(const QString &platformList);

    /**
     * Signal emitted when connectedPlatformList_ is updated.
     * @param [in] connectedPlatformList QString of the all connected platforms
     */
    bool connectedPlatformListChanged(const QString &connectedPlatformList);

    /**
     * Signal emitted when connected_platforms notification is received (regardless if connectedPlatformList_ did changed).
     * @param [in] payload QJsonObject of connected_platforms notification payload.
     */
    void connectedPlatformListMessage(const QJsonObject &payload);

    /**
     * Signal emitted when a platform notification is received
     * @param [in] payload QString of the platform notification that contains the
     * device_id and the notification.
     */
    void notification(const QString &payload);

    /**
     * Signal emitted when updates available notification is received
     * @param [in] payload QJsonObject of updates_available notification payload.
     */
    void updateInfoReceived(const QJsonObject &payload);

    /**
     * Signal emitted when download view finished notification is received
     * @param [in] payload QJsonObject of download_view_finished notification payload.
     */
    void downloadViewFinished(const QJsonObject &payload);

    /**
     * Signal emitted when control view download progress notification is received
     * @param [in] payload QJsonObject of control_view_download_progress notification payload.
     */
    void downloadControlViewProgress(const QJsonObject &payload);

    /**
     * Signal emitted when program_controller_job notification is received.
     * @param [in] payload QJsonObject of program_controller_job notification payload.
     */
    void programControllerJobUpdate(const QJsonObject &payload);

    /**
     * Signal emitted when update_firmware_job notification is received.
     * @param [in] payload QJsonObject of update_firmware_job notification payload.
     */
    void updateFirmwareJobUpdate(const QJsonObject &payload);

    /**
     * Signal emitted when download_platform_filepath_changed notification is received.
     * @param [in] payload QJsonObject of download_platform_filepath_changed notification payload.
     */
    void downloadPlatformFilepathChanged(const QJsonObject &payload);
    /**
     * Signal emitted when download_platform_single_file_progress notification is received.
     * @param [in] payload QJsonObject of download_platform_single_file_progress notification
     * payload.
     */
    void downloadPlatformSingleFileProgress(const QJsonObject &payload);

    /**
     * Signal emitted when download_platform_single_file_finished notification is received.
     * @param [in] payload QJsonObject of download_platform_single_file_finished notification
     * payload.
     */
    void downloadPlatformSingleFileFinished(const QJsonObject &payload);

    /**
     * Signal emitted when download_platform_files_finished notification is received.
     * @param [in] payload QJsonObject of download_platform_files_finished notification payload.
     */
    void downloadPlatformFilesFinished(const QJsonObject &payload);

    /**
     * Signal emitted when bluetooth_scan notification is received.
     * @param [in] payload QJsonObject of bluetooth_scan notification payload.
     */
    void bluetoothScan(const QJsonObject &payload);

    /**
     * Signal emitted when connect_device notification is received.
     * @param [in] payload QJsonObject of connect_device notification payload.
     */
    void connectDevice(const QJsonObject &payload);

    /**
     * Signal emitted when disconnect_device notification is received.
     * @param [in] payload QJsonObject of disconnect_device notification payload.
     */
    void disconnectDevice(const QJsonObject &payload);

private:
    void processPlatformNotification(const QJsonObject &payload);
    void processAllPlatformsNotification(const QJsonObject &payload);
    void processConnectedPlatformsNotification(const QJsonObject &payload);
    void processUpdatesAvailableNotification(const QJsonObject &payload);
    void processDownloadViewFinishedNotification(const QJsonObject &payload);
    void processDownloadControlViewProgressNotification(const QJsonObject &payload);
    void processProgramControllerJobNotification(const QJsonObject &payload);
    void processUpdateFirmwareJobNotification(const QJsonObject &payload);
    void processDownloadPlatformFilepathChangedNotification(const QJsonObject &payload);
    void processDownloadPlatformSingleFileProgressNotification(const QJsonObject &payload);
    void processDownloadPlatformSingleFileFinishedNotification(const QJsonObject &payload);
    void processDownloadPlatformFilesFinishedNotification(const QJsonObject &payload);
    void processBluetoothScanNotification(const QJsonObject &payload);
    void processConnectDeviceNotification(const QJsonObject &payload);
    void processDisconnectDeviceNotification(const QJsonObject &payload);

    strata::strataRPC::StrataClient *strataClient_{nullptr};
    QString platformList_{"{ \"list\":[]}"};
    QString connectedPlatformList_{"{ \"list\":[]}"};
};
