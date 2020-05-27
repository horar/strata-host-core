#include "Flasher.h"
#include "FlasherConstants.h"

#include <SerialDevice.h>
#include <DeviceProperties.h>
#include <DeviceOperations.h>
#include <DeviceOperationsFinished.h>

#include "logging/LoggingQtCategories.h"

namespace strata {

QDebug operator<<(QDebug dbg, const Flasher* f) {
    return dbg.nospace() << "Device 0x" << hex << f->deviceId_ << ": ";
}

Flasher::Flasher(const SerialDevicePtr& device, const QString& firmwareFilename) :
    device_(device), fwFile_(firmwareFilename)
{
    deviceId_ = static_cast<uint>(device_->deviceId());
    operation_ = std::make_unique<DeviceOperations>(device_);

    connect(operation_.get(), &DeviceOperations::finished, this, &Flasher::handleOperationFinished);
    connect(operation_.get(), &DeviceOperations::error, this, &Flasher::handleOperationError);

    qCDebug(logCategoryFlasher) << this << "Flasher created (unique ID: 0x" << reinterpret_cast<quintptr>(this) << ").";
}

Flasher::~Flasher() {
    // Destructor must be defined due to unique pointer to incomplete type.
    qCDebug(logCategoryFlasher) << this << "Flasher deleted (unique ID: 0x" << reinterpret_cast<quintptr>(this) << ").";
}

void Flasher::flash(bool startApplication) {
    startApp_ = startApplication;
    if (fwFile_.open(QIODevice::ReadOnly)) {
        if (fwFile_.size() > 0) {
            action_ = Action::Flash;
            chunkNumber_ = 0;
            chunkCount_ = static_cast<int>((fwFile_.size() - 1 + CHUNK_SIZE) / CHUNK_SIZE);
            chunkProgress_ = FLASH_PROGRESS_STEP;
            qCInfo(logCategoryFlasher) << this << "Preparing for flashing " << dec << chunkCount_ << " chunks of firmware.";
            emit switchToBootloader(false);
            operation_->switchToBootloader();
        } else {
            QString errStr = QStringLiteral("File '") + fwFile_.fileName() + QStringLiteral("' is empty.");
            qCCritical(logCategoryFlasher).noquote() << this << errStr;
            emit error(errStr);
            finish(Result::Error);
        }
    } else {
        qCCritical(logCategoryFlasher).noquote().nospace() << this << "Cannot open file '" << fwFile_.fileName() << "'. " << fwFile_.errorString();
        emit error(fwFile_.errorString());
        finish(Result::Error);
    }
}

void Flasher::backup(bool startApplication) {
    startApp_ = startApplication;
    if (fwFile_.open(QIODevice::WriteOnly)) {
        action_ = Action::Backup;
        chunkCount_ = 0;
        chunkProgress_ = BACKUP_PROGRESS_STEP;
        qCInfo(logCategoryFlasher) << this << "Preparing for firmware backup.";
        emit switchToBootloader(false);
        operation_->switchToBootloader();
    } else {
        qCCritical(logCategoryFlasher).noquote().nospace() << this << "Cannot open file '" << fwFile_.fileName() << "'. " << fwFile_.errorString();
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
        if (data != 1) {
            // Operation SwitchToBootloader has data set to 1 if board was already in
            // bootloader mode, otherwise data has default value INT_MIN.
            emit devicePropertiesChanged();
        }
        // negative value (-1) means that no chunk was flashed / backed up yet
        (action_ == Action::Flash) ? handleFlashFirmware(-1) : handleBackupFirmware(-1);
        break;
    case DeviceOperation::FlashFirmwareChunk :
        handleFlashFirmware(data);
        break;
    case DeviceOperation::BackupFirmwareChunk :
        if (data == OPERATION_BACKUP_NO_FIRMWARE) {
            finish(Result::NoFirmware);
        } else {
            handleBackupFirmware(data);
        }
        break;
    case DeviceOperation::StartApplication :
        operation_->refreshPlatformId();
        break;
    case DeviceOperation::RefreshPlatformId :
        qCInfo(logCategoryFlasher) << this << "Firmware is ready for use.";
        emit devicePropertiesChanged();
        finish(Result::Ok);
        break;
    case DeviceOperation::Timeout :
        qCCritical(logCategoryFlasher) << this << "Timeout during firmware operation.";
        finish(Result::Timeout);
        break;
    case DeviceOperation::Cancel :
        qCWarning(logCategoryFlasher) << this << "Firmware operation was cancelled.";
        finish(Result::Cancelled);
        break;
    case DeviceOperation::Failure :
        {
            QString errStr(QStringLiteral("Firmware operation has failed (faulty response from device)."));
            qCCritical(logCategoryFlasher).noquote() << this << errStr;
            emit error(errStr);
            finish(Result::Error);
        }
        break;
    default :
        {
            QString errStr = QStringLiteral("Unsupported operation.");
            qCCritical(logCategoryFlasher) << this << errStr;
            emit error(errStr);
            finish(Result::Error);
        }
    }
}


void Flasher::handleFlashFirmware(int lastFlashedChunk) {
    if (lastFlashedChunk == 0) {  // the last chunk
        fwFile_.close();
        qCInfo(logCategoryFlasher) << this << "Flashed chunk " << dec << chunkCount_ << " of " << chunkCount_ << " - firmware is flashed.";
        emit flashProgress(chunkCount_, chunkCount_);
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
            qCInfo(logCategoryFlasher) << this << "Flashed chunk " << dec << lastFlashedChunk << " of " << chunkCount_;
            emit flashProgress(lastFlashedChunk, chunkCount_);
        } else {
            qCDebug(logCategoryFlasher) << this << "Flashed chunk " << dec << lastFlashedChunk << " of " << chunkCount_;
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
        operation_->flashFirmwareChunk(chunk, chunkNumber_);
    } else {
        qCCritical(logCategoryFlasher).noquote().nospace() << this << "Cannot read from file '" << fwFile_.fileName() << "'. " << fwFile_.errorString();
        emit error(QStringLiteral("File read error. ") + fwFile_.errorString());
        finish(Result::Error);
    }
}

void Flasher::handleBackupFirmware(int chunkNumber) {
    if (chunkNumber >= 0) {  // if no chunk was backed up yet, 'chunkNumber' is negative number (-1)
        QVector<quint8> chunk = operation_->recentBackupChunk();
        qint64 bytesWritten = fwFile_.write(reinterpret_cast<char*>(chunk.data()), chunk.size());
        if (bytesWritten != chunk.size()) {
            qCCritical(logCategoryFlasher).noquote().nospace() << this << "Cannot write to file '" << fwFile_.fileName() << "'. " << fwFile_.errorString();
            emit error(QStringLiteral("File write error. ") + fwFile_.errorString());
            finish(Result::Error);
            return;
        }
        if (chunkNumber != 0) {
            chunkCount_ = chunkNumber;
            if (chunkNumber == chunkProgress_) { // this is faster than modulo
                chunkProgress_ += BACKUP_PROGRESS_STEP;
                qCInfo(logCategoryFlasher) << this << "Backed up chunk " << dec << chunkNumber;
                emit backupProgress(chunkNumber, false);
            } else {
                qCDebug(logCategoryFlasher) << this << "Backed up chunk " << dec << chunkNumber;
            }
        } else {  // chunkNumber is 0 => the last chunk
            ++chunkCount_;
            fwFile_.close();
            qCInfo(logCategoryFlasher) << this << "Backed up chunk " << dec << chunkCount_ << " - firmware backup is done.";
            emit backupProgress(chunkCount_, true);
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
    qCCritical(logCategoryFlasher).noquote() << this << "Error during flashing: " << errStr;
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
