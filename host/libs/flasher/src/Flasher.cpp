#include "Flasher.h"
#include "FlasherConstants.h"

#include <Device/DeviceOperations.h>

#include "logging/LoggingQtCategories.h"

namespace strata {

using device::DevicePtr;
using device::DeviceOperations;
using device::DeviceOperation;
using device::DeviceProperties;

Flasher::Flasher(const DevicePtr& device, const QString& firmwareFilename) :
    device_(device), fwFile_(firmwareFilename)
{
    operation_ = std::make_unique<DeviceOperations>(device_);

    connect(operation_.get(), &DeviceOperations::finished, this, &Flasher::handleOperationFinished);
    connect(operation_.get(), &DeviceOperations::error, this, &Flasher::handleOperationError);

    qCDebug(logCategoryFlasher) << device_ << "Flasher created (unique ID: 0x" << reinterpret_cast<quintptr>(this) << ").";
}

Flasher::~Flasher() {
    // Destructor must be defined due to unique pointer to incomplete type.
    qCDebug(logCategoryFlasher) << device_ << "Flasher deleted (unique ID: 0x" << reinterpret_cast<quintptr>(this) << ").";
}

void Flasher::flashFirmware(bool startApplication) {
    flash(true, startApplication);
}

void Flasher::backupFirmware(bool startApplication) {
    startApp_ = startApplication;
    if (fwFile_.open(QIODevice::WriteOnly)) {
        action_ = Action::BackupFirmware;
        chunkProgress_ = BACKUP_PROGRESS_STEP;
        qCInfo(logCategoryFlasher) << device_ << "Preparing for firmware backup.";
        emit switchToBootloader(false);
        operation_->switchToBootloader();
    } else {
        qCCritical(logCategoryFlasher) << device_ << "Cannot open file '" << fwFile_.fileName() << "'. " << fwFile_.errorString();
        emit error(fwFile_.errorString());
        finish(Result::Error);
    }
}

void Flasher::flashBootloader(bool startApplication) {
    flash(false, startApplication);
}

void Flasher::flash(bool flashFirmware, bool startApplication) {
    startApp_ = startApplication;
    if (fwFile_.open(QIODevice::ReadOnly)) {
        if (fwFile_.size() > 0) {
            action_ = (flashFirmware) ? Action::FlashFirmware : Action::FlashBootloader;
            chunkNumber_ = 0;
            chunkCount_ = static_cast<int>((fwFile_.size() - 1 + CHUNK_SIZE) / CHUNK_SIZE);
            chunkProgress_ = FLASH_PROGRESS_STEP;
            const char* binaryType = (flashFirmware) ? "firmware" : "bootloader";
            qCInfo(logCategoryFlasher) << device_ << "Preparing for flashing " << chunkCount_ << " chunks of " << binaryType << '.';
            emit switchToBootloader(false);
            operation_->switchToBootloader();
        } else {
            QString errStr = QStringLiteral("File '") + fwFile_.fileName() + QStringLiteral("' is empty.");
            qCCritical(logCategoryFlasher) << device_ << errStr;
            emit error(errStr);
            finish(Result::Error);
        }
    } else {
        qCCritical(logCategoryFlasher) << device_ << "Cannot open file '" << fwFile_.fileName() << "'. " << fwFile_.errorString();
        emit error(fwFile_.errorString());
        finish(Result::Error);
    }
}

void Flasher::cancel() {
    operation_->cancelOperation();
}

void Flasher::handleOperationFinished(DeviceOperation operation, int data) {
    switch (operation) {
    case DeviceOperation::SwitchToBootloader :
        emit switchToBootloader(true);
        qCInfo(logCategoryFlasher) << device_ << "Switched to bootloader (version '"
                                   << device_->property(DeviceProperties::bootloaderVer) << "').";
        if (data == device::OPERATION_DEFAULT_DATA) {
            // Operation SwitchToBootloader has data set to OPERATION_ALREADY_IN_BOOTLOADER (1) if board was
            // already in bootloader mode, otherwise data has default value OPERATION_DEFAULT_DATA (INT_MIN).
            emit devicePropertiesChanged();
        }
        switch (action_) {
        case Action::FlashFirmware :
        case Action::FlashBootloader :
            handleFlash(-1);  // negative value (-1) means that no chunk was flashed / backed up yet
            break;
        case Action::BackupFirmware :
            handleBackup(-1);  // negative value (-1) means that no chunk was flashed / backed up yet
            break;
        }
        break;
    case DeviceOperation::FlashFirmwareChunk :
    case DeviceOperation::FlashBootloaderChunk :
        handleFlash(data);
        break;
    case DeviceOperation::BackupFirmwareChunk :
        if (data == device::OPERATION_BACKUP_NO_FIRMWARE) {
            finish(Result::NoFirmware);
        } else {
            handleBackup(data);
        }
        break;
    case DeviceOperation::StartApplication :
        qCInfo(logCategoryFlasher) << device_ << "Launching firmware. Name: '"
                                   << device_->property(DeviceProperties::verboseName) << "', version: '"
                                   << device_->property(DeviceProperties::applicationVer) << "'.";
        emit devicePropertiesChanged();
        finish(Result::Ok);
        break;
    case DeviceOperation::Timeout :
        qCCritical(logCategoryFlasher) << device_ << "Timeout during firmware operation.";
        finish(Result::Timeout);
        break;
    case DeviceOperation::Cancel :
        qCWarning(logCategoryFlasher) << device_ << "Firmware operation was cancelled.";
        finish(Result::Cancelled);
        break;
    case DeviceOperation::Failure :
        {
            QString errStr(QStringLiteral("Firmware operation has failed (faulty response from device)."));
            qCCritical(logCategoryFlasher) << device_ << errStr;
            emit error(errStr);
            finish(Result::Error);
        }
        break;
    default :
        {
            QString errStr = QStringLiteral("Unsupported operation.");
            qCCritical(logCategoryFlasher) << device_ << errStr;
            emit error(errStr);
            finish(Result::Error);
        }
    }
}


void Flasher::handleFlash(int lastFlashedChunk) {
    bool flashFirmware = (action_ == Action::FlashFirmware);
    if (lastFlashedChunk == 0) {  // the last chunk
        fwFile_.close();
        const char* binaryType = (flashFirmware) ? "firmware" : "bootloader";
        qCInfo(logCategoryFlasher) << device_ << "Flashed chunk " << chunkCount_ << " of " << chunkCount_ << " - " << binaryType << " is flashed.";
        emit flashFirmwareProgress(chunkCount_, chunkCount_);
        if (startApp_) {
            operation_->startApplication();
        } else {
            finish(Result::Ok);
        }
        return;
    }
    if (lastFlashedChunk > 0) {  // if no chunk was flashed yet, 'lastFlashedChunk' is negative number (-1)
        if (lastFlashedChunk == chunkProgress_) { // this is faster than modulo
            chunkProgress_ += FLASH_PROGRESS_STEP;
            qCInfo(logCategoryFlasher) << device_ << "Flashed chunk " << lastFlashedChunk << " of " << chunkCount_;
            (flashFirmware) ?
                emit flashFirmwareProgress(lastFlashedChunk, chunkCount_) :
                emit flashBootloaderProgress(lastFlashedChunk, chunkCount_);
        } else {
            qCDebug(logCategoryFlasher) << device_ << "Flashed chunk " << lastFlashedChunk << " of " << chunkCount_;
        }
    }
    ++chunkNumber_;
    int chunkSize = CHUNK_SIZE;
    qint64 remainingFileSize = fwFile_.size() - fwFile_.pos();
    if (remainingFileSize <= CHUNK_SIZE) {
        chunkNumber_ = 0;  // the last chunk
        chunkSize = static_cast<int>(remainingFileSize);
    }
    QVector<quint8> chunk(chunkSize);

    qint64 bytesRead = fwFile_.read(reinterpret_cast<char*>(chunk.data()), chunkSize);
    if (bytesRead == chunkSize) {
        (flashFirmware) ?
            operation_->flashFirmwareChunk(chunk, chunkNumber_) :
            operation_->flashBootloaderChunk(chunk, chunkNumber_);
    } else {
        qCCritical(logCategoryFlasher) << device_ << "Cannot read from file '" << fwFile_.fileName() << "'. " << fwFile_.errorString();
        emit error(QStringLiteral("File read error. ") + fwFile_.errorString());
        finish(Result::Error);
    }
}

void Flasher::handleBackup(int chunkNumber) {
    if (chunkNumber >= 0) {  // if no chunk was backed up yet, 'chunkNumber' is negative number (-1)
        QVector<quint8> chunk = operation_->recentBackupChunk();
        int totalChunks = operation_->backupChunksCount();
        qint64 bytesWritten = fwFile_.write(reinterpret_cast<char*>(chunk.data()), chunk.size());
        if (bytesWritten != chunk.size()) {
            qCCritical(logCategoryFlasher) << device_ << "Cannot write to file '" << fwFile_.fileName() << "'. " << fwFile_.errorString();
            emit error(QStringLiteral("File write error. ") + fwFile_.errorString());
            finish(Result::Error);
            return;
        }
        if (chunkNumber != 0) {
            if (chunkNumber == chunkProgress_) { // this is faster than modulo
                chunkProgress_ += BACKUP_PROGRESS_STEP;
                qCInfo(logCategoryFlasher) << device_ << "Backed up chunk " << chunkNumber << " of " << totalChunks;
                emit backupFirmwareProgress(chunkNumber, totalChunks);
            } else {
                qCDebug(logCategoryFlasher) << device_ << "Backed up chunk " << chunkNumber << " of " << totalChunks;
            }
        } else {  // chunkNumber is 0 => the last chunk
            fwFile_.close();
            qCInfo(logCategoryFlasher) << device_ << "Backed up chunk " << totalChunks << " of " << totalChunks << " - firmware backup is done.";
            emit backupFirmwareProgress(totalChunks, totalChunks);
            if (startApp_) {
                operation_->startApplication();
            } else {
                finish(Result::Ok);
            }
            return;
        }
    }
    operation_->backupFirmwareChunk();
}

void Flasher::handleOperationError(QString errStr) {
    qCCritical(logCategoryFlasher) << device_ << "Error during flashing: " << errStr;
    emit error(errStr);
    finish(Result::Error);
}

void Flasher::finish(Result result) {
    if (fwFile_.isOpen()) {
        fwFile_.close();
    }
    emit finished(result);
}

}  // namespace
