#include "Flasher.h"
#include "FlasherConstants.h"

#include <QCryptographicHash>
#include <QFileInfo>
#include <QDir>

#include <Operations/StartBootloader.h>
#include <Operations/Flash.h>
#include <Operations/Backup.h>
#include <Operations/SetAssistedPlatformId.h>
#include <Operations/StartApplication.h>
#include <Operations/Identify.h>
#include <PlatformOperationsStatus.h>

#include "logging/LoggingQtCategories.h"

namespace strata {

using platform::PlatformPtr;

namespace operation = platform::operation;

Flasher::Flasher(const PlatformPtr& platform, const QString& fileName) :
    Flasher(platform, fileName, QString(), QString()) { }

Flasher::Flasher(const PlatformPtr& platform, const QString& fileName, const QString& fileMD5) :
    Flasher(platform, fileName, fileMD5, QString()) { }

Flasher::Flasher(const PlatformPtr& platform, const QString& fileName, const QString& fileMD5, const QString& fwClassId) :
    platform_(platform),
    fileName_(fileName),
    sourceFile_(this),
    destinationFile_(this),
    fileMD5_(fileMD5),
    fwClassId_(fwClassId)
{
    connect(this, &Flasher::nextOperation, this, &Flasher::runFlasherOperation, Qt::QueuedConnection);
    connect(this, &Flasher::flashNextChunk, this, &Flasher::handleFlashNextChunk, Qt::QueuedConnection);
    currentOperation_ = operationList_.end();

    qCDebug(logCategoryFlasher) << platform_ << "Flasher created (unique ID: 0x" << hex << reinterpret_cast<quintptr>(this) << ").";
}

Flasher::~Flasher()
{
    if ((operationList_.size() != 0) && (currentOperation_ != operationList_.end())) {
        currentOperation_->operation->disconnect(this);
        currentOperation_->operation->cancelOperation();
    }
    qCDebug(logCategoryFlasher) << platform_ << "Flasher deleted (unique ID: 0x" << hex << reinterpret_cast<quintptr>(this) << ").";
}

void Flasher::flashFirmware(FinalAction finalAction)
{
    activity_ = FlasherActivity::FlashFirmware;
    finalAction_ = finalAction;
    constexpr bool flashingFw = true;

    if (startActionCheck(QStringLiteral("Cannot flash firmware")) == false) {
        return;
    }

    if (prepareForFlash(flashingFw) == false) {
        return;
    }

    operationList_.reserve(5);

    addSwitchToBootloaderOperation();      // switch to bootloader

    if (fwClassId_.isNull() == false) {
        addSetFwClassIdOperation(true);    // clear fw_class_id
    }

    addFlashOperation(flashingFw);         // flash firmware

    if (fwClassId_.isNull() == false) {
        addSetFwClassIdOperation(false);   // set fw_class_id
    }

    switch (finalAction_) {
    case FinalAction::StartApplication :
        addStartApplicationOperation();    // start application
        break;
    case FinalAction::StayInBootloader :
        addIdentifyOperation(flashingFw);  // identify board
        break;
    case FinalAction::PreservePlatformState :
        // Do nothing here, right operation will be added to 'operationList_' later
        // in 'startBootloaderFinished()' operation when platform will be identified.
        // It can be added later because it is added to the end of the 'operationList_'.
        break;
    }

    currentOperation_ = operationList_.begin();

    runFlasherOperation();
}

void Flasher::flashBootloader()
{
    activity_ = FlasherActivity::FlashBootloader;
    constexpr bool flashingFw = false;
    std::chrono::milliseconds identifyDelay = (platform_->deviceType() == device::Device::Type::MockDevice) ? IDENTIFY_OPERATION_MOCK_DELAY : IDENTIFY_OPERATION_DELAY;

    if (startActionCheck(QStringLiteral("Cannot flash bootloader")) == false) {
        return;
    }

    if (prepareForFlash(flashingFw) == false) {
        return;
    }

    operationList_.reserve(3);

    addSwitchToBootloaderOperation();                 // switch to bootloader

    addFlashOperation(flashingFw);                    // flash bootloader

    // starting new bootloader takes some time
    addIdentifyOperation(flashingFw, identifyDelay);  // identify board

    currentOperation_ = operationList_.begin();

    runFlasherOperation();
}

void Flasher::backupFirmware(FinalAction finalAction)
{
    activity_ = FlasherActivity::BackupFirmware;
    finalAction_ = finalAction;

    if (startActionCheck(QStringLiteral("Cannot backup firmware")) == false) {
        return;
    }

    if (prepareForBackup() == false) {
        return;
    }

    operationList_.reserve(3);

    addSwitchToBootloaderOperation();    // switch to bootloader

    addBackupFirmwareOperation();        // backup firmware

    if (finalAction_ == FinalAction::StartApplication) {
        addStartApplicationOperation();  // start application
    }
    // If 'finalAction_' is 'PreservePlatformState', operation for start application
    // can be added later in 'startBootloaderFinished()' when platform will be identified.
    // It can be added later because it is added to the end of the 'operationList_'.

    currentOperation_ = operationList_.begin();

    runFlasherOperation();
}

void Flasher::setFwClassId(FinalAction finalAction)
{
    activity_ = FlasherActivity::SetFwClassId;
    finalAction_ = finalAction;

    if (startActionCheck(QStringLiteral("Cannot set firmware class ID")) == false) {
        return;
    }

    if (fwClassId_.isNull()) {
        QString errStr(QStringLiteral("Cannot set firmware class ID, no fwClassId was provided."));
        qCCritical(logCategoryFlasher) << platform_ << errStr;
        finish(Result::Error, errStr);
        return;
    }

    operationList_.reserve(3);

    addSwitchToBootloaderOperation();    // switch to bootloader

    addSetFwClassIdOperation(false);     // set fw_class_id

    if (finalAction_ == FinalAction::StartApplication) {
        addStartApplicationOperation();  // start application
    }
    // If 'finalAction_' is 'PreservePlatformState', operation for start application
    // can be added later in 'startBootloaderFinished()' when platform will be identified.
    // It can be added later because it is added to the end of the 'operationList_'.

    currentOperation_ = operationList_.begin();

    runFlasherOperation();
}

void Flasher::cancel()
{
    if ((operationList_.size() != 0) && (currentOperation_ != operationList_.end())) {
        currentOperation_->operation->cancelOperation();
    }
}

bool Flasher::startActionCheck(const QString& errorString)
{
    if (operationList_.size() != 0) {
        QString errorMessage = errorString + QStringLiteral(", flasher is already running.");
        qCCritical(logCategoryFlasher) << platform_ << errorMessage;
        finish(Result::Error, errorMessage);
        return false;
    }

    // platform could be rebooted (e.g. by j-link) and it
    // could send part of message before rebooting,
    // so reset receiving to drop possible incomplete message
    platform_->resetReceiving();

    return true;
}

bool Flasher::prepareForFlash(bool flashingFirmware)
{
    sourceFile_.setFileName(fileName_);
    if (sourceFile_.open(QIODevice::ReadOnly)) {
        if (sourceFile_.size() > 0) {
            {
                QCryptographicHash hash(QCryptographicHash::Algorithm::Md5);
                hash.addData(&sourceFile_);
                QString md5 = hash.result().toHex();
                sourceFile_.seek(0);
                if (fileMD5_.isEmpty()) {
                    fileMD5_ = md5;
                } else {
                    if (fileMD5_ != md5) {
                        QString errStr(QStringLiteral("Wrong MD5 checksum of file to be flashed."));
                        qCCritical(logCategoryFlasher) << platform_ << errStr;
                        finish(Result::Error, errStr);
                        return false;
                    }
                }
            }
            chunkNumber_ = -1;  // set chunk number to last flashed chunk (-1 means that no chunk was flashed yet)
            chunkCount_ = static_cast<int>((sourceFile_.size() - 1 + CHUNK_SIZE) / CHUNK_SIZE);
            chunkProgress_ = FLASH_PROGRESS_STEP;
            const char* binaryType = (flashingFirmware) ? "firmware" : "bootloader";
            qCInfo(logCategoryFlasher) << platform_ << "Preparing for flashing " << chunkCount_ << " chunks ("
                << CHUNK_SIZE << " bytes) of " << binaryType << " with size " << sourceFile_.size() << " bytes.";
        } else {
            QString errStr = QStringLiteral("File '") + sourceFile_.fileName() + QStringLiteral("' is empty.");
            qCCritical(logCategoryFlasher) << platform_ << errStr;
            finish(Result::Error, errStr);
            return false;
        }
    } else {
        qCCritical(logCategoryFlasher) << platform_ << "Cannot open file '" << fileName_ << "'. " << sourceFile_.errorString();
        finish(Result::Error, sourceFile_.errorString());
        return false;
    }

    return true;
}

bool Flasher::prepareForBackup()
{
    QFileInfo fileInfo(fileName_);
    QDir fileDir;
    if (fileDir.mkpath(fileInfo.absolutePath()) == false) {
        QString errStr(QStringLiteral("Cannot create path for backup file."));
        qCCritical(logCategoryFlasher) << platform_ << errStr;
        finish(Result::Error, errStr);
        return false;
    }

    destinationFile_.setFileName(fileName_);
    if (destinationFile_.open(QIODevice::WriteOnly)) {
        chunkProgress_ = BACKUP_PROGRESS_STEP;
        chunkCount_ = 0;
        expectedBackupChunkNumber_ = 1;
        actualBackupSize_ = 0;
        expectedBackupSize_ = 0;
        qCInfo(logCategoryFlasher) << platform_ << "Preparing to back up the firmware to the '" << fileName_ << "' file.";
        return true;
    } else {
        qCCritical(logCategoryFlasher) << platform_ << "Cannot open file '" << fileName_ << "'. " << destinationFile_.errorString();
        finish(Result::Error, destinationFile_.errorString());
        return false;
    }
}

void Flasher::runNextOperation()
{
    emit flasherState(currentOperation_->state, true);

    ++currentOperation_;
    emit nextOperation(QPrivateSignal());
}

void Flasher::runFlasherOperation()
{
    if (operationList_.empty()) {
        return;
    }

    if (currentOperation_ == operationList_.end()) {
        finish(Result::Ok);
        return;
    }

    emit flasherState(currentOperation_->state, false);

    currentOperation_->operation->run();
}

void Flasher::finish(Result result, QString errorString)
{
    operationList_.clear();
    currentOperation_ = operationList_.end();
    if (sourceFile_.isOpen()) {
        sourceFile_.close();
    }
    if (destinationFile_.isOpen()) {
        destinationFile_.cancelWriting();
    }
    emit finished(result, errorString);
}

void Flasher::handleOperationFinished(operation::Result result, int status, QString errStr)
{
    switch (result) {
    case operation::Result::Success :
        if (operationList_.empty() || currentOperation_ == operationList_.end()) {
            return;
        }
        if (currentOperation_->finishedHandler) {
            currentOperation_->finishedHandler(status);
        } else {
            runNextOperation();
        }
        break;
    case operation::Result::Timeout :
        qCCritical(logCategoryFlasher) << platform_ << "Timeout during firmware operation.";
        finish(Result::Timeout);
        break;
    case operation::Result::Cancel :
        qCWarning(logCategoryFlasher) << platform_ << "Firmware operation was cancelled.";
        finish(Result::Cancelled);
        break;
    case operation::Result::Reject :
    case operation::Result::Failure :
        {
            QString errMsg(QStringLiteral("Firmware operation has failed (faulty response from device)."));
            qCCritical(logCategoryFlasher) << platform_ << errMsg;
            finish(Result::Error, errMsg);
        }
        break;
    case operation::Result::Disconnect:
        {
            QString errMsg(QStringLiteral("Device disconnected during firmware operation."));
            qCCritical(logCategoryFlasher) << platform_ << errMsg;
            finish(Result::Disconnect, errMsg);
        }
    break;
    case operation::Result::Error:
        qCCritical(logCategoryFlasher) << platform_ << "Error during flashing: " << errStr;
        finish(Result::Error, errStr);
        break;
    }
}

void Flasher::handleOperationPartialStatus(int status)
{
    if (operationList_.empty() || currentOperation_ == operationList_.end()) {
        return;
    }

    if (currentOperation_->finishedHandler) {
        currentOperation_->finishedHandler(status);
    }
}

Flasher::FlasherOperation::FlasherOperation(
        OperationPtr&& platformOperation,
        State stateOfFlasher,
        const std::function<void(int)>& finishedOperationHandler,
        const Flasher* parent)
    : operation(std::move(platformOperation)),
      state(stateOfFlasher),
      finishedHandler(finishedOperationHandler),
      flasher(parent)
{
    Q_ASSERT(flasher != nullptr);
    Q_ASSERT(operation != nullptr);

    flasher->connect(operation.get(), &operation::BasePlatformOperation::finished, flasher, &Flasher::handleOperationFinished);
    flasher->connect(operation.get(), &operation::BasePlatformOperation::partialStatus, flasher, &Flasher::handleOperationPartialStatus);
}

void Flasher::operationDeleter(operation::BasePlatformOperation* operation)
{
    operation->deleteLater();
}

void Flasher::startBootloaderFinished(int status)
{
    qCInfo(logCategoryFlasher) << platform_ << "Switched to bootloader (version '"
                               << platform_->bootloaderVer() << "').";

    // Operation 'SwitchToBootloader' has status set to 'ALREADY_IN_BOOTLOADER' (1) if platform was
    // already in bootloader mode, otherwise status has default value 'DEFAULT_STATUS' (INT_MIN).
    if (status == operation::DEFAULT_STATUS) {
        if (finalAction_ == FinalAction::PreservePlatformState) {
            // Platform had been booted into application before and 'finalAction_' is
            // 'PreservePlatformState' so add operation for start application.
            switch (activity_) {
            case FlasherActivity::FlashFirmware :
            case FlasherActivity::BackupFirmware :
            case FlasherActivity::SetFwClassId :
                addStartApplicationOperation();
                break;
            case FlasherActivity::FlashBootloader :
                // Do nothing (platform has no application and this 'activity_' already contains 'Identify' operation).
                break;
            }
        }
        emit devicePropertiesChanged();
    } else if (status == operation::ALREADY_IN_BOOTLOADER) {
        if (finalAction_ == FinalAction::PreservePlatformState) {
            switch (activity_) {
            case FlasherActivity::FlashFirmware :
                addIdentifyOperation(true);
                break;
            case FlasherActivity::FlashBootloader :
            case FlasherActivity::BackupFirmware :
            case FlasherActivity::SetFwClassId :
                // Do nothing - firmware won't be changed (and 'FlashBootloader' already contains 'Identify' operation).
                break;
            }
        }
    }    

    runNextOperation();
}

void Flasher::setAssistPlatfIdFinished(int status)
{
    Q_UNUSED(status)

    emit devicePropertiesChanged();

    runNextOperation();
}

void Flasher::flashFinished(bool flashingFirmware, int status)
{
    if (status == operation::FLASH_STARTED) {
        manageFlash(flashingFirmware, -1);  // negative value (-1) means that no chunk was flashed yet
    } else {
        manageFlash(flashingFirmware, status);  // status contains chunk number
    }
}

void Flasher::backupFinished(int status)
{
    switch (status) {
    case operation::NO_FIRMWARE :
        finish(Result::NoFirmware);
        break;
    case operation::BACKUP_STARTED :
        manageBackup(-1);  // negative value (-1) means that no chunk was backed up yet
        break;
    default :
        manageBackup(status);  // status contains chunk number
        break;
    }
}

void Flasher::startApplicationFinished(int status)
{
    if (status == operation::NO_FIRMWARE) {
        qCCritical(logCategoryFlasher) << platform_ << "Platform has no firmware.";
        finish(Result::NoFirmware);
        return;
    }

    if (status == operation::FIRMWARE_UNABLE_TO_START) {
        qCCritical(logCategoryFlasher) << platform_ << "Platform firmware is unable to start, platform remains in bootloader mode.";
        finish(Result::BadFirmware);
        return;
    }

    qCInfo(logCategoryFlasher) << platform_ << "Launching platform firmware. Name: '" << platform_->name()
                               << "', version: '" << platform_->applicationVer() << "'.";
    emit devicePropertiesChanged();

    runNextOperation();
}

void Flasher::identifyFinished(bool flashingFirmware, int status)
{
    Q_UNUSED(status)

    if (flashingFirmware) {
        qCInfo(logCategoryFlasher) << platform_ << "Firmware version: '"
                                   << platform_->applicationVer() << "', platform still in bootloader mode.";
    } else {
        qCInfo(logCategoryFlasher) << platform_ << "Bootloader version: '" << platform_->bootloaderVer() << "'.";
    }

    emit devicePropertiesChanged();

    runNextOperation();
}

void Flasher::manageFlash(bool flashingFirmware, int lastFlashedChunk)
{
    // Bootloader uses range 0 to N-1 for chunk numbers, our signals use range 1 to N.
    int flashedChunk = lastFlashedChunk + 1;

    if (chunkNumber_ != lastFlashedChunk) {
        QString errStr(QStringLiteral("Received confirmation of flash unexpected chunk."));
        qCCritical(logCategoryFlasher) << platform_ << errStr << ' ' <<  sourceFile_.fileName();
        finish(Result::Error, errStr);
        return;
    }

    if (flashedChunk == chunkCount_) {  // the last chunk
        sourceFile_.close();

        qCInfo(logCategoryFlasher) << platform_ << "Flashed chunk " << flashedChunk << " of " << chunkCount_;
        if (flashingFirmware) {
            qCInfo(logCategoryFlasher) << platform_ << "Firmware is fully flashed.";
            emit flashFirmwareProgress(flashedChunk, chunkCount_);
        } else {
            qCInfo(logCategoryFlasher) << platform_ << "Bootloader is fully flashed.";
            emit flashBootloaderProgress(flashedChunk, chunkCount_);
        }

        runNextOperation();

        return;
    }

    if (lastFlashedChunk >= 0) {  // if no chunk was flashed yet, 'lastFlashedChunk' is negative number (-1)
        if (flashedChunk == chunkProgress_) { // this is faster than modulo
            chunkProgress_ += FLASH_PROGRESS_STEP;
            qCInfo(logCategoryFlasher) << platform_ << "Flashed chunk " << flashedChunk << " of " << chunkCount_;
            (flashingFirmware)
                ? emit flashFirmwareProgress(flashedChunk, chunkCount_)
                : emit flashBootloaderProgress(flashedChunk, chunkCount_);
        } else {
            qCDebug(logCategoryFlasher) << platform_ << "Flashed chunk " << flashedChunk << " of " << chunkCount_;
        }
    }

    emit flashNextChunk(QPrivateSignal());
}

void Flasher::handleFlashNextChunk()
{
    if (operationList_.empty() || currentOperation_ == operationList_.end()) {
        // flashing was cancelled or did not started yet
        return;
    }

    if (sourceFile_.atEnd()) {
        QString errStr(QStringLiteral("Unexpected end of file."));
        qCCritical(logCategoryFlasher) << platform_ << errStr << ' ' <<  sourceFile_.fileName();
        finish(Result::Error, errStr);
        return;
    }

    int chunkSize = CHUNK_SIZE;
    qint64 remainingFileSize = sourceFile_.size() - sourceFile_.pos();
    if (remainingFileSize <= CHUNK_SIZE) {  // the last chunk
        chunkSize = static_cast<int>(remainingFileSize);
    }
    QVector<quint8> chunk(chunkSize);

    qint64 bytesRead = sourceFile_.read(reinterpret_cast<char*>(chunk.data()), chunkSize);
    if (bytesRead == chunkSize) {
        operation::Flash *flashOp = dynamic_cast<operation::Flash*>(currentOperation_->operation.get());
        if (flashOp != nullptr) {
            ++chunkNumber_;
            flashOp->flashChunk(chunk, chunkNumber_);
        } else {
            operationCastError();
        }
    } else {
        qCCritical(logCategoryFlasher) << platform_ << "Cannot read from file '" << sourceFile_.fileName() << "'. " << sourceFile_.errorString();
        finish(Result::Error, QStringLiteral("File read error. ") + sourceFile_.errorString());
    }
}

void Flasher::manageBackup(int chunkNumber)
{
    operation::Backup *backupOp = dynamic_cast<operation::Backup*>(currentOperation_->operation.get());
    if (backupOp == nullptr) {
        operationCastError();
        return;
    }

    if (chunkNumber < 0) {  // if no chunk was backed up yet, 'chunkNumber' is negative number (-1)
        chunkCount_ = backupOp->totalChunks();
        expectedBackupSize_ = backupOp->backupSize();
        if ((chunkCount_ <= 0) || (expectedBackupSize_ <= 0)) {
            qCWarning(logCategoryFlasher) << "Cannot backup firmware which has 0 chunks or size 0.";
            // Operation 'Backup' is currently runing, it must be cancelled.
            currentOperation_->operation->disconnect(this);  // disconnect slots, we do not want to invoke 'handleOperationFinished()'
            currentOperation_->operation->cancelOperation();
            finish(Result::NoFirmware);
            return;
        }
    } else {
        // Bootloader uses range 0 to N-1 for chunk numbers, our signals use range 1 to N.
        ++chunkNumber;  // move chunk number to range from 1 to N

        if (chunkNumber == expectedBackupChunkNumber_) {
            ++expectedBackupChunkNumber_;
        } else {
            QString errStr(QStringLiteral("Received other chunk than expected."));
            qCCritical(logCategoryFlasher) << platform_ << errStr
                << " Expected chunk number: " << expectedBackupChunkNumber_ << ", received: " << chunkNumber << '.';
            finish(Result::Error, errStr);
            return;
        }

        const QVector<quint8> chunk = backupOp->recentBackupChunk();
        const qint64 bytesWritten = destinationFile_.write(reinterpret_cast<const char*>(chunk.data()), chunk.size());
        if (bytesWritten != chunk.size()) {
            qCCritical(logCategoryFlasher) << platform_ << "Cannot write to file '" << destinationFile_.fileName() << "'. " << destinationFile_.errorString();
            finish(Result::Error, QStringLiteral("File write error. ") + destinationFile_.errorString());
            return;
        }
        actualBackupSize_ += static_cast<uint>(chunk.size());

        if (chunkNumber < chunkCount_) {
            if (chunkNumber == chunkProgress_) { // this is faster than modulo
                chunkProgress_ += BACKUP_PROGRESS_STEP;
                qCInfo(logCategoryFlasher) << platform_ << "Backed up chunk " << chunkNumber << " of " << chunkCount_;
                emit backupFirmwareProgress(chunkNumber, chunkCount_);
            } else {
                qCDebug(logCategoryFlasher) << platform_ << "Backed up chunk " << chunkNumber << " of " << chunkCount_;
            }
        } else {  // the last chunk
            qCInfo(logCategoryFlasher) << platform_ << "Backed up chunk " << chunkNumber << " of " << chunkCount_;
            emit backupFirmwareProgress(chunkNumber, chunkCount_);

            if (actualBackupSize_ != expectedBackupSize_) {
                QString errStr(QStringLiteral("Received firmware size is different than expected."));
                qCCritical(logCategoryFlasher) << platform_ << errStr;
                finish(Result::Error, errStr);
                return;
            }
            if (destinationFile_.commit() == false) {
                qCCritical(logCategoryFlasher) << platform_ << "Cannot save file '" << destinationFile_.fileName() << "'. " << destinationFile_.errorString();
                finish(Result::Error, QStringLiteral("File save error. ") + destinationFile_.errorString());
                return;
            }

            qCInfo(logCategoryFlasher) << platform_ << "Firmware is backed up.";

            runNextOperation();
            return;
        }
    }

    backupOp->backupNextChunk();
}

void Flasher::operationCastError()
{
    QString errStr(QStringLiteral("Unexpected flasher operation error."));
    qCCritical(logCategoryFlasher) << platform_ << errStr;
    finish(Result::Error, errStr);
}

void Flasher::addSwitchToBootloaderOperation()
{
    operationList_.emplace_back(
            OperationPtr(new operation::StartBootloader(platform_), operationDeleter),
            State::SwitchToBootloader,
            std::bind(&Flasher::startBootloaderFinished, this, std::placeholders::_1),
            this);
}

void Flasher::addSetFwClassIdOperation(bool clear)
{
    operation::SetAssistedPlatformId* setAssisted = new operation::SetAssistedPlatformId(platform_);
    if (clear) {
        setAssisted->setFwClassId(QStringLiteral("00000000-0000-4000-0000-000000000000"));
    } else {
        setAssisted->setFwClassId(fwClassId_);
    }
    operationList_.emplace_back(
            OperationPtr(setAssisted, operationDeleter),
            (clear) ? State::ClearFwClassId : State::SetFwClassId,
            std::bind(&Flasher::setAssistPlatfIdFinished, this, std::placeholders::_1),
            this);
}

void Flasher::addFlashOperation(bool flashingFirmware)
{
    operationList_.emplace_back(
            OperationPtr(new operation::Flash(platform_, sourceFile_.size(), chunkCount_, fileMD5_, flashingFirmware), operationDeleter),
            (flashingFirmware) ? State::FlashFirmware : State::FlashBootloader,
            std::bind(&Flasher::flashFinished, this, flashingFirmware, std::placeholders::_1),
            this);
}

void Flasher::addBackupFirmwareOperation()
{
    operationList_.emplace_back(
            OperationPtr(new operation::Backup(platform_), operationDeleter),
            State::BackupFirmware,
            std::bind(&Flasher::backupFinished, this, std::placeholders::_1),
            this);
}

void Flasher::addStartApplicationOperation()
{
    operationList_.emplace_back(
            OperationPtr(new operation::StartApplication(platform_), operationDeleter),
            State::StartApplication,
            std::bind(&Flasher::startApplicationFinished, this, std::placeholders::_1),
            this);
}

void Flasher::addIdentifyOperation(bool flashingFirmware, std::chrono::milliseconds delay)
{
    operationList_.emplace_back(
            OperationPtr(new operation::Identify(platform_, true, MAX_GET_FW_INFO_RETRIES, delay), operationDeleter),
            State::IdentifyBoard,
            std::bind(&Flasher::identifyFinished, this, flashingFirmware, std::placeholders::_1),
            this);
}

}  // namespace
