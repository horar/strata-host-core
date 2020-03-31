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

Flasher::Flasher(SerialDevicePtr device, const QString& firmwareFilename) :
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
            chunkNumber_ = 0;
            chunkCount_ = static_cast<int>((fwFile_.size() - 1 + CHUNK_SIZE) / CHUNK_SIZE);
            qCInfo(logCategoryFlasher) << this << "Preparing for flashing " << dec << chunkCount_ << " chunks of firmware.";
            operation_->prepareForFlash();
        } else {
            qCCritical(logCategoryFlasher).noquote() << this << "File '" << fwFile_.fileName() << "' is empty.";
            finish(false);
        }
    } else {
        qCCritical(logCategoryFlasher).noquote() << this << "Cannot open file '" << fwFile_.fileName() << "'.";
        finish(false);
    }
}

void Flasher::handleOperationFinished(int operation, int data) {
    DeviceOperations::Operation op = static_cast<DeviceOperations::Operation>(operation);
    switch (op) {
    case DeviceOperations::Operation::PrepareForFlash :
    case DeviceOperations::Operation::FlashFirmwareChunk :
        handleFlashFirmware(data);
        break;
    case DeviceOperations::Operation::StartApplication :
        qCInfo(logCategoryFlasher) << this << "Flashed firmware is ready for use.";
        finish(true);
        break;
    case DeviceOperations::Operation::Timeout :
        qCWarning(logCategoryFlasher) << this << "Timeout during flashing.";
        finish(false);
        break;
    case DeviceOperations::Operation::Cancel :
        qCInfo(logCategoryFlasher) << this << "Flashing was cancelled.";
        finish(false);
        break;
    default :
        qCWarning(logCategoryFlasher) << this << "Unsupported operation.";
        finish(false);
    }
}


void Flasher::handleFlashFirmware(int lastFlashedChunk) {
    if (lastFlashedChunk == 0) {
        fwFile_.close();
        qCInfo(logCategoryFlasher) << this << "Firmware is flashed.";
        if (startApp_) {
            operation_->startApplication();
        } else {
            finish(true);
        }
        return;
    }
    chunkNumber_++;
    int chunkNumLog = chunkNumber_;  // chunk number for log
    int chunkSize = CHUNK_SIZE;
    qint64 remainingFileSize = fwFile_.size() - fwFile_.pos();
    if (remainingFileSize <= CHUNK_SIZE) {
        chunkNumber_ = 0;  // the last chunk
        chunkSize = static_cast<int>(remainingFileSize);
    }
    QVector<quint8> chunk(chunkSize);

    qint64 bytesRead = fwFile_.read(reinterpret_cast<char*>(chunk.data()), chunkSize);
    if (bytesRead == chunkSize) {
        qCInfo(logCategoryFlasher) << this << "Going to flash chunk " << dec << chunkNumLog << " of " << chunkCount_;
        operation_->flashFirmwareChunk(chunk, chunkNumber_);
    } else {
        qCCritical(logCategoryFlasher).noquote() << this << "Cannot read from file " << fwFile_.fileName() ;
        finish(false);
    }
}

void Flasher::handleOperationError(QString msg) {
    qCWarning(logCategoryFlasher).noquote() << this << "Error during flashing: " << msg;
    finish(false);
}

void Flasher::finish(bool success) {
    if (fwFile_.isOpen()) {
        fwFile_.close();
    }
    emit finished(success);
}

}  // namespace
