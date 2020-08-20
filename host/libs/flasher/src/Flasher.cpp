#include "Flasher.h"
#include "FlasherConstants.h"

#include <QCryptographicHash>

#include <Device/DeviceOperations.h>

#include "logging/LoggingQtCategories.h"

namespace strata {

using device::DevicePtr;
using device::DeviceOperations;
using device::DeviceOperation;
using device::DeviceProperties;

Flasher::Flasher(const DevicePtr& device, const QString& fileName) :
    Flasher(device, fileName, QString()) { }

Flasher::Flasher(const DevicePtr& device, const QString& fileName, const QString& fileMD5) :
    device_(device), binaryFile_(fileName), fileMD5_(fileMD5)
{
    operation_ = std::make_unique<DeviceOperations>(device_);

    connect(operation_.get(), &DeviceOperations::finished, this, &Flasher::handleOperationFinished);
    connect(operation_.get(), &DeviceOperations::error, this, &Flasher::handleOperationError);

    qCDebug(logCategoryFlasher) << device_ << "Flasher created (unique ID: 0x" << hex << reinterpret_cast<quintptr>(this) << ").";
}

Flasher::~Flasher() {
    // Destructor must be defined due to unique pointer to incomplete type.
    qCDebug(logCategoryFlasher) << device_ << "Flasher deleted (unique ID: 0x" << hex << reinterpret_cast<quintptr>(this) << ").";
}

void Flasher::flashFirmware(bool startApplication) {
    flash(true, startApplication);
}

void Flasher::backupFirmware(bool startApplication) {
    startApp_ = startApplication;
    if (binaryFile_.open(QIODevice::WriteOnly)) {
        action_ = Action::BackupFirmware;
        chunkProgress_ = BACKUP_PROGRESS_STEP;
        qCInfo(logCategoryFlasher) << device_ << "Preparing for firmware backup.";
        emit switchToBootloader(false);
        operation_->switchToBootloader();
    } else {
        qCCritical(logCategoryFlasher) << device_ << "Cannot open file '" << binaryFile_.fileName() << "'. " << binaryFile_.errorString();
        emit error(binaryFile_.errorString());
        finish(Result::Error);
    }
}

void Flasher::flashBootloader(bool startApplication) {
    flash(false, startApplication);
}

void Flasher::flash(bool flashFirmware, bool startApplication) {
    startApp_ = startApplication;
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
                        emit error(errStr);
                        finish(Result::Error);
                        return;
                    }
                }
            }
            action_ = (flashFirmware) ? Action::FlashFirmware : Action::FlashBootloader;
            chunkNumber_ = 0;
            chunkCount_ = static_cast<int>((binaryFile_.size() - 1 + CHUNK_SIZE) / CHUNK_SIZE);
            chunkProgress_ = FLASH_PROGRESS_STEP;
            const char* binaryType = (flashFirmware) ? "firmware" : "bootloader";
            qCInfo(logCategoryFlasher) << device_ << "Preparing for flashing " << chunkCount_ << " chunks of " << binaryType << '.';

            emit switchToBootloader(false);

            operation_->switchToBootloader();
        } else {
            QString errStr = QStringLiteral("File '") + binaryFile_.fileName() + QStringLiteral("' is empty.");
            qCCritical(logCategoryFlasher) << device_ << errStr;
            emit error(errStr);
            finish(Result::Error);
        }
    } else {
        qCCritical(logCategoryFlasher) << device_ << "Cannot open file '" << binaryFile_.fileName() << "'. " << binaryFile_.errorString();
        emit error(binaryFile_.errorString());
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
            QString errStr(QStringLiteral("Unsupported operation."));
            qCCritical(logCategoryFlasher) << device_ << errStr;
            emit error(errStr);
            finish(Result::Error);
        }
    }
}


void Flasher::handleFlash(int lastFlashedChunk) {
    bool flashFirmware = (action_ == Action::FlashFirmware);

    // Bootloader uses range 0 to N-1 for chunk numbers, our signals use range 1 to N.
    int flashedChunk = lastFlashedChunk + 1;

    if (flashedChunk == chunkCount_) {  // the last chunk
        binaryFile_.close();
        const char* binaryType = (flashFirmware) ? "firmware" : "bootloader";
        qCInfo(logCategoryFlasher) << device_ << "Flashed chunk " << flashedChunk << " of " << chunkCount_ << " - " << binaryType << " is flashed.";
        (flashFirmware)
            ? emit flashFirmwareProgress(flashedChunk, chunkCount_)
            : emit flashBootloaderProgress(flashedChunk, chunkCount_);
        if (startApp_) {
            operation_->startApplication();
        } else {
            finish(Result::Ok);
        }
        return;
    }

    if (lastFlashedChunk < 0) {  // if no chunk was flashed yet, 'lastFlashedChunk' is negative number (-1)
        operation_->setFlashInfo(binaryFile_.size(), fileMD5_);
    } else {
        if (flashedChunk == chunkProgress_) { // this is faster than modulo
            chunkProgress_ += FLASH_PROGRESS_STEP;
            qCInfo(logCategoryFlasher) << device_ << "Flashed chunk " << flashedChunk << " of " << chunkCount_;
            (flashFirmware)
                ? emit flashFirmwareProgress(flashedChunk, chunkCount_)
                : emit flashBootloaderProgress(flashedChunk, chunkCount_);
        } else {
            qCDebug(logCategoryFlasher) << device_ << "Flashed chunk " << flashedChunk << " of " << chunkCount_;
        }
    }

    if (binaryFile_.atEnd()) {
        QString errStr(QStringLiteral("Unexpected end of file."));
        qCCritical(logCategoryFlasher) << device_ << errStr << ' ' <<  binaryFile_.fileName();
        emit error(errStr);
        finish(Result::Error);
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
        (flashFirmware)
            ? operation_->flashFirmwareChunk(chunk, chunkNumber_, chunkCount_)
            : operation_->flashBootloaderChunk(chunk, chunkNumber_, chunkCount_);
        ++chunkNumber_;
    } else {
        qCCritical(logCategoryFlasher) << device_ << "Cannot read from file '" << binaryFile_.fileName() << "'. " << binaryFile_.errorString();
        emit error(QStringLiteral("File read error. ") + binaryFile_.errorString());
        finish(Result::Error);
    }
}

void Flasher::handleBackup(int chunkNumber) {
    if (chunkNumber >= 0) {  // if no chunk was backed up yet, 'chunkNumber' is negative number (-1)
        QVector<quint8> chunk = operation_->recentBackupChunk();
        int totalChunks = operation_->backupChunksCount();
        qint64 bytesWritten = binaryFile_.write(reinterpret_cast<char*>(chunk.data()), chunk.size());
        if (bytesWritten != chunk.size()) {
            qCCritical(logCategoryFlasher) << device_ << "Cannot write to file '" << binaryFile_.fileName() << "'. " << binaryFile_.errorString();
            emit error(QStringLiteral("File write error. ") + binaryFile_.errorString());
            finish(Result::Error);
            return;
        }

        // Bootloader uses range 0 to N-1 for chunk numbers, our signals use range 1 to N.
        ++chunkNumber;  // move chunk number to range from 1 to N

        if (chunkNumber < totalChunks) {
            if (chunkNumber == chunkProgress_) { // this is faster than modulo
                chunkProgress_ += BACKUP_PROGRESS_STEP;
                qCInfo(logCategoryFlasher) << device_ << "Backed up chunk " << chunkNumber << " of " << totalChunks;
                emit backupFirmwareProgress(chunkNumber, totalChunks);
            } else {
                qCDebug(logCategoryFlasher) << device_ << "Backed up chunk " << chunkNumber << " of " << totalChunks;
            }
        } else {  // the last chunk
            binaryFile_.close();
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
    if (binaryFile_.isOpen()) {
        binaryFile_.close();
    }
    emit finished(result);
}

}  // namespace
