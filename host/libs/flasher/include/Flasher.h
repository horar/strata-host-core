#ifndef FLASHER_H_
#define FLASHER_H_

#include <QObject>
#include <QFile>

#include <memory>

#include <Device/Device.h>

namespace strata::device::operation {
    class BaseDeviceOperation;
    enum class Result : int;
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
         * The AuxiliaryState enum for auxiliaryState() signal.
         */
        enum class AuxiliaryState {
            SwitchingToBootloader,
            InBootloaderMode,
            ClearFwClassId,
            SetFwClassId,
            StartApplication,
            IdentifyBoard
        };
        Q_ENUM(AuxiliaryState)

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
         * Flasher constructor.
         * \param device device which will be used by Flasher
         * \param fileName path to firmware (or bootloader) file
         * \param fileMD5 MD5 checksum of file which will be flashed
         * \param fwClassId device firmware class id (UUID v4)
         */
        Flasher(const device::DevicePtr& device, const QString& fileName, const QString& fileMD5, const QString& fwClassId);

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
         * Flash bootloader.
         */
        void flashBootloader();

        /*!
         * Backup firmware.
         * \param startApplication if set to true start application after backup
         */
        void backupFirmware(bool startApplication = true);

        /*!
         * Cancel flash firmware operation.
         */
        void cancel();

    signals:
        /*!
         * This signal is emitted when Flasher finishes.
         * \param result result of firmware operation
         * \param errorString error description if result is Error
         */
        void finished(Result result, QString errorString);

        /*!
         * This signal is emitted with request to switch the board to bootloader mode
         * and when board is successfully switched to bootloader.
         * \param done true when board was successfully switched to bootloader
         */
        void switchToBootloader(bool done);

        /*!
         * This signal is emitted when flasher is in auxiliary state.
         * \param auxState value from AuxiliaryState enum (defining current auxiliary state)
         */
        void auxiliaryState(AuxiliaryState auxState);

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
         * This signal is emitted when device properties are changed (board switched to/from bootloader, fwClassId changed).
         */
        void devicePropertiesChanged();

    private slots:
        void handleOperationFinished(device::operation::Result result, int status, QString errStr);

    private:
        // flash firmware of bootloader
        void flash(bool flashFirmware);
        // do next operation in flash (backup) process
        void doNextOperation(device::operation::BaseDeviceOperation* baseOp, int status);
        // create operation to flash or back up firmware
        std::unique_ptr<device::operation::BaseDeviceOperation, void(*)(device::operation::BaseDeviceOperation*)> createFlasherOperation();
        // manage flash process - handle flashed chunks
        void manageFlash(int lastFlashedChunk);
        // manage backup process - handle becked up chunks
        void manageBackup(int chunkNumber);
        // finish flasher
        void finish(Result result, QString errorString = QString());
        // connect handlers for flasher operation
        void connectHandlers(device::operation::BaseDeviceOperation* operation);
        // deleter for flasher operations
        static void operationDeleter(device::operation::BaseDeviceOperation* operation);

        device::DevicePtr device_;

        QFile binaryFile_;
        QString fileMD5_;
        bool fileFlashed_;

        QString fwClassId_;

        std::unique_ptr<device::operation::BaseDeviceOperation, void(*)(device::operation::BaseDeviceOperation*)> operation_;

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
