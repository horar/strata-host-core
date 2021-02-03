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
    device_(device), binaryFile_(fileName), fileMD5_(fileMD5), fwClassId_(fwClassId), operation_(nullptr, nullptr)
{
    qCDebug(logCategoryFlasher) << device_ << "Flasher created (unique ID: 0x" << hex << reinterpret_cast<quintptr>(this) << ").";
}

Flasher::~Flasher() {
    // Destructor must be defined due to unique pointer to incomplete type.
    qCDebug(logCategoryFlasher) << device_ << "Flasher deleted (unique ID: 0x" << hex << reinterpret_cast<quintptr>(this) << ").";
}

void Flasher::flashFirmware(bool startApplication) {
    startApp_ = startApplication;
    flash(true);
}

void Flasher::flashBootloader() {
    startApp_ = false;
    flash(false);
}

void Flasher::backupFirmware(bool startApplication) {
    startApp_ = startApplication;
    if (binaryFile_.open(QIODevice::WriteOnly)) {
        action_ = Action::BackupFirmware;
        chunkProgress_ = BACKUP_PROGRESS_STEP;
        chunkCount_ = 0;

        qCInfo(logCategoryFlasher) << device_ << "Preparing for firmware backup.";
        state_ = State::SwitchToBootloader;
        emit flasherState(state_, false);

        operation_ = std::unique_ptr<operation::StartBootloader, void(*)(operation::BaseDeviceOperation*)>
                     (new operation::StartBootloader(device_), operationDeleter);
        connectHandlers(operation_.get());
        operation_->run();
    } else {
        qCCritical(logCategoryFlasher) << device_ << "Cannot open file '" << binaryFile_.fileName() << "'. " << binaryFile_.errorString();
        finish(Result::Error, binaryFile_.errorString());
    }
}

void Flasher::flash(bool flashFirmware) {
    fileFlashed_ = false;
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

            state_ = State::SwitchToBootloader;
            emit flasherState(state_, false);

            operation_ = std::unique_ptr<operation::StartBootloader, void(*)(operation::BaseDeviceOperation*)>
                         (new operation::StartBootloader(device_), operationDeleter);
            connectHandlers(operation_.get());
            operation_->run();
        } else {
            QString errStr = QStringLiteral("File '") + binaryFile_.fileName() + QStringLiteral("' is empty.");
            qCCritical(logCategoryFlasher) << device_ << errStr;
            finish(Result::Error, errStr);
        }
    } else {
        qCCritical(logCategoryFlasher) << device_ << "Cannot open file '" << binaryFile_.fileName() << "'. " << binaryFile_.errorString();
        finish(Result::Error, binaryFile_.errorString());
    }
}

void Flasher::cancel() {
    if (operation_) {
        operation_->cancelOperation();
        qCWarning(logCategoryFlasher) << device_ << "Firmware operation was cancelled.";
        finish(Result::Cancelled);
    }
}

void Flasher::handleOperationFinished(operation::Result result, int status, QString errStr) {
    switch (result) {
    case operation::Result::Success :
        doNextOperation(qobject_cast<operation::BaseDeviceOperation*>(QObject::sender()), status);
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

void Flasher::doNextOperation(device::operation::BaseDeviceOperation* baseOp, int status) {
    if (baseOp == nullptr) {
        return;
    }

    switch (baseOp->type()) {
    case operation::Type::StartBootloader :
        qCInfo(logCategoryFlasher) << device_ << "Switched to bootloader (version '"
                                   << device_->bootloaderVer() << "').";
        emit flasherState(state_, true);

        if (status == operation::DEFAULT_STATUS) {
            // Operation SwitchToBootloader has status set to OPERATION_ALREADY_IN_BOOTLOADER (1) if board was
            // already in bootloader mode, otherwise status has default value DEFAULT_STATUS (INT_MIN).
            emit devicePropertiesChanged();
        }

        if (fwClassId_.isNull()) {
            createFlasherOperation(operation_, state_);
        } else {
            operation_ = std::unique_ptr<operation::SetAssistedPlatformId, void(*)(operation::BaseDeviceOperation*)>
                          (new operation::SetAssistedPlatformId(device_), operationDeleter);
            operation::SetAssistedPlatformId *setAssisted = dynamic_cast<device::operation::SetAssistedPlatformId*>(operation_.get());
            setAssisted->setFwClassId(QStringLiteral("00000000-0000-4000-0000-000000000000"));

            state_ = State::ClearFwClassId;
        }
        emit flasherState(state_, false);

        connectHandlers(operation_.get());
        operation_->run();
        break;
    case operation::Type::SetAssistedPlatformId :
        emit flasherState(state_, true);
        emit devicePropertiesChanged();
        if (fileFlashed_) {
            if (startApp_) {
                operation_ = std::unique_ptr<operation::StartApplication, void(*)(operation::BaseDeviceOperation*)>
                              (new operation::StartApplication(device_), operationDeleter);
                state_ = State::StartApplication;
            } else {
                finish(Result::Ok);
                break;
            }
        } else {
           createFlasherOperation(operation_, state_);
        }
        emit flasherState(state_, false);
        connectHandlers(operation_.get());
        operation_->run();
        break;
    case operation::Type::FlashFirmware :
    case operation::Type::FlashBootloader :
        if (status == operation::FLASH_STARTED) {
            manageFlash(-1);  // negative value (-1) means that no chunk was flashed yet
        } else {
            manageFlash(status);  // status contains chunk number
        }
        break;
    case operation::Type::BackupFirmware :
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
        break;
    case operation::Type::StartApplication :
        if (status == operation::NO_FIRMWARE) {
            finish(Result::NoFirmware);
            break;
        }
        // if status is not 'NO_FIRMWARE' continue with code for 'Identify' operation
        [[fallthrough]];
    case operation::Type::Identify :
        emit flasherState(state_, true);
        {
            QString version = (action_ == Action::FlashBootloader)
                              ? device_->bootloaderVer()
                              : device_->applicationVer();
            qCInfo(logCategoryFlasher) << device_ << "Launching device software. Name: '"
                                       << device_->name()
                                       << "', version: '" << version << "'.";
        }
        emit devicePropertiesChanged();
        finish(Result::Ok);
        break;
    default :
        {
            QString errStr(QStringLiteral("Unsupported operation."));
            qCCritical(logCategoryFlasher) << device_ << errStr;
            finish(Result::Error, errStr);
        }
    }
}

void Flasher::createFlasherOperation(FlasherOperation& operation, State& state) {
    switch (action_) {
    case Action::FlashFirmware :
        operation = std::unique_ptr<operation::Flash, void(*)(operation::BaseDeviceOperation*)>
                     (new operation::Flash(device_, binaryFile_.size(), chunkCount_, fileMD5_, true), operationDeleter);
        state = State::FlashFirmware;
        break;
    case Action::FlashBootloader :
        operation = std::unique_ptr<operation::Flash, void(*)(operation::BaseDeviceOperation*)>
                     (new operation::Flash(device_, binaryFile_.size(), chunkCount_, fileMD5_, false), operationDeleter);
        state = State::FlashBootloader;
        break;
    case Action::BackupFirmware :
        operation = std::unique_ptr<operation::Backup, void(*)(operation::BaseDeviceOperation*)>
                     (new operation::Backup(device_), operationDeleter);
        state = State::BackupFirmware;
        break;
    }
}

void Flasher::manageFlash(int lastFlashedChunk) {
    bool flashFw = (action_ == Action::FlashFirmware);

    // Bootloader uses range 0 to N-1 for chunk numbers, our signals use range 1 to N.
    int flashedChunk = lastFlashedChunk + 1;

    if (flashedChunk == chunkCount_) {  // the last chunk
        binaryFile_.close();
        fileFlashed_ = true;

        const char* binaryType = (flashFw) ? "firmware" : "bootloader";
        qCInfo(logCategoryFlasher) << device_ << "Flashed chunk " << flashedChunk << " of " << chunkCount_ << " - " << binaryType << " is flashed.";
        (flashFw)
            ? emit flashFirmwareProgress(flashedChunk, chunkCount_)
            : emit flashBootloaderProgress(flashedChunk, chunkCount_);
        emit flasherState(state_, true);
        if (flashFw) {
            if (fwClassId_.isNull()) {
                if (startApp_) {
                    state_ = State::StartApplication;
                    emit flasherState(state_, false);

                    operation_ = std::unique_ptr<operation::StartApplication, void(*)(operation::BaseDeviceOperation*)>
                                  (new operation::StartApplication(device_), operationDeleter);
                    connectHandlers(operation_.get());
                    operation_->run();
                } else {
                    finish(Result::Ok);
                }
            } else {
                state_ = State::SetFwClassId;
                emit flasherState(state_, false);

                operation_ = std::unique_ptr<operation::SetAssistedPlatformId, void(*)(operation::BaseDeviceOperation*)>
                              (new operation::SetAssistedPlatformId(device_), operationDeleter);
                operation::SetAssistedPlatformId *setAssisted = dynamic_cast<device::operation::SetAssistedPlatformId*>(operation_.get());
                setAssisted->setFwClassId(fwClassId_);
                connectHandlers(operation_.get());
                operation_->run();
            }
        } else {  // flash bootloader
            state_ = State::IdentifyBoard;
            emit flasherState(state_, false);

            operation_ = std::unique_ptr<operation::Identify, void(*)(operation::BaseDeviceOperation*)>
                         (new operation::Identify(device_, true, MAX_GET_FW_INFO_RETRIES), operationDeleter);
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
        operation::Flash *flashOp = dynamic_cast<operation::Flash*>(operation_.get());
        if (flashOp != nullptr) {
            flashOp->flashChunk(chunk, chunkNumber_);
            ++chunkNumber_;
        } else {
            QString errStr(QStringLiteral("Unexpected flash error."));
            qCCritical(logCategoryFlasher) << device_ << errStr;
            finish(Result::Error, errStr);
        }
    } else {
        qCCritical(logCategoryFlasher) << device_ << "Cannot read from file '" << binaryFile_.fileName() << "'. " << binaryFile_.errorString();
        finish(Result::Error, QStringLiteral("File read error. ") + binaryFile_.errorString());
    }
}

void Flasher::manageBackup(int chunkNumber) {
    operation::Backup *backupOp = dynamic_cast<operation::Backup*>(operation_.get());
    if (backupOp == nullptr) {
        QString errStr(QStringLiteral("Unexpected backup error."));
        qCCritical(logCategoryFlasher) << device_ << errStr;
        finish(Result::Error, errStr);
        return;
    }

    if (chunkNumber < 0) {  // if no chunk was backed up yet, 'chunkNumber' is negative number (-1)
        chunkCount_ = backupOp->totalChunks();
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
            emit flasherState(state_, true);
            if (chunkCount_ > 0) {
                qCInfo(logCategoryFlasher) << device_ << "Backed up chunk " << chunkNumber << " of " << chunkCount_ << " - firmware backup is done.";
                emit backupFirmwareProgress(chunkNumber, chunkCount_);
                if (startApp_) {
                    state_ = State::StartApplication;
                    emit flasherState(state_, false);

                    operation_ = std::unique_ptr<operation::StartApplication, void(*)(operation::BaseDeviceOperation*)>
                                 (new operation::StartApplication(device_), operationDeleter);
                    connectHandlers(operation_.get());
                    operation_->run();
                } else {
                    finish(Result::Ok);
                }
            } else {
                qCWarning(logCategoryFlasher) << "Cannot backup firmware which has 0 chunks.";
                // Operation 'Backup' is currently runing, it must be cancelled.
                operation_->cancelOperation();
                finish(Result::NoFirmware);
            }
            return;
        }
    }

    backupOp->backupNextChunk();
}

void Flasher::finish(Result result, QString errorString) {
    operation_.reset();
    if (binaryFile_.isOpen()) {
        binaryFile_.close();
    }
    emit finished(result, errorString);
}

void Flasher::connectHandlers(operation::BaseDeviceOperation *operation) {
    connect(operation, &operation::BaseDeviceOperation::finished, this, &Flasher::handleOperationFinished);
}

void Flasher::operationDeleter(operation::BaseDeviceOperation *operation) {
    operation->deleteLater();
}

}  // namespace
