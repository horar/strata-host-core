#include "Flasher.h"
#include "FlasherConstants.h"

#include <SerialDevice.h>
#include <DeviceProperties.h>
#include <DeviceOperations.h>

#include "logging/LoggingQtCategories.h"

namespace strata {

QDebug operator<<(QDebug dbg, const Flasher* f) {
    return dbg.nospace() << "Flasher for device 0x" << hex << f->device_id_ << ": ";
}

Flasher::Flasher(std::shared_ptr<strata::SerialDevice> device, const QString& firmwareFilename) :
    device_(device), fw_file_(firmwareFilename)
{
    device_id_ = static_cast<uint>(device_->getConnectionId());
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
    start_app_ = startApplication;
    if (fw_file_.open(QIODevice::ReadOnly)) {
        if (fw_file_.size() > 0) {
            chunk_number_ = 0;
            chunk_count_ = static_cast<int>((fw_file_.size() - 1 + CHUNK_SIZE) / CHUNK_SIZE);
            qCInfo(logCategoryFlasher) << this << "Preparing for flashing " << dec << chunk_count_ << " chunks of firmware.";
            operation_->prepareForFlash();
        } else {
            qCWarning(logCategoryFlasher).noquote() << this << "File '" << fw_file_.fileName() << "' is empty.";
            finish(false);
        }
    } else {
        qCWarning(logCategoryFlasher).noquote() << this << "Cannot open file '" << fw_file_.fileName() << "'.";
        finish(false);
    }
}

void Flasher::handleFlashFirmware(int lastFlashedChunk) {
    if (lastFlashedChunk == 0) {
        fw_file_.close();
        qCInfo(logCategoryFlasher) << this << "Firmware is flashed.";
        if (start_app_) {
            operation_->startApplication();
        } else {
            finish(true);
        }
        return;
    }
    chunk_number_++;
    int chunk_num_log = chunk_number_;  // chunk number for log
    int chunk_size = CHUNK_SIZE;
    qint64 remaining_file_size = fw_file_.size() - fw_file_.pos();
    if (remaining_file_size <= CHUNK_SIZE) {
        chunk_number_ = 0;  // the last chunk
        chunk_size = static_cast<int>(remaining_file_size);
    }
    QVector<quint8> chunk(chunk_size);

    qint64 bytes_read = fw_file_.read(reinterpret_cast<char*>(chunk.data()), chunk_size);
    if (bytes_read == chunk_size) {
        qCInfo(logCategoryFlasher) << this << "Going to flash chunk " << dec << chunk_num_log << " of " << chunk_count_;
        operation_->flashFirmwareChunk(chunk, chunk_number_);
    } else {
        qCWarning(logCategoryFlasher).noquote() << this << "Cannot read from file " << fw_file_.fileName() ;
        finish(false);
    }
}

void Flasher::handleStartApp() {
    qCInfo(logCategoryFlasher) << this << "Flashed firmware is ready for use.";
    finish(true);
}

void Flasher::handleTimeout() {
    qCWarning(logCategoryFlasher) << this << "Timeout during flashing.";
    finish(false);
}

void Flasher::handleError(QString msg) {
    qCWarning(logCategoryFlasher).noquote() << this << "Error during flashing: " << msg;
    finish(false);
}

void Flasher::handleCancel() {
    qCInfo(logCategoryFlasher) << this << "Flashing was cancelled.";
    finish(false);
}

void Flasher::finish(bool success) {
    if (fw_file_.isOpen()) {
        fw_file_.close();
    }
    emit finished(success);
}

}  // namespace
