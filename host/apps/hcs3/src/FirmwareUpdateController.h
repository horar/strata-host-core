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
        UpdateProgress(const QString& jobUuid, bool workWithController);
        UpdateOperation operation;
        UpdateStatus status;
        int complete;
        int total;
        QString error;
        const QString jobUuid;
        const bool workWithController;
    };

    /**
     * The UpdateFirmwareData struct for updateFirmware() slot.
     */
    struct UpdateFirmwareData {
        QByteArray clientId;
        int deviceId;
        QUrl firmwareUrl;
        QString firmwareMD5;
        QString jobUuid;
    };

    /**
     * The ProgramControllerData struct for programController() slot.
     */
    struct ProgramControllerData {
        QByteArray clientId;
        int deviceId;
        QUrl firmwareUrl;
        QString firmwareMD5;
        QString firmwareClassId;
        QString jobUuid;
    };

signals:
    void progressOfUpdate(int deviceId, QByteArray clientId, UpdateProgress progress);
    void updaterError(int deviceId, QString errorString);

public slots:
    /**
     * Update firmware.
     * @param data struct containing data for updating firmware
     */
    void updateFirmware(UpdateFirmwareData data);

    /**
     * Program controller.
     * @param data struct containing data for programing controller
     */
    void programController(ProgramControllerData data);

    /**
     * Set controller firmware class ID.
     * @param data struct containing data for setting controller fw_class_id (URL and MD5 are unused)
     */
    void setControllerFwClassId(ProgramControllerData data);


private slots:
    void handleUpdateProgress(int deviceId, FirmwareUpdateController::UpdateOperation operation,
                              FirmwareUpdateController::UpdateStatus status, int complete, int total, QString errorString);

private:
    void logAndEmitError(int deviceId, const QString& errorString);

    enum class Action {
        UpdateFirmware,
        ProgramController,
        SetControllerFwClassId
    };

    struct FlashData {
        // constructror for update firmware action
        FlashData(int deviceId,
                  const QByteArray& clientId,
                  const QString& jobUuid,
                  const QUrl& firmwareUrl,
                  const QString& firmwareMD5);
        // constructor for program controller action
        FlashData(int deviceId,
                  const QByteArray& clientId,
                  const QString& jobUuid,
                  const QUrl& firmwareUrl,
                  const QString& firmwareMD5,
                  const QString& firmwareClassId);
        // constructor for set controller fw_class_id action
        FlashData(int deviceId,
                  const QByteArray& clientId,
                  const QString& jobUuid,
                  const QString& firmwareClassId);

        Action action;
        int deviceId;
        QByteArray clientId;
        QString jobUuid;
        QUrl firmwareUrl;
        QString firmwareMD5;
        QString firmwareClassId;
    };

    void runUpdate(const FlashData& data);

    QPointer<BoardController> boardController_;
    QPointer<strata::DownloadManager> downloadManager_;

    struct UpdateInfo {
        UpdateInfo(const QByteArray& client, FirmwareUpdater* updater, const QString& jobUuid, bool workWithController);
        const QByteArray clientId;
        FirmwareUpdater* fwUpdater;
        UpdateProgress updateProgress;
    };

    QHash<int, struct UpdateInfo*> updates_;
};

Q_DECLARE_METATYPE(FirmwareUpdateController::UpdateOperation)
Q_DECLARE_METATYPE(FirmwareUpdateController::UpdateStatus)
Q_DECLARE_METATYPE(FirmwareUpdateController::UpdateProgress)
Q_DECLARE_METATYPE(FirmwareUpdateController::UpdateFirmwareData)
Q_DECLARE_METATYPE(FirmwareUpdateController::ProgramControllerData)
