#pragma once

#include <memory>

#include <QObject>
#include <QString>
#include <QUrl>
#include <QPointer>
#include <QTemporaryFile>

#include <FlasherConnector.h>
#include <Device/Device.h>

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
     * FirmwareUpdater constructor
     * @param devPtr device
     * @param downloadManager pointer to DownloadManager
     * @param url URL where firmware is located
     * @param md5 MD5 of firmware
     * @param adjustController flag if assisted controller (dongle) is being flashed
     */
    FirmwareUpdater(const strata::device::DevicePtr& devPtr, strata::DownloadManager *downloadManager,
                    const QUrl& url, const QString& md5, bool adjustController);

    /**
     * FirmwareUpdater destructor
     */
    ~FirmwareUpdater();

    /**
     * Update Firmware
     */
    void updateFirmware();

signals:
    void updateProgress(int deviceId, FirmwareUpdateController::UpdateOperation operation, FirmwareUpdateController::UpdateStatus status,
                        qint64 complete = -1, qint64 total = -1, QString errorString = QString());
    void updaterError(int deviceId, QString errorString);
    // internal signals:
    void flashFirmware(QPrivateSignal);
    void setFirmwareClassId(QString fwClassId, QPrivateSignal);

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
    // slot for flashFirmware() signal:
    void handleFlashFirmware();
    // slot for setFirmwareClassId() signal:
    void handleSetFirmwareClassId(QString fwClassId);
    // slot for device operation (setAssistedPlatformId) signal:
    void handleSetFirmwareClassIdFinished(strata::device::operation::Result result, int status, QString errorString);

private:
    void updateFinished(FirmwareUpdateController::UpdateStatus status);
    void downloadFirmware();

    bool running_;
    bool adjustController_;

    const strata::device::DevicePtr device_;
    const int deviceId_;

    QPointer<strata::DownloadManager> downloadManager_;
    QString downloadId_;

    const QUrl firmwareUrl_;
    const QString firmwareMD5_;
    QTemporaryFile firmwareFile_;

    QPointer<strata::FlasherConnector> flasherConnector_;
    bool flasherFinished_;

    QPointer<strata::device::operation::SetAssistedPlatformId> setAssistPlatfIdOper_;
};
