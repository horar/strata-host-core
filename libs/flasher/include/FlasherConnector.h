/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#ifndef FLASHER_CONNECTOR_H_
#define FLASHER_CONNECTOR_H_

#include <memory>

#include <QObject>
#include <QString>
#include <QTemporaryFile>

#include <Platform.h>
#include <Flasher.h>
#include <Operations/PlatformOperations.h>

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
     * Flash firmware. Firmware (application) is always started when it is fully flashed.
     * \param backupBeforeFlash if set to true backup old firmware before flashing new one and if flash process fails flash old firmware back
     * \return true if flash process has started, otherwise false
     */
    bool flash(bool backupBeforeFlash = true);

    /*!
     * Backup firmware.
     * \param finalAction what to do after backup: start application, stay in bootloader or do not change state of borad's binary
     * \return true if backup process has started, otherwise false
     */
    bool backup(Flasher::FinalAction finalAction = Flasher::FinalAction::StartApplication);

    /*!
     * Set Firmware Class ID (without flashing firmware)
     * finalAction what to do after set FW clas ID: start application, stay in bootloader or do not change state of borad's binary
     * \return true if set process has started, otherwise false
     */
    bool setFwClassId(Flasher::FinalAction finalAction = Flasher::FinalAction::StartApplication);

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
        NoFirmware,
        BadFirmware
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
     * This signal is emitted when platform properties are changed (when platform is
     * switched to/from bootloader mode, fw_class_is is changed, ...).
     */
    void devicePropertiesChanged();

    /*!
     * This signal is emitted when 'start_bootloader' command was successful and bootloader is running.
     */
    void bootloaderActive();

    /*!
     * This signal is emitted when 'start_application' command was successful and application is running.
     */
    void applicationActive();

private slots:
    void handleFlasherFinished(Flasher::Result flasherResult, QString errorString);
    void handleFlasherState(Flasher::State flasherState, bool done);
    void handlePlatformOperationFinished(QByteArray deviceId,
                                         platform::operation::Type type,
                                         platform::operation::Result result,
                                         int status,
                                         QString errorString);

private:
    // deleter for flasher_ unique pointer
    static void flasherDeleter(Flasher* flasher);

    void flashFirmware(bool flashOldFw);
    void backupFirmware(bool backupOldFw, Flasher::FinalAction finalAction);
    void processStartupError(const QString& errorString);

    void removeBackupFile();

    void startApplicationFailed(const QString& errorString);

    platform::PlatformPtr platform_;

    typedef std::unique_ptr<Flasher, void(*)(Flasher*)> FlasherPtr;
    FlasherPtr flasher_;

    platform::operation::PlatformOperations platformOperations_;

    const QString filePath_;
    const QString newFirmwareMD5_;
    const QString newFwClassId_;
    QString oldFwClassId_;
    QString tmpBackupFileName_;

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
