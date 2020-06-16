#pragma once

#include <QObject>
#include <QString>
#include <QUrl>
#include <QHash>

namespace strata {
    class DownloadManager;
}
class BoardController;
class FirmwareUpdater;

class UpdateController final : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(UpdateController)

public:
    /**
     * UpdateController constructor.
     */
    UpdateController();

    /**
     * UpdateController destructor.
     */
    ~UpdateController();

    /**
     * Initialize Update Controller.
     * @param boardController pointer to BoardController
     * @param downloadManager pointer to DownloadManager
     */
    void initialize(const BoardController* boardController, strata::DownloadManager* downloadManager);

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
        QString backupError;
        QString flashError;
        QString restoreError;
    };

signals:
    void progressOfUpdate(int deviceId, QByteArray clientId, UpdateProgress progress);
    void updaterError(int deviceId, QString errorString);

public slots:
    /**
     * Update Firmware.
     * @param clientId
     * @param deviceId
     * @param firmwareUrl
     * @param firmwareMD5
     */
    void updateFirmware(const QByteArray& clientId, const int deviceId, const QUrl& firmwareUrl, const QString& firmwareMD5);

private slots:
    void handleUpdateProgress(int deviceId, UpdateController::UpdateOperation operation,
                              UpdateController::UpdateStatus status, int complete, int total, QString errorString);

private:
    const BoardController* boardController_;
    strata::DownloadManager* downloadManager_;

    struct UpdateData {
        UpdateData(const QByteArray& client, FirmwareUpdater* updater);
        const QByteArray clientId;
        FirmwareUpdater* fwUpdater;
        UpdateProgress updateProgress;
    };

    QHash<int, struct UpdateData*> updates_;
};

Q_DECLARE_METATYPE(UpdateController::UpdateOperation)
Q_DECLARE_METATYPE(UpdateController::UpdateStatus)
Q_DECLARE_METATYPE(UpdateController::UpdateProgress)
