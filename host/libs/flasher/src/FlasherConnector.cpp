#include "FlasherConnector.h"

#include "logging/LoggingQtCategories.h"

namespace strata {

FlasherConnector::FlasherConnector(const SerialDevicePtr& device, const QString& firmwarePath, QObject* parent) :
    QObject(parent), device_(device), filePath_(firmwarePath), state_(State::None) { }

FlasherConnector::~FlasherConnector() { }

bool FlasherConnector::flash(bool backupOld) {
    if (state_ != State::None) {
       qCWarning(logCategoryFlasherConnector) << "Cannot flash firmware because another firmware operation is running.";
       return false;
    }

    if (backupOld) {
        if (tmpBackupFile_.open() == false) {
            qCCritical(logCategoryFlasherConnector) << "Cannot create temporary file for firmware backup.";
            return false;
        }
        state_ = State::BackupOld;
        backupFirmware(true);
    } else {
        state_ = State::Flash;
        flashFirmware(false);
    }

    return true;
}

bool FlasherConnector::backup() {
    if (state_ != State::None) {
       qCWarning(logCategoryFlasherConnector) << "Cannot backup firmware because another firmware operation is running.";
       return false;
    }
    state_ = State::Backup;

    backupFirmware(false);

    return true;
}

void FlasherConnector::stop() {
    if (flasher_) {
        flasher_->cancel();
    } else {
        emit finished(Flasher::Result::Cancelled);
    }
}

void FlasherConnector::setFirmwarePath(const QString& firmwarePath) {
    filePath_ = firmwarePath;
}

void FlasherConnector::flashFirmware(bool flashOld) {
    const QString& firmwarePath = (flashOld) ? tmpBackupFile_.fileName() : filePath_;
    flasher_ = std::make_unique<Flasher>(device_, firmwarePath);

    connect(flasher_.get(), &Flasher::finished, this, &FlasherConnector::handleFlasherFinished);
    connect(flasher_.get(), &Flasher::flashProgress, this, &FlasherConnector::flashProgress);

    flasher_->flash();
}

void FlasherConnector::backupFirmware(bool backupOld) {
    bool startApp = (backupOld) ? false : true;

    const QString& firmwarePath = (backupOld) ? tmpBackupFile_.fileName() : filePath_;
    flasher_ = std::make_unique<Flasher>(device_, firmwarePath);

    connect(flasher_.get(), &Flasher::finished, this, &FlasherConnector::handleFlasherFinished);
    connect(flasher_.get(), &Flasher::backupProgress, this, &FlasherConnector::backupProgress);

    flasher_->backup(startApp);
}

void FlasherConnector::handleFlasherFinished(Flasher::Result result, QString errorString) {
    flasher_.reset();

    switch (state_) {
    case State::None :
    case State::Flash :
    case State::Backup :
    case State::FlashOld :
        state_ = State::None;
        emit finished(result, errorString);
        break;
    case State::BackupOld :
        if (result == Flasher::Result::Ok) {
            state_ = State::FlashNew;
            flashFirmware(false);
        } else {
            state_ = State::None;
            emit finished(result, errorString);
        }
        break;
    case State::FlashNew :
        if (result == Flasher::Result::Ok) {
            state_ = State::None;
            emit finished(result, errorString);
        } else {
            state_ = State::FlashOld;
            flashFirmware(true);
        }
    }
}

}  // namespace
