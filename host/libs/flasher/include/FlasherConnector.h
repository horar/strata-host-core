#ifndef FLASHER_CONNECTOR_H_
#define FLASHER_CONNECTOR_H_

#include <memory>

#include <QObject>
#include <QString>
#include <QTemporaryFile>

#include <SerialDevice.h>
#include <Flasher.h>

namespace strata {

class FlasherConnector : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(FlasherConnector)

public:
    /*!
     * FlasherConnector constructor.
     * \param device device which will be used by FlasherConnector
     * \param firmwarePath path to firmware file
     */
    FlasherConnector(const SerialDevicePtr& device, const QString& firmwarePath, QObject* parent = nullptr);

    /*!
     * FlasherConnector destructor.
     */
    ~FlasherConnector();

    /*!
     * Flash firmware.
     * \param backupOld if set to true backup old firmware before flashing new one and if flash process fails flash old firmware
     * \return true if flash process has started, otherwise false
     */
    bool flash(bool backupOld = true);

    /*!
     * Backup firmware.
     * \return true if backup process has started, otherwise false
     */
    bool backup();

    /*!
     * Stop flash/backup firmware operation.
     */
    void stop();

    /*!
     * Set path to firmware file.
     * \param firmwarePath path to firmware file
     */
    void setFirmwarePath(const QString& firmwarePath);

signals:
    /*!
     * This signal is emitted when FlasherConnector finishes.
     * \param result result of firmware operation
     * \param errorString error description (if result is Error, otherwise null string)
     */
    void finished(Flasher::Result result, QString errorString = QString());

    /*!
     * This signal is emitted during firmware flashing.
     * \param chunk number of firmware chunks which was flashed
     * \param total total count of firmware chunks
     */
    void flashProgress(int chunk, int total);

    /*!
     * This signal is emitted during firmware backup.
     * \param chunk chunk number which was backed up
     * \param last true if backed up chunk is last
     */
    void backupProgress(int chunk, bool last);

private slots:
    void handleFlasherFinished(Flasher::Result result, QString errorString);

private:
    void flashFirmware(bool flashOld);
    void backupFirmware(bool backupOld);

    SerialDevicePtr device_;
    std::unique_ptr<Flasher> flasher_;
    QString filePath_;
    QTemporaryFile tmpBackupFile_;

    enum class State {
        None,
        Flash,
        Backup,
        BackupOld,
        FlashNew,
        FlashOld
    };
    State state_;
};

}  // namespace

#endif
