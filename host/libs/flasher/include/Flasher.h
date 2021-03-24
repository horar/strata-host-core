#ifndef FLASHER_H_
#define FLASHER_H_

#include <QObject>
#include <QFile>

#include <memory>
#include <functional>
#include <vector>
#include <chrono>

#include <Device.h>

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
         * The State enum for flasherState() signal.
         */
        enum class State {
            SwitchToBootloader,
            ClearFwClassId,
            SetFwClassId,
            FlashFirmware,
            FlashBootloader,
            BackupFirmware,
            StartApplication,
            IdentifyBoard
        };
        Q_ENUM(State)

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
         * Set firmware class ID (without flashing firmware).
         * \param startApplication if set to true start application after setting firmware class ID
         */
        void setFwClassId(bool startApplication = true);

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
         * This signal is emitted when flasher state is changed.
         * \param flasherState value from FlasherState enum (defining current flasher state)
         * \param done false if flasher just reached this state, true if flasher finished this state
         */
        void flasherState(State flasherState, bool done);

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

        // private signal:
        void nextOperation(QPrivateSignal);

    private slots:
        // run current operation from operationList_
        void runFlasherOperation();
        // process operation finished signal
        void handleOperationFinished(device::operation::Result result, int status, QString errStr);

    private:
        // check if flasher action can start
        bool startActionCheck(const QString& errorString);
        // prepare for flash (file checks)
        bool prepareForFlash(bool flashFirmware);
        // prepare for backup (file checks)
        bool prepareForBackup();

        // run next operation in operationList_
        void runNextOperation();
        // finish flasher
        void finish(Result result, QString errorString = QString());

        // hanlers which are called when operation in operationList_ finishes
        void startBootloaderFinished(int status);
        void setAssistPlatfIdFinished(int status);
        void flashFinished(bool flashingFirmware, int status);
        void backupFinished(int status);
        void startApplicationFinished(int status);
        void identifyFinished(bool flashingFirmware, int status);

        // flash logic
        void manageFlash(bool flashingFirmware, int lastFlashedChunk);
        // backup logic
        void manageBackup(int chunkNumber);

        // deleter for flasher oparation
        static void operationDeleter(device::operation::BaseDeviceOperation* operation);

        // error logic when dynamic_cast on DeviceOperation fails
        void operationCastError();

        // methods for adding operations to operationList_
        void addSwitchToBootloaderOperation();
        void addSetFwClassIdOperation(bool clear = false);
        void addFlashOperation(bool flashingFirmware);
        void addBackupFirmwareOperation();
        void addStartApplicationOperation();
        void addIdentifyOperation(bool flashingFirmware, std::chrono::milliseconds delay = std::chrono::milliseconds(0));

        typedef std::unique_ptr<device::operation::BaseDeviceOperation, void(*)(device::operation::BaseDeviceOperation*)> OperationPtr;

        struct FlasherOperation {
            FlasherOperation(OperationPtr&& deviceOperation,
                             State stateOfFlasher,
                             const std::function<void(int)>& finishedOperationHandler,
                             const Flasher* parent);
            OperationPtr operation;
            State state;
            std::function<void(int)> finishedHandler;
            const Flasher* flasher;
        };

        std::vector<FlasherOperation> operationList_;
        std::vector<FlasherOperation>::iterator currentOperation_;

        device::DevicePtr device_;

        QFile binaryFile_;
        QString fileMD5_;
        bool fileFlashed_;

        QString fwClassId_;

        int chunkNumber_;
        int chunkCount_;
        int chunkProgress_;

        enum class Action {
            FlashFirmware,
            FlashBootloader,
            BackupFirmware,
            SetFwClassId
        };
        Action action_;
};

}  // namespace

#endif
