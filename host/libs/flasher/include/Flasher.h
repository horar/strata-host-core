#ifndef FLASHER_H_
#define FLASHER_H_

#include <QObject>
#include <QFile>

#include <memory>

#include <Device/Device.h>

namespace strata::device {

class DeviceOperations;
enum class DeviceOperation: int;

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
         * \param chunk chunk number which was flashed
         * \param total total count of firmware chunks
         */
        void flashFirmwareProgress(int chunk, int total);

        /*!
         * This signal is emitted during firmware backup.
         * \param chunk chunk number which was backed up
         * \param total total count of firmware chunks
         */
        void backupFirmwareProgress(int chunk, int total);

        /*!
         * This signal is emitted during bootloader flashing.
         * \param chunk chunk number which was flashed
         * \param total total count of bootloader chunks
         */
        void flashBootloaderProgress(int chunk, int total);

        /*!
         * This signal is emitted when device properties are changed (e.g. board switched to/from bootloader).
         */
        void devicePropertiesChanged();

    private slots:
        void handleOperationFinished(device::DeviceOperation operation, int data);
        void handleOperationError(QString errStr);

    private:
        void flash(bool flashFirmware, bool startApplication);
        void handleFlash(int lastFlashedChunk);
        void handleBackup(int chunkNumber);
        void finish(Result result);

        device::DevicePtr device_;

        QFile binaryFile_;

        std::unique_ptr<device::DeviceOperations> operation_;

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
