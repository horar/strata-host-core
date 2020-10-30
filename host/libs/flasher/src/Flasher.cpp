#include "Flasher.h"
#include "FlasherConstants.h"

#include <QCryptographicHash>

#include <Device/Operations/StartBootloader.h>
#include <Device/Operations/Flash.h>
#include <Device/Operations/Backup.h>
#include <Device/Operations/StartApplication.h>
#include <Device/Operations/Identify.h>

#include "logging/LoggingQtCategories.h"

namespace strata {

using device::DevicePtr;
using device::DeviceProperties;

namespace operation = device::operation;

Flasher::Flasher(const DevicePtr& device, const QString& fileName) :
    Flasher(device, fileName, QString()) { }

Flasher::Flasher(const DevicePtr& device, const QString& fileName, const QString& fileMD5) :
    device_(device), binaryFile_(fileName), fileMD5_(fileMD5)
{
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
        chunkCount_ = 0;
        qCInfo(logCategoryFlasher) << device_ << "Preparing for firmware backup.";
        emit switchToBootloader(false);
        operation_ = std::make_unique<operation::StartBootloader>(device_);
        connectHandlers(operation_.get());
        operation_->run();
    } else {
        qCCritical(logCategoryFlasher) << device_ << "Cannot open file '" << binaryFile_.fileName() << "'. " << binaryFile_.errorString();
        emit error(binaryFile_.errorString());
        finish(Result::Error);
    }
}

void Flasher::flashBootloader() {
    flash(false, false);
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

            operation_ = std::make_unique<operation::StartBootloader>(device_);
            connectHandlers(operation_.get());
            operation_->run();
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
    if (operation_) {
        operation_->cancelOperation();
    }
}

void Flasher::handleOperationFinished(operation::Type opType, int data) {
    switch (opType) {
    case operation::Type::StartBootloader :
        emit switchToBootloader(true);
        qCInfo(logCategoryFlasher) << device_ << "Switched to bootloader (version '"
                                   << device_->property(DeviceProperties::bootloaderVer) << "').";
        if (data == operation::DEFAULT_DATA) {
            // Operation SwitchToBootloader has data set to OPERATION_ALREADY_IN_BOOTLOADER (1) if board was
            // already in bootloader mode, otherwise data has default value OPERATION_DEFAULT_DATA (INT_MIN).
            emit devicePropertiesChanged();
        }
        switch (action_) {
        case Action::FlashFirmware :
            operation_ = std::make_unique<operation::Flash>(device_, binaryFile_.size(), chunkCount_, fileMD5_, true);
            break;
        case Action::FlashBootloader :
            operation_ = std::make_unique<operation::Flash>(device_, binaryFile_.size(), chunkCount_, fileMD5_, false);
            break;
        case Action::BackupFirmware :
            operation_ = std::make_unique<operation::Backup>(device_);
            break;
        }
        connectHandlers(operation_.get());
        operation_->run();
        break;
    case operation::Type::FlashFirmware :
    case operation::Type::FlashBootloader :
        if (data == operation::FLASH_STARTED) {
            manageFlash(-1);  // negative value (-1) means that no chunk was flashed yet
        } else {
            manageFlash(data);
        }
        break;
    case operation::Type::BackupFirmware :
        switch (data) {
        case operation::BACKUP_NO_FIRMWARE :
            finish(Result::NoFirmware);
            break;
        case operation::BACKUP_STARTED :
            manageBackup(-1);  // negative value (-1) means that no chunk was backed up yet
            break;
        default :
            manageBackup(data);
            break;
        }
        break;
    case operation::Type::Identify :
    case operation::Type::StartApplication :
        qCInfo(logCategoryFlasher) << device_ << "Launching device software. Name: '"
                                   << device_->property(DeviceProperties::verboseName) << "', version: '"
                                   << device_->property(DeviceProperties::applicationVer) << "'.";
        emit devicePropertiesChanged();
        finish(Result::Ok);
        break;
    case operation::Type::Timeout :
        qCCritical(logCategoryFlasher) << device_ << "Timeout during firmware operation.";
        finish(Result::Timeout);
        break;
    case operation::Type::Cancel :
        qCWarning(logCategoryFlasher) << device_ << "Firmware operation was cancelled.";
        finish(Result::Cancelled);
        break;
    case operation::Type::Failure :
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

void Flasher::manageFlash(int lastFlashedChunk) {
    bool flashFw = (action_ == Action::FlashFirmware);

    // Bootloader uses range 0 to N-1 for chunk numbers, our signals use range 1 to N.
    int flashedChunk = lastFlashedChunk + 1;

    if (flashedChunk == chunkCount_) {  // the last chunk
        binaryFile_.close();
        const char* binaryType = (flashFw) ? "firmware" : "bootloader";
        qCInfo(logCategoryFlasher) << device_ << "Flashed chunk " << flashedChunk << " of " << chunkCount_ << " - " << binaryType << " is flashed.";
        (flashFw)
            ? emit flashFirmwareProgress(flashedChunk, chunkCount_)
            : emit flashBootloaderProgress(flashedChunk, chunkCount_);
        if (flashFw) {
            if (startApp_) {
                operation_ = std::make_unique<operation::StartApplication>(device_);
                connectHandlers(operation_.get());
                operation_->run();
            } else {
                finish(Result::Ok);
            }
        } else {  // flash bootloader
            operation_ = std::make_unique<operation::Identify>(device_, true, MAX_GET_FW_INFO_RETRIES);
            connectHandlers(operation_.get());
            device::operation::Identify *identify = dynamic_cast<device::operation::Identify*>(operation_.get());
            identify->runWithDelay(IDENTIFY_OPERATION_DELAY);  // starting new bootloader takes some time
        }
        return;
    }

    if (lastFlashedChunk >= 0) {  // if no chunk was flashed yet, 'lastFlashedChunk' is negative number (-1)
        if (flashedChunk == chunkProgress_) { // this is faster than modulo
            chunkProgress_ += FLASH_PROGRESS_STEP;
            qCInfo(logCategoryFlasher) << device_ << "Flashed chunk " << flashedChunk << " of " << chunkCount_;
            (flashFw)
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
        operation::Flash *flashOp = dynamic_cast<operation::Flash*>(operation_.get());
        if (flashOp != nullptr) {
            flashOp->flashChunk(chunk, chunkNumber_);
            ++chunkNumber_;
        } else {
            QString errStr(QStringLiteral("Unexpected flash error."));
            qCCritical(logCategoryFlasher) << device_ << errStr;
            emit error(errStr);
            finish(Result::Error);
        }
    } else {
        qCCritical(logCategoryFlasher) << device_ << "Cannot read from file '" << binaryFile_.fileName() << "'. " << binaryFile_.errorString();
        emit error(QStringLiteral("File read error. ") + binaryFile_.errorString());
        finish(Result::Error);
    }
}

void Flasher::manageBackup(int chunkNumber) {
    operation::Backup *backupOp = dynamic_cast<operation::Backup*>(operation_.get());
    if (backupOp == nullptr) {
        QString errStr(QStringLiteral("Unexpected backup error."));
        qCCritical(logCategoryFlasher) << device_ << errStr;
        emit error(errStr);
        finish(Result::Error);
        return;
    }

    if (chunkNumber < 0) {  // if no chunk was backed up yet, 'chunkNumber' is negative number (-1)
        chunkCount_ = backupOp->totalChunks();
    } else {
        QVector<quint8> chunk = backupOp->recentBackupChunk();
        qint64 bytesWritten = binaryFile_.write(reinterpret_cast<char*>(chunk.data()), chunk.size());
        if (bytesWritten != chunk.size()) {
            qCCritical(logCategoryFlasher) << device_ << "Cannot write to file '" << binaryFile_.fileName() << "'. " << binaryFile_.errorString();
            emit error(QStringLiteral("File write error. ") + binaryFile_.errorString());
            finish(Result::Error);
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
            qCInfo(logCategoryFlasher) << device_ << "Backed up chunk " << chunkNumber << " of " << chunkCount_ << " - firmware backup is done.";
            emit backupFirmwareProgress(chunkNumber, chunkCount_);
            if (startApp_) {
                operation_ = std::make_unique<operation::StartApplication>(device_);
                connectHandlers(operation_.get());
                operation_->run();
            } else {
                finish(Result::Ok);
            }
            return;
        }
    }

    backupOp->backupNextChunk();
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

void Flasher::connectHandlers(operation::BaseDeviceOperation *operation) {
    connect(operation, &operation::BaseDeviceOperation::finished, this, &Flasher::handleOperationFinished);
    connect(operation, &operation::BaseDeviceOperation::error, this, &Flasher::handleOperationError);
}

}  // namespace
