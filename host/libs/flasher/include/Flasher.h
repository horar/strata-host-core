#ifndef FLASHER_H_
#define FLASHER_H_

#include <QObject>
#include <QFile>

#include <memory>

#include <Device/Device.h>

namespace strata::device::operation {

class BaseDeviceOperation;
enum class Type : int;

}

namespace strata {

class Flasher : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(Flasher)

    public:
        /*!
         * The Result enum for finished() signal.
         */
        enum class Result {
            Ok,
            NoFirmware,
            Error,
            Timeout,
            Cancelled
        };
        Q_ENUM(Result)

        /*!
         * Flasher constructor.
         * \param device device which will be used by Flasher
         * \param fileName path to firmware (or bootloader) file
         */
        Flasher(const device::DevicePtr& device, const QString& fileName);
        /*!
         * Flasher constructor.
         * \param device device which will be used by Flasher
         * \param fileName path to firmware (or bootloader) file
         * \param fileMD5 MD5 checksum of file which will be flashed
         */
        Flasher(const device::DevicePtr& device, const QString& fileName, const QString& fileMD5);

        /*!
         * Flasher destructor.
         */
        ~Flasher();

        /*!
         * Flash firmware.
         * \param startApplication if set to true start application after flashing
         */
        void flashFirmware(bool startApplication = true);

        /*!
         * Backup firmware.
         * \param startApplication if set to true start application after backup
         */
        void backupFirmware(bool startApplication = true);

        /*!
         * Flash bootloader.
         * \param startApplication if set to true start application after flashing
         */
        void flashBootloader(bool startApplication = true);

        /*!
         * Cancel flash firmware operation.
         */
        void cancel();

    signals:
        /*!
         * This signal is emitted when Flasher finishes.
         * \param result result of firmware operation
         */
        void finished(Result result);

        /*!
         * This signal is emitted when error occurres.
         * \param errorString error description
         */
        void error(QString errorString);

        /*!
         * This signal is emitted with request to switch the board to bootloader mode
         * and when board is successfully switched to bootloader.
         * \param done true when board was successfully switched to bootloader
         */
        void switchToBootloader(bool done);

        /*!
         * This signal is emitted during firmware flashing.
         * \param chunk chunk number which was flashed (1 - N)
         * \param total total count of firmware chunks (N)
         */
        void flashFirmwareProgress(int chunk, int total);

        /*!
         * This signal is emitted during firmware backup.
         * \param chunk chunk number which was backed up (1 - N)
         * \param total total count of firmware chunks (N)
         */
        void backupFirmwareProgress(int chunk, int total);

        /*!
         * This signal is emitted during bootloader flashing.
         * \param chunk chunk number which was flashed (1 - N)
         * \param total total count of bootloader chunks (N)
         */
        void flashBootloaderProgress(int chunk, int total);

        /*!
         * This signal is emitted when device properties are changed (e.g. board switched to/from bootloader).
         */
        void devicePropertiesChanged();

    private slots:
        void handleOperationFinished(device::operation::Type opType, int data);
        void handleOperationError(QString errStr);

    private:
        void flash(bool flashFirmware, bool startApplication);
        void startFlash();
        void manageFlash(int lastFlashedChunk);
        void startBackup();
        void manageBackup(int chunkNumber);
        void finish(Result result);
        void connectHandlers(device::operation::BaseDeviceOperation* operation);

        device::DevicePtr device_;

        QFile binaryFile_;
        QString fileMD5_;

        std::unique_ptr<device::operation::BaseDeviceOperation> operation_;

        int chunkNumber_;
        int chunkCount_;
        int chunkProgress_;

        enum class Action {
            FlashFirmware,
            FlashBootloader,
            BackupFirmware
        };
        Action action_;

        bool startApp_;
};

}  // namespace

#endif
