/*
 * Copyright (c) 2018-2021 onsemi.
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
#include <QUrl>
#include <QPointer>
#include <QTemporaryFile>

#include <FlasherConnector.h>
#include <Platform.h>

#include "FirmwareUpdateController.h"

namespace strata {
    class DownloadManager;
}

namespace strata::device::operation {
    class SetAssistedPlatformId;
    enum class Result: int;
}

class FirmwareUpdater final : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(FirmwareUpdater)
public:
    /**
     * FirmwareUpdater constructor for updating firmware or programming new firmware to assisted controller (dongle)
     * @param platform platform
     * @param downloadManager pointer to DownloadManager
     * @param url URL where firmware is located
     * @param md5 MD5 of firmware
     * @param fwClassId firmware class id
     */
    FirmwareUpdater(const strata::platform::PlatformPtr& platform, strata::DownloadManager *downloadManager,
                    const QUrl& url, const QString& md5, const QString& fwClassId);

    /**
     * FirmwareUpdater constructor for setting fw_class_id (without flash) to assisted controller (dongle)
     * @param platform platform
     * @param fwClassId firmware class id
     */
    FirmwareUpdater(const strata::platform::PlatformPtr& platform, const QString& fwClassId);

    /**
     * FirmwareUpdater destructor
     */
    ~FirmwareUpdater();

    /**
     * Update Firmware
     * @param backupOldFirmware true if backup original firmware, false otherwise
     */
    void updateFirmware(bool backupOldFirmware);

    /**
     * Set Firmware ClassId
     */
    void setFwClassId();

signals:
    void updateProgress(QByteArray deviceId, FirmwareUpdateController::UpdateOperation operation, FirmwareUpdateController::UpdateStatus status,
                        qint64 complete = -1, qint64 total = -1, QString errorString = QString());
    void updaterError(QByteArray deviceId, QString errorString);
    void bootloaderActive(QByteArray deviceId);
    void applicationActive(QByteArray deviceId);
    // internal signal:
    void flashFirmware(QPrivateSignal);

private slots:
    // slots for DownloadManager signals:
    void handleDownloadFinished(QString downloadId, QString errorString);
    void handleSingleDownloadProgress(QString downloadId, QString filePath, qint64 bytesReceived, qint64 bytesTotal);
    // slots for FlasherConnector signals:
    void handleFlasherFinished(strata::FlasherConnector::Result result);
    void handleFlashProgress(int chunk, int total);
    void handleBackupProgress(int chunk, int total);
    void handleRestoreProgress(int chunk, int total);
    void handleOperationStateChanged(strata::FlasherConnector::Operation operation,
                                     strata::FlasherConnector::State state, QString errorString);
    void handleBootloaderActive();
    void handleApplicationActive();
    // slot for flashFirmware() signal:
    void handleFlashFirmware();

private:
    void updateFinished(FirmwareUpdateController::UpdateStatus status);
    void downloadFirmware();

    void logAndEmitError(const QString& errorString);

    bool running_;
    bool backupOldFirmware_;

    const strata::platform::PlatformPtr platform_;
    const QByteArray deviceId_;

    QPointer<strata::DownloadManager> downloadManager_;
    QString downloadId_;

    const QUrl firmwareUrl_;
    const QString firmwareMD5_;
    QTemporaryFile firmwareFile_;

    const QString fwClassId_;

    QPointer<strata::FlasherConnector> flasherConnector_;
};
