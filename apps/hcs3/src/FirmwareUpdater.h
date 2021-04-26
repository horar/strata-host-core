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
     */
    FirmwareUpdater(const strata::platform::PlatformPtr& platform, strata::DownloadManager *downloadManager, const QUrl& url, const QString& md5);

    /**
     * FirmwareUpdater destructor
     */
    ~FirmwareUpdater();

    /**
     * Update Firmware
     */
    void updateFirmware();

signals:
    void updateProgress(QByteArray deviceId, FirmwareUpdateController::UpdateOperation operation, FirmwareUpdateController::UpdateStatus status,
                        qint64 complete = -1, qint64 total = -1, QString errorString = QString());
    void updaterError(QByteArray deviceId, QString errorString);
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
    // slot for flashFirmware() signal:
    void handleFlashFirmware();

private:
    void downloadFirmware();

    bool running_;

    const strata::platform::PlatformPtr platform_;
    const QByteArray deviceId_;

    QPointer<strata::DownloadManager> downloadManager_;
    QString downloadId_;

    const QUrl firmwareUrl_;
    const QString firmwareMD5_;
    QTemporaryFile firmwareFile_;

    QPointer<strata::FlasherConnector> flasherConnector_;
};
