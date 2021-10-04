/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#ifndef FLASHER_H_
#define FLASHER_H_

#include <QObject>
#include <QFile>
#include <QSaveFile>

#include <memory>
#include <functional>
#include <vector>
#include <chrono>

#include <Platform.h>

namespace strata::platform::operation {
    class BasePlatformOperation;
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
            Ok,          // successfully done
            NoFirmware,  // device has no firmware
            BadFirmware, // firmware is bad - it cannot start
            Error,       // error during firmware / bootloader operation
            Disconnect,  // device disconnected
            Timeout,     // command timed out
            Cancelled    // operation cancelled
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
         * The FinalAction enum for Flasher methods.
         */
        enum class FinalAction {
            StartApplication,  // start application
            StayInBootloader,  // stay in bootloader mode
            PreservePlatformState,  // preserve initial platform state:
                                    //  start application if it was running before
                                    //  or otherwise stay in bootloader mode
        };

        /*!
         * Flasher constructor.
         * \param platform platform which will be used by Flasher
         * \param fileName path to firmware (or bootloader) file
         */

        Flasher(const platform::PlatformPtr& platform, const QString& fileName);
        /*!
         * Flasher constructor.
         * \param platform platform which will be used by Flasher
         * \param fileName path to firmware (or bootloader) file
         * \param fileMD5 MD5 checksum of file which will be flashed
         */
        Flasher(const platform::PlatformPtr& platform, const QString& fileName, const QString& fileMD5);

        /*!
         * Flasher constructor.
         * \param platform platform which will be used by Flasher
         * \param fileName path to firmware (or bootloader) file
         * \param fileMD5 MD5 checksum of file which will be flashed
         * \param fwClassId platform firmware class id (UUID v4)
         */
        Flasher(const platform::PlatformPtr& platform, const QString& fileName, const QString& fileMD5, const QString& fwClassId);

        /*!
         * Flasher destructor.
         */
        ~Flasher();

        /*!
         * Flash firmware.
         * \param finalAction value from FinalAction enum, defines what to do after flash
         * NOTE: Flash firmware process is not completed until application is not started!
         *       Application writes data like its version into board memory (into FIB).
         */
        void flashFirmware(FinalAction finalAction);

        /*!
         * Flash bootloader.
         */
        void flashBootloader();

        /*!
         * Backup firmware.
         * \param finalAction value from FinalAction enum, defines what to do after backup
         */
        void backupFirmware(FinalAction finalAction);

        /*!
         * Set firmware class ID (without flashing firmware).
         * \param finalAction value from FinalAction enum, defines what to do after setting firmware class ID
         */
        void setFwClassId(FinalAction finalAction);

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
         * This signal is emitted when platform properties are changed (board switched to/from bootloader, fwClassId changed).
         */
        void devicePropertiesChanged();

        // private signals:
        void nextOperation(QPrivateSignal);
        void flashNextChunk(QPrivateSignal);

    private slots:
        // run current operation from operationList_
        void runFlasherOperation();
        // process operation finished signal
        void handleOperationFinished(platform::operation::Result result, int status, QString errStr);
        // process operation partialStatus signal
        void handleOperationPartialStatus(int status);
        // flash next firmware/bootloader chunk
        void handleFlashNextChunk();

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
        static void operationDeleter(platform::operation::BasePlatformOperation* operation);

        // error logic when dynamic_cast on PlatformOperation fails
        void operationCastError();

        // methods for adding operations to operationList_
        void addSwitchToBootloaderOperation();
        void addSetFwClassIdOperation(bool clear = false);
        void addFlashOperation(bool flashingFirmware);
        void addBackupFirmwareOperation();
        void addStartApplicationOperation();
        void addIdentifyOperation(bool flashingFirmware, std::chrono::milliseconds delay = std::chrono::milliseconds(0));

        typedef std::unique_ptr<platform::operation::BasePlatformOperation, void(*)(platform::operation::BasePlatformOperation*)> OperationPtr;

        enum class FlasherActivity {
            FlashFirmware,
            FlashBootloader,
            BackupFirmware,
            SetFwClassId
        };
        FlasherActivity activity_;

        struct FlasherOperation {
            FlasherOperation(OperationPtr&& platformOperation,
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

        platform::PlatformPtr platform_;

        FinalAction finalAction_;

        const QString fileName_;
        QFile sourceFile_;
        QSaveFile destinationFile_;
        QString fileMD5_;
        bool fileFlashed_;

        QString fwClassId_;

        int chunkNumber_;
        int chunkCount_;
        int chunkProgress_;
        int expectedBackupChunkNumber_;
        uint actualBackupSize_;
        uint expectedBackupSize_;
};

}  // namespace

#endif
