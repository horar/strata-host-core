#pragma once

#include <memory>

#include <QObject>
#include <QString>
#include <QUrl>
#include <QHash>
#include <QPointer>

namespace strata {
    class DownloadManager;
}
class BoardController;
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
     * @param boardController pointer to BoardController
     * @param downloadManager shared pointer to DownloadManager
     */
    void initialize(BoardController *boardController, strata::DownloadManager *downloadManager);

    /**
     * The UpdateOperation enum for UpdateProgressInfo struct.
     */
    enum class UpdateOperation {
        Download,
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
        UpdateOperation operation;
        UpdateStatus status;
        int complete;
        int total;
        QString error;
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
     * @param adjustController
     */
    void updateFirmware(const QByteArray& clientId, const int deviceId, const QUrl& firmwareUrl, const QString& firmwareMD5, bool adjustController);

private slots:
    void handleUpdateProgress(int deviceId, FirmwareUpdateController::UpdateOperation operation,
                              FirmwareUpdateController::UpdateStatus status, int complete, int total, QString errorString);

private:
    QPointer<BoardController> boardController_;
    QPointer<strata::DownloadManager> downloadManager_;

    struct UpdateData {
        UpdateData(const QByteArray& client, FirmwareUpdater* updater);
        const QByteArray clientId;
        FirmwareUpdater* fwUpdater;
        UpdateProgress updateProgress;
    };

    QHash<int, struct UpdateData*> updates_;
};

Q_DECLARE_METATYPE(FirmwareUpdateController::UpdateOperation)
Q_DECLARE_METATYPE(FirmwareUpdateController::UpdateStatus)
Q_DECLARE_METATYPE(FirmwareUpdateController::UpdateProgress)
