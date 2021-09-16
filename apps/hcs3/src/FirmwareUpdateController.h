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
        UpdateOperation operation;
        UpdateStatus status;
        int complete;
        int total;
        QString downloadError;
        QString prepareError;
        QString backupError;
        QString flashError;
        QString restoreError;
    };

signals:
    void progressOfUpdate(QByteArray deviceId, QByteArray clientId, UpdateProgress progress);
    void updaterError(QByteArray deviceId, QString errorString);

public slots:
    /**
     * Update Firmware.
     * @param clientId
     * @param deviceId
     * @param firmwareUrl
     * @param firmwareMD5
     */
    void updateFirmware(const QByteArray& clientId, const QByteArray& deviceId, const QUrl& firmwareUrl, const QString& firmwareMD5);

private slots:
    void handleUpdateProgress(const QByteArray& deviceId, FirmwareUpdateController::UpdateOperation operation,
                              FirmwareUpdateController::UpdateStatus status, int complete, int total, QString errorString);

private:
    QPointer<PlatformController> platformController_;
    QPointer<strata::DownloadManager> downloadManager_;

    struct UpdateData {
        UpdateData(const QByteArray& client, FirmwareUpdater* updater);
        const QByteArray clientId;
        FirmwareUpdater* fwUpdater;
        UpdateProgress updateProgress;
    };

    // deviceId <-> UpdateData
    QHash<QByteArray, struct UpdateData*> updates_;
};

Q_DECLARE_METATYPE(FirmwareUpdateController::UpdateOperation)
Q_DECLARE_METATYPE(FirmwareUpdateController::UpdateStatus)
Q_DECLARE_METATYPE(FirmwareUpdateController::UpdateProgress)
