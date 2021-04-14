#ifndef FLASHER_CONNECTOR_H_
#define FLASHER_CONNECTOR_H_

#include <memory>

#include <QObject>
#include <QString>
#include <QTemporaryFile>

#include <Platform.h>
#include <Flasher.h>

namespace strata {

class FlasherConnector : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(FlasherConnector)

public:
    /*!
     * FlasherConnector constructor.
     * \param platform platform which will be used by FlasherConnector
     * \param firmwarePath path to firmware file
     */
    FlasherConnector(const platform::PlatformPtr& platform, const QString& firmwarePath, QObject* parent = nullptr);

    /*!
     * FlasherConnector constructor.
     * \param fwClassId firmware class id which will be set to platform
     * \param platform platform which will be used by FlasherConnector
     */
    FlasherConnector(const QString& fwClassId, const platform::PlatformPtr& platform, QObject* parent = nullptr);

    /*!
     * FlasherConnector constructor.
     * \param platform platform which will be used by FlasherConnector
     * \param firmwarePath path to firmware file
     * \param firmwareMD5 MD5 checksum of firmware
     */
    FlasherConnector(const platform::PlatformPtr& platform, const QString& firmwarePath, const QString& firmwareMD5, QObject* parent = nullptr);

    /*!
     * FlasherConnector constructor.
     * \param platform platform which will be used by FlasherConnector
     * \param firmwarePath path to firmware file
     * \param firmwareMD5 MD5 checksum of firmware
     * \param fwClassId firmware class id which will be set to platform
     */
    FlasherConnector(const platform::PlatformPtr& platform,
                     const QString& firmwarePath,
                     const QString& firmwareMD5,
                     const QString& fwClassId,
                     QObject* parent = nullptr);

    /*!
     * FlasherConnector destructor.
     */
    ~FlasherConnector();

    /*!
     * Flash firmware.
     * \param backupBeforeFlash if set to true backup old firmware before flashing new one and if flash process fails flash old firmware
     * \return true if flash process has started, otherwise false
     */
    bool flash(bool backupBeforeFlash = true);

    /*!
     * Backup firmware.
     * \return true if backup process has started, otherwise false
     */
    bool backup();

    /*!
     * Set Firmware Class ID (without flashing firmware)
     * \return true if set process has started, otherwise false
     */
    bool setFwClassId();

    /*!
     * Stop flash/backup firmware operation.
     */
    void stop();

    /*!
     * The Result enum for finished() signal.
     */
    enum class Result {
        Success,   /*!< Firmware is flashed (or backed up) successfully. */
        Unsuccess, /*!< Something went wrong, new firmware was not flashed, but original firmware is avaialble (board can be in bootloader mode). */
        Failure    /*!< Failure, neither new nor original firmware is flashed correctly. */
    };
    Q_ENUM(Result)

    /*!
     * The Operation enum for operationStateChanged() signal.
     */
    enum class Operation {
        Preparation,
        ClearFwClassId,
        SetFwClassId,
        Flash,
        Backup,
        BackupBeforeFlash,
        RestoreFromBackup
    };
    Q_ENUM(Operation)

    /*!
     * The State enum for operationStateChanged() signal.
     */
    enum class State {
        Started,
        Finished,
        Cancelled,
        Failed,
        NoFirmware
    };
    Q_ENUM(State)

signals:
    /*!
     * This signal is emitted only once when FlasherConnector finishes.
     * \param result result of FlasherConnector operation
     */
    void finished(Result result);

    /*!
     * This signal is emitted during flashing new firmware.
     * \param chunk number of firmware chunks which was flashed
     * \param total total count of firmware chunks
     */
    void flashProgress(int chunk, int total);

    /*!
     * This signal is emitted during firmware backup.
     * \param chunk chunk number which was backed up
     * \param total total count of firmware chunks
     */
    void backupProgress(int chunk, int total);

    /*!
     * This signal is emitted during flashing backed up firmware.
     * \param chunk number of firmware chunks which was flashed
     * \param total total count of firmware chunks
     */
    void restoreProgress(int chunk, int total);

    /*!
     * This signal is emitted when state of FlasherConnector is changed.
     * \param operation FlasherConnector operation
     * \param state state of operation
     * \param errorString error description (if state is 'Failed', otherwise null string)
     */
    void operationStateChanged(Operation operation, State state, QString errorString = QString());

    /*!
     * This signal is emitted when platform properties are changed (when platform is switched to/from bootloader mode).
     */
    void devicePropertiesChanged();

private slots:
    void handleFlasherFinished(Flasher::Result flasherResult, QString errorString);
    void handleFlasherState(Flasher::State flasherState, bool done);

private:
    // deleter for flasher_ unique pointer
    static void flasherDeleter(Flasher* flasher);

    void flashFirmware(bool flashOld);
    void backupFirmware(bool backupOld);
    void processStartupError(const QString& errorString);

    platform::PlatformPtr platform_;

    typedef std::unique_ptr<Flasher, void(*)(Flasher*)> FlasherPtr;
    FlasherPtr flasher_;

    const QString filePath_;
    const QString newFirmwareMD5_;
    const QString newFwClassId_;
    QString oldFwClassId_;
    QTemporaryFile tmpBackupFile_;

    enum class Action {
        None,
        Flash,        // only flash firmware (without backup)
        Backup,       // only backup firmware
        BackupOld,    // backup old firmware
        FlashNew,     // flash new firmware
        FlashOld,     // flash backed up (old) firmware
        SetFwClassId  // set firmware class ID (without flash)
    };
    Action action_;

    Operation operation_;
};

}  // namespace

#endif
