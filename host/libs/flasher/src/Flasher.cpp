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

Flasher::Flasher(std::shared_ptr<strata::SerialDevice> device, const QString& firmwareFilename) :
    device_(device), fwFile_(firmwareFilename)
{
    deviceId_ = static_cast<uint>(device_->getDeviceId());
    operation_ = std::make_unique<DeviceOperations>(device_);

    connect(operation_.get(), &DeviceOperations::readyForFlashFw, [this](){this->handleFlashFirmware(-1);});
    connect(operation_.get(), &DeviceOperations::fwChunkFlashed, this, &Flasher::handleFlashFirmware);
    connect(operation_.get(), &DeviceOperations::applicationStarted, this, &Flasher::handleStartApp);
    connect(operation_.get(), &DeviceOperations::timeout, this, &Flasher::handleTimeout);
    connect(operation_.get(), &DeviceOperations::error, this, &Flasher::handleError);
    connect(operation_.get(), &DeviceOperations::cancelled, this, &Flasher::handleCancel);

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

void Flasher::handleStartApp() {
    qCInfo(logCategoryFlasher) << this << "Flashed firmware is ready for use.";
    finish(true);
}

void Flasher::handleTimeout() {
    qCCritical(logCategoryFlasher) << this << "Timeout during flashing.";
    finish(false);
}

void Flasher::handleError(QString msg) {
    qCCritical(logCategoryFlasher).noquote() << this << "Error during flashing: " << msg;
    finish(false);
}

void Flasher::handleCancel() {
    qCInfo(logCategoryFlasher) << this << "Flashing was cancelled.";
    finish(false);
}

void Flasher::finish(bool success) {
    if (fwFile_.isOpen()) {
        fwFile_.close();
    }
    emit finished(success);
}

}  // namespace
