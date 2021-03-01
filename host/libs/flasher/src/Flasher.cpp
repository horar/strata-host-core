#include "Flasher.h"
#include "FlasherConstants.h"

#include <QCryptographicHash>

#include <Device/Operations/StartBootloader.h>
#include <Device/Operations/Flash.h>
#include <Device/Operations/Backup.h>
#include <Device/Operations/SetAssistedPlatformId.h>
#include <Device/Operations/StartApplication.h>
#include <Device/Operations/Identify.h>
#include <DeviceOperationsStatus.h>

#include "logging/LoggingQtCategories.h"

namespace strata {

using device::DevicePtr;

namespace operation = device::operation;

Flasher::Flasher(const DevicePtr& device, const QString& fileName) :
    Flasher(device, fileName, QString(), QString()) { }

Flasher::Flasher(const DevicePtr& device, const QString& fileName, const QString& fileMD5) :
    Flasher(device, fileName, fileMD5, QString()) { }

Flasher::Flasher(const DevicePtr& device, const QString& fileName, const QString& fileMD5, const QString& fwClassId) :
    device_(device), binaryFile_(fileName), fileMD5_(fileMD5), fwClassId_(fwClassId)
{
    connect(this, &Flasher::nextOperation, this, &Flasher::runFlasherOperation, Qt::QueuedConnection);
    currentOperation_ = operationList_.end();

    qCDebug(logCategoryFlasher) << device_ << "Flasher created (unique ID: 0x" << hex << reinterpret_cast<quintptr>(this) << ").";
}

Flasher::~Flasher()
{
    if ((operationList_.size() != 0) && (currentOperation_ != operationList_.end())) {
        currentOperation_->operation->disconnect();
        currentOperation_->operation->cancelOperation();
    }
    qCDebug(logCategoryFlasher) << device_ << "Flasher deleted (unique ID: 0x" << hex << reinterpret_cast<quintptr>(this) << ").";
}

void Flasher::flashFirmware(bool startApplication)
{
    constexpr bool flashingFw = true;
    action_ = Action::FlashFirmware;

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

    if (startApplication) {
        addStartApplicationOperation();    // start application
    } else {
        addIdentifyOperation(flashingFw);  // identify board
    }

    currentOperation_ = operationList_.begin();

    runFlasherOperation();
}

void Flasher::flashBootloader()
{
    constexpr bool flashingFw = false;
    action_ = Action::FlashBootloader;

    if (startActionCheck(QStringLiteral("Cannot flash bootloader")) == false) {
        return;
    }

    if (prepareForFlash(flashingFw) == false) {
        return;
    }

    operationList_.reserve(3);

    addSwitchToBootloaderOperation();                            // switch to bootloader

    addFlashOperation(flashingFw);                               // flash bootloader

    // starting new bootloader takes some time
    addIdentifyOperation(flashingFw, IDENTIFY_OPERATION_DELAY);  // identify board

    currentOperation_ = operationList_.begin();

    runFlasherOperation();
}

void Flasher::backupFirmware(bool startApplication)
{
    action_ = Action::BackupFirmware;

    if (startActionCheck(QStringLiteral("Cannot backup firmware")) == false) {
        return;
    }

    if (prepareForBackup() == false) {
        return;
    }

    operationList_.reserve(3);

    addSwitchToBootloaderOperation();    // switch to bootloader

    addBackupFirmwareOperation();        // backup firmware

    if (startApplication) {
        addStartApplicationOperation();  // start application
    }

    currentOperation_ = operationList_.begin();

    runFlasherOperation();
}

void Flasher::setFwClassId(bool startApplication)
{
    action_ = Action::SetFwClassId;

    if (startActionCheck(QStringLiteral("Cannot set firmware class ID")) == false) {
        return;
    }

    if (fwClassId_.isNull()) {
        QString errStr(QStringLiteral("Cannot set firmware class ID, no fwClassId was provided."));
        qCCritical(logCategoryFlasher) << device_ << errStr;
        finish(Result::Error, errStr);
        return;
    }

    operationList_.reserve(3);

    addSwitchToBootloaderOperation();    // switch to bootloader

    addSetFwClassIdOperation(false);     // set fw_class_id

    if (startApplication) {
        addStartApplicationOperation();  // start application
    }

    currentOperation_ = operationList_.begin();

    runFlasherOperation();
}

void Flasher::cancel()
{
    if ((operationList_.size() != 0) && (currentOperation_ != operationList_.end())) {
        currentOperation_->operation->cancelOperation();
        qCWarning(logCategoryFlasher) << device_ << "Firmware operation was cancelled.";
        finish(Result::Cancelled);
    }
}

bool Flasher::startActionCheck(const QString& errorString)
{
    if (operationList_.size() != 0) {
        QString errorMessage = errorString + QStringLiteral(", flasher is already running.");
        qCCritical(logCategoryFlasher) << device_ << errorMessage;
        finish(Result::Error, errorMessage);
        return false;
    }
    return true;
}

bool Flasher::prepareForFlash(bool flashingFirmware)
{
    if (binaryFile_.open(QIODevice::ReadOnly)) {
        if (binaryFile_.size() > 0) {
            {
                QCryptographicHash hash(QCryptographicHash::Algorithm::Md5);
                hash.addData(&binaryFile_);
                QString md5 = hash.result().toHex();
                binaryFile_.seek(0);
                if (fileMD5_.isEmpty()) {
                    fileMD5_ = md5;
                } else {
                    if (fileMD5_ != md5) {
                        QString errStr(QStringLiteral("Wrong MD5 checksum of file to be flashed."));
                        qCCritical(logCategoryFlasher) << device_ << errStr;
                        finish(Result::Error, errStr);
                        return false;
                    }
                }
            }
            chunkNumber_ = -1;  // set chunk number to last flashed chunk (-1 means that no chunk was flashed yet)
            chunkCount_ = static_cast<int>((binaryFile_.size() - 1 + CHUNK_SIZE) / CHUNK_SIZE);
            chunkProgress_ = FLASH_PROGRESS_STEP;
            const char* binaryType = (flashingFirmware) ? "firmware" : "bootloader";
            qCInfo(logCategoryFlasher) << device_ << "Preparing for flashing " << chunkCount_ << " chunks of " << binaryType << '.';
        } else {
            QString errStr = QStringLiteral("File '") + binaryFile_.fileName() + QStringLiteral("' is empty.");
            qCCritical(logCategoryFlasher) << device_ << errStr;
            finish(Result::Error, errStr);
            return false;
        }
    } else {
        qCCritical(logCategoryFlasher) << device_ << "Cannot open file '" << binaryFile_.fileName() << "'. " << binaryFile_.errorString();
        finish(Result::Error, binaryFile_.errorString());
        return false;
    }

    return true;
}

bool Flasher::prepareForBackup()
{
    if (binaryFile_.open(QIODevice::WriteOnly)) {
        chunkProgress_ = BACKUP_PROGRESS_STEP;
        chunkCount_ = 0;
        qCInfo(logCategoryFlasher) << device_ << "Preparing for firmware backup.";
        return true;
    } else {
        qCCritical(logCategoryFlasher) << device_ << "Cannot open file '" << binaryFile_.fileName() << "'. " << binaryFile_.errorString();
        finish(Result::Error, binaryFile_.errorString());
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
    if (binaryFile_.isOpen()) {
        binaryFile_.close();
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
        qCCritical(logCategoryFlasher) << device_ << "Timeout during firmware operation.";
        finish(Result::Timeout);
        break;
    case operation::Result::Cancel :
        // Do nothing
        break;
    case operation::Result::Reject :
    case operation::Result::Failure :
        {
            QString errMsg(QStringLiteral("Firmware operation has failed (faulty response from device)."));
            qCCritical(logCategoryFlasher) << device_ << errMsg;
            finish(Result::Error, errMsg);
        }
        break;
    case operation::Result::Error:
        qCCritical(logCategoryFlasher) << device_ << "Error during flashing: " << errStr;
        finish(Result::Error, errStr);
        break;
    }
}

Flasher::FlasherOperation::FlasherOperation(
        OperationPtr&& deviceOperation,
        State stateOfFlasher,
        const std::function<void(int)>& finishedOperationHandler,
        const Flasher* parent)
    : operation(std::move(deviceOperation)),
      state(stateOfFlasher),
      finishedHandler(finishedOperationHandler),
      flasher(parent)
{
    Q_ASSERT(flasher != nullptr);
    Q_ASSERT(operation != nullptr);

    flasher->connect(operation.get(), &operation::BaseDeviceOperation::finished, flasher, &Flasher::handleOperationFinished);
}

void Flasher::operationDeleter(operation::BaseDeviceOperation* operation)
{
    operation->deleteLater();
}

void Flasher::startBootloaderFinished(int status)
{
    qCInfo(logCategoryFlasher) << device_ << "Switched to bootloader (version '"
                               << device_->bootloaderVer() << "').";

    if (status == operation::DEFAULT_STATUS) {
        // Operation SwitchToBootloader has status set to OPERATION_ALREADY_IN_BOOTLOADER (1) if board was
        // already in bootloader mode, otherwise status has default value DEFAULT_STATUS (INT_MIN).
        emit devicePropertiesChanged();
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
        finish(Result::NoFirmware);
        return;
    }

    qCInfo(logCategoryFlasher) << device_ << "Launching device software. Name: '" << device_->name()
                               << "', version: '" << device_->applicationVer() << "'.";
    emit devicePropertiesChanged();

    runNextOperation();
}

void Flasher::identifyFinished(bool flashingFirmware, int status)
{
    Q_UNUSED(status)

    if (flashingFirmware) {
        qCInfo(logCategoryFlasher) << device_ << "Firmware version: '"
                                   << device_->applicationVer() << "', device still in bootloader mode.";
    } else {
        qCInfo(logCategoryFlasher) << device_ << "Bootloader version: '" << device_->bootloaderVer() << "'.";
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
        qCCritical(logCategoryFlasher) << device_ << errStr << ' ' <<  binaryFile_.fileName();
        finish(Result::Error, errStr);
        return;
    }

    if (flashedChunk == chunkCount_) {  // the last chunk
        binaryFile_.close();

        qCInfo(logCategoryFlasher) << device_ << "Flashed chunk " << flashedChunk << " of " << chunkCount_;
        if (flashingFirmware) {
            qCInfo(logCategoryFlasher) << device_ << "Firmware is fully flashed.";
            emit flashFirmwareProgress(flashedChunk, chunkCount_);
        } else {
            qCInfo(logCategoryFlasher) << device_ << "Bootloader is fully flashed.";
            emit flashBootloaderProgress(flashedChunk, chunkCount_);
        }

        runNextOperation();

        return;
    }

    if (lastFlashedChunk >= 0) {  // if no chunk was flashed yet, 'lastFlashedChunk' is negative number (-1)
        if (flashedChunk == chunkProgress_) { // this is faster than modulo
            chunkProgress_ += FLASH_PROGRESS_STEP;
            qCInfo(logCategoryFlasher) << device_ << "Flashed chunk " << flashedChunk << " of " << chunkCount_;
            (flashingFirmware)
                ? emit flashFirmwareProgress(flashedChunk, chunkCount_)
                : emit flashBootloaderProgress(flashedChunk, chunkCount_);
        } else {
            qCDebug(logCategoryFlasher) << device_ << "Flashed chunk " << flashedChunk << " of " << chunkCount_;
        }
    }

    if (binaryFile_.atEnd()) {
        QString errStr(QStringLiteral("Unexpected end of file."));
        qCCritical(logCategoryFlasher) << device_ << errStr << ' ' <<  binaryFile_.fileName();
        finish(Result::Error, errStr);
        return;
    }

    int chunkSize = CHUNK_SIZE;
    qint64 remainingFileSize = binaryFile_.size() - binaryFile_.pos();
    if (remainingFileSize <= CHUNK_SIZE) {  // the last chunk
        chunkSize = static_cast<int>(remainingFileSize);
    }
    QVector<quint8> chunk(chunkSize);

    qint64 bytesRead = binaryFile_.read(reinterpret_cast<char*>(chunk.data()), chunkSize);
    if (bytesRead == chunkSize) {
        operation::Flash *flashOp = dynamic_cast<operation::Flash*>(currentOperation_->operation.get());
        if (flashOp != nullptr) {
            ++chunkNumber_;
            flashOp->flashChunk(chunk, chunkNumber_);
        } else {
            operationCastError();
        }
    } else {
        qCCritical(logCategoryFlasher) << device_ << "Cannot read from file '" << binaryFile_.fileName() << "'. " << binaryFile_.errorString();
        finish(Result::Error, QStringLiteral("File read error. ") + binaryFile_.errorString());
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
        if (chunkCount_ <= 0) {
            qCWarning(logCategoryFlasher) << "Cannot backup firmware which has 0 chunks.";
            // Operation 'Backup' is currently runing, it must be cancelled.
            currentOperation_->operation->cancelOperation();
            finish(Result::NoFirmware);
            return;
        }
    } else {
        QVector<quint8> chunk = backupOp->recentBackupChunk();
        qint64 bytesWritten = binaryFile_.write(reinterpret_cast<char*>(chunk.data()), chunk.size());
        if (bytesWritten != chunk.size()) {
            qCCritical(logCategoryFlasher) << device_ << "Cannot write to file '" << binaryFile_.fileName() << "'. " << binaryFile_.errorString();
            finish(Result::Error, QStringLiteral("File write error. ") + binaryFile_.errorString());
            return;
        }

        // Bootloader uses range 0 to N-1 for chunk numbers, our signals use range 1 to N.
        ++chunkNumber;  // move chunk number to range from 1 to N

        if (chunkNumber < chunkCount_) {
            if (chunkNumber == chunkProgress_) { // this is faster than modulo
                chunkProgress_ += BACKUP_PROGRESS_STEP;
                qCInfo(logCategoryFlasher) << device_ << "Backed up chunk " << chunkNumber << " of " << chunkCount_;
                emit backupFirmwareProgress(chunkNumber, chunkCount_);
            } else {
                qCDebug(logCategoryFlasher) << device_ << "Backed up chunk " << chunkNumber << " of " << chunkCount_;
            }
        } else {  // the last chunk
            binaryFile_.close();

            qCInfo(logCategoryFlasher) << device_ << "Backed up chunk " << chunkNumber << " of " << chunkCount_;
            qCInfo(logCategoryFlasher) << device_ << "Firmware is backed up.";
            emit backupFirmwareProgress(chunkNumber, chunkCount_);

            runNextOperation();
            return;
        }
    }

    backupOp->backupNextChunk();
}

void Flasher::operationCastError()
{
    QString errStr(QStringLiteral("Unexpected flasher operation error."));
    qCCritical(logCategoryFlasher) << device_ << errStr;
    finish(Result::Error, errStr);
}

void Flasher::addSwitchToBootloaderOperation()
{
    operationList_.emplace_back(
            OperationPtr(new operation::StartBootloader(device_), operationDeleter),
            State::SwitchToBootloader,
            std::bind(&Flasher::startBootloaderFinished, this, std::placeholders::_1),
            this);
}

void Flasher::addSetFwClassIdOperation(bool clear)
{
    operation::SetAssistedPlatformId* setAssisted = new operation::SetAssistedPlatformId(device_);
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
            OperationPtr(new operation::Flash(device_, binaryFile_.size(), chunkCount_, fileMD5_, flashingFirmware), operationDeleter),
            (flashingFirmware) ? State::FlashFirmware : State::FlashBootloader,
            std::bind(&Flasher::flashFinished, this, flashingFirmware, std::placeholders::_1),
            this);
}

void Flasher::addBackupFirmwareOperation()
{
    operationList_.emplace_back(
            OperationPtr(new operation::Backup(device_), operationDeleter),
            State::BackupFirmware,
            std::bind(&Flasher::backupFinished, this, std::placeholders::_1),
            this);
}

void Flasher::addStartApplicationOperation()
{
    operationList_.emplace_back(
            OperationPtr(new operation::StartApplication(device_), operationDeleter),
            State::StartApplication,
            std::bind(&Flasher::startApplicationFinished, this, std::placeholders::_1),
            this);
}

void Flasher::addIdentifyOperation(bool flashingFirmware, std::chrono::milliseconds delay)
{
    operationList_.emplace_back(
            OperationPtr(new operation::Identify(device_, true, MAX_GET_FW_INFO_RETRIES, delay), operationDeleter),
            State::IdentifyBoard,
            std::bind(&Flasher::identifyFinished, this, flashingFirmware, std::placeholders::_1),
            this);
}

}  // namespace
