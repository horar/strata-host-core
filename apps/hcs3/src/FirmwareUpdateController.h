/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <memory>

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QUrl>
#include <QHash>
#include <QPointer>

namespace strata {
    class DownloadManager;
}
class PlatformController;
class FirmwareUpdater;

class FirmwareUpdateController final : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(FirmwareUpdateController)

public:
    /**
     * FirmwareUpdateController constructor.
     */
    FirmwareUpdateController(QObject *parent = nullptr);

    /**
     * FirmwareUpdateController destructor.
     */
    ~FirmwareUpdateController();

    /**
     * Initialize the Firmware Update Controller.
     * @param platformController pointer to PlatformController
     * @param downloadManager shared pointer to DownloadManager
     */
    void initialize(PlatformController *platformController, strata::DownloadManager *downloadManager);

    /**
     * The UpdateOperation enum for UpdateProgressInfo struct.
     */
    enum class UpdateOperation {
        Download,
        ClearFwClassId,
        SetFwClassId,
        Prepare,
        Backup,
        Flash,
        Restore,
        Finished
    };
    Q_ENUM(UpdateOperation)

    /**
     * The UpdateStatus enum for UpdateProgressInfo struct.
     */
    enum class UpdateStatus {
        Running,
        Success,
        Unsuccess,
        Failure
    };
    Q_ENUM(UpdateStatus)

    /**
     * The UpdateProgressInfo struct for progressOfUpdate() signal.
     */
    struct UpdateProgress {
        UpdateProgress();  // Q_DECLARE_METATYPE needs default constructor
        UpdateProgress(const QString& jobUuid, bool programController);
        UpdateOperation operation;
        UpdateStatus status;
        int complete;
        int total;
        QString lastError;  // last error which occurred during whole update process
        const QString jobUuid;
        const bool programController;
    };

    /**
     * The ChangeFirmwareAction enum for ChangeFirmwareData struct.
     */
    enum class ChangeFirmwareAction {
        UpdateFirmware,         // backup old firmware and flash new firmware
        ProgramFirmware,        // program firmware (without backup) - embedded board
        ProgramController,      // program controller (dongle) - assisted board
        SetControllerFwClassId  // set controller FW class ID - assisted board
    };

    /**
     * The ChangeFirmwareData struct holding information about new firmware which will be written to device.
     */
    struct ChangeFirmwareData {
        QByteArray clientId;
        QByteArray deviceId;
        QUrl firmwareUrl;
        QString firmwareMD5;
        QString firmwareClassId;
        QString jobUuid;
        ChangeFirmwareAction action;
    };

signals:
    void progressOfUpdate(QByteArray deviceId, QByteArray clientId, UpdateProgress progress);
    void updaterError(QByteArray deviceId, QString errorString);
    void bootloaderActive(QByteArray deviceId);
    void applicationActive(QByteArray deviceId);

public slots:
    /**
     * Change firmware.
     * @param data struct containing data for firmware update / program controler / set controller fw_class_id
     */
    void changeFirmware(const ChangeFirmwareData &data);

private slots:
    void handleUpdateProgress(const QByteArray& deviceId, FirmwareUpdateController::UpdateOperation operation,
                              FirmwareUpdateController::UpdateStatus status, int complete, int total, QString errorString);

private:
    void runUpdate(const ChangeFirmwareData& data);

    QPointer<PlatformController> platformController_;
    QPointer<strata::DownloadManager> downloadManager_;

    struct UpdateInfo {
        UpdateInfo(const QByteArray& client, FirmwareUpdater* updater, const QString& jobUuid, bool programController);
        const QByteArray clientId;
        FirmwareUpdater* fwUpdater;
        UpdateProgress updateProgress;
    };

    // deviceId <-> UpdateInfo
    QHash<QByteArray, struct UpdateInfo*> updates_;
};

Q_DECLARE_METATYPE(FirmwareUpdateController::UpdateOperation)
Q_DECLARE_METATYPE(FirmwareUpdateController::UpdateStatus)
Q_DECLARE_METATYPE(FirmwareUpdateController::UpdateProgress)
Q_DECLARE_METATYPE(FirmwareUpdateController::ChangeFirmwareData)
