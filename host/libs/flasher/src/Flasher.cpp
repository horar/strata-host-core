#include "Flasher.h"
#include "FlasherConstants.h"

#include <SerialDevice.h>
#include <DeviceProperties.h>
#include <DeviceOperations.h>

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

    qCDebug(logCategoryFlasher) << this << "Flasher created.";
}

Flasher::~Flasher() {
    // Destructor must be defined due to unique pointer to incomplete type.
    qCDebug(logCategoryFlasher) << this << "Flasher deleted.";
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
            operation_->switchToBootloader();
        } else {
            QString errStr = QStringLiteral("File '") + fwFile_.fileName() + QStringLiteral("' is empty.");
            qCCritical(logCategoryFlasher).noquote() << this << errStr;
            finish(Result::Error, errStr);
        }
    } else {
        QString errStr = QStringLiteral("Cannot open file '") + fwFile_.fileName() + QStringLiteral("'.");
        qCCritical(logCategoryFlasher).noquote() << this << errStr;
        finish(Result::Error, errStr);
    }
}

void Flasher::backup(bool startApplication) {
    startApp_ = startApplication;
    if (fwFile_.open(QIODevice::WriteOnly)) {
        action_ = Action::Backup;
        chunkCount_ = 0;
        chunkProgress_ = BACKUP_PROGRESS_STEP;
        qCInfo(logCategoryFlasher) << this << "Preparing for firmware backup.";
        operation_->switchToBootloader();
    } else {
        QString errStr = QStringLiteral("Cannot open file '") + fwFile_.fileName() + QStringLiteral("'.");
        qCCritical(logCategoryFlasher).noquote() << this << errStr;
        finish(Result::Error, errStr);
    }
}

void Flasher::cancel() {
    operation_->cancelOperation();
}

void Flasher::handleOperationFinished(int operation, int data) {
    DeviceOperations::Operation op = static_cast<DeviceOperations::Operation>(operation);
    switch (op) {
    case DeviceOperations::Operation::SwitchToBootloader :
        (action_ == Action::Flash) ? handleFlashFirmware(data) : handleBackupFirmware(data);
        break;
    case DeviceOperations::Operation::FlashFirmwareChunk :
        handleFlashFirmware(data);
        break;
    case DeviceOperations::Operation::BackupFirmwareChunk :
        handleBackupFirmware(data);
        break;
    case DeviceOperations::Operation::StartApplication :
        qCInfo(logCategoryFlasher) << this << "Firmware is ready for use.";
        finish(Result::Ok);
        break;
    case DeviceOperations::Operation::Timeout :
        if (action_ == Action::Flash) {
            qCCritical(logCategoryFlasher) << this << "Timeout during flashing.";
        } else {
            qCCritical(logCategoryFlasher) << this << "Timeout during firmware backup.";
        }
        finish(Result::Timeout);
        break;
    case DeviceOperations::Operation::Cancel :
        if (action_ == Action::Flash) {
            qCWarning(logCategoryFlasher) << this << "Flashing was cancelled.";
        } else {
            qCWarning(logCategoryFlasher) << this << "Firmware backup was cancelled.";
        }
        finish(Result::Cancelled);
        break;
    default :
        {
            QString errStr = QStringLiteral("Unsupported operation.");
            qCCritical(logCategoryFlasher) << this << errStr;
            finish(Result::Error, errStr);
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
    if (lastFlashedChunk > 0) {  // operation SwitchToBootloader has this value set to -1
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
        QString errStr = QStringLiteral("Cannot read from file ") + fwFile_.fileName();
        qCCritical(logCategoryFlasher).noquote() << this << errStr;
        finish(Result::Error, errStr);
    }
}

void Flasher::handleBackupFirmware(int chunkNumber) {
    bool firstChunk = false;
    if (chunkNumber < 0) {  // operation SwitchToBootloader has this value set to -1
        firstChunk = true;
    } else {
        QVector<quint8> chunk = operation_->recentFirmwareChunk();
        qint64 bytesWritten = fwFile_.write(reinterpret_cast<char*>(chunk.data()), chunk.size());
        if (bytesWritten != chunk.size()) {
            QString errStr = QStringLiteral("Cannot write to file ") + fwFile_.fileName();
            qCCritical(logCategoryFlasher).noquote() << this << errStr;
            finish(Result::Error, errStr);
            return;
        }
        if (chunkNumber) {
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
    operation_->backupFirmwareChunk(firstChunk);
}

void Flasher::handleOperationError(QString errStr) {
    qCCritical(logCategoryFlasher).noquote() << this << "Error during flashing: " << errStr;
    finish(Result::Error, errStr);
}

void Flasher::finish(Result result, QString errStr) {
    if (fwFile_.isOpen()) {
        fwFile_.close();
    }
    emit finished(result, errStr);
}

}  // namespace
