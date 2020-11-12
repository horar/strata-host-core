#include <QFile>
#include <QDir>

#include "FlasherConnector.h"
#include "logging/LoggingQtCategories.h"

namespace strata {

FlasherConnector::FlasherConnector(const device::DevicePtr& device, const QString& firmwarePath, QObject* parent) :
    FlasherConnector(device, firmwarePath, QString(), parent) { }

FlasherConnector::FlasherConnector(const device::DevicePtr& device,
                                   const QString& firmwarePath,
                                   const QString& firmwareMD5,
                                   QObject* parent) :
    QObject(parent),
    device_(device),
    filePath_(firmwarePath),
    newFirmwareMD5_(firmwareMD5),
    tmpBackupFile_(QDir(QDir::tempPath()).filePath(QStringLiteral("firmware_backup"))),
    action_(Action::None)
{ }

FlasherConnector::~FlasherConnector() { }

bool FlasherConnector::flash(bool backupBeforeFlash) {
    operation_ = Operation::Preparation;
    emit operationStateChanged(operation_, State::Started);

    if (action_ != Action::None) {
        processStartupError(QStringLiteral("Cannot flash firmware because another firmware operation is running."));
        return false;
    }

    if (QFile::exists(filePath_) == false) {
        processStartupError(QStringLiteral("Firmware file does not exist."));
        return false;
    }

    if (backupBeforeFlash) {
        if (tmpBackupFile_.open() == false) {
            processStartupError(QStringLiteral("Cannot create temporary file for firmware backup."));
            return false;
        }
        qCInfo(logCategoryFlasherConnector) << "Starting to backup current firmware.";
        qCDebug(logCategoryFlasherConnector).noquote() << "Temporary file for firmware backup:" << tmpBackupFile_.fileName();
        action_ = Action::BackupOld;
        backupFirmware(true);
    } else {
        qCInfo(logCategoryFlasherConnector) << "Starting to flash firmware.";
        action_ = Action::Flash;
        flashFirmware(false);
    }

    return true;
}

bool FlasherConnector::backup() {
    operation_ = Operation::Preparation;
    emit operationStateChanged(operation_, State::Started);

    if (action_ != Action::None) {
        processStartupError(QStringLiteral("Cannot flash firmware because another firmware operation is running."));
        return false;
    }

    qCInfo(logCategoryFlasherConnector) << "Starting to backup firmware.";
    action_ = Action::Backup;
    backupFirmware(false);

    return true;
}

void FlasherConnector::stop() {
    if (flasher_) {
        flasher_->cancel();
    }
}

void FlasherConnector::setFirmwarePath(const QString& firmwarePath) {
    filePath_ = firmwarePath;
}

void FlasherConnector::flashFirmware(bool flashOld) {
    const QString& firmwarePath = (flashOld) ? tmpBackupFile_.fileName() : filePath_;
    qCDebug(logCategoryFlasherConnector).noquote().nospace() << "Starting to flash firmware from file '" << firmwarePath <<"'.";
    (flashOld)
        ? flasher_ = std::make_unique<Flasher>(device_, firmwarePath)
        : flasher_ = std::make_unique<Flasher>(device_, firmwarePath, newFirmwareMD5_);

    connect(flasher_.get(), &Flasher::finished, this, &FlasherConnector::handleFlasherFinished);
    (flashOld)
        ? connect(flasher_.get(), &Flasher::flashFirmwareProgress, this, &FlasherConnector::restoreProgress)
        : connect(flasher_.get(), &Flasher::flashFirmwareProgress, this, &FlasherConnector::flashProgress);
    connect(flasher_.get(), &Flasher::switchToBootloader, this, &FlasherConnector::handleSwitchToBootloader);
    connect(flasher_.get(), &Flasher::devicePropertiesChanged, this, &FlasherConnector::devicePropertiesChanged);

    if (operation_ != Operation::Preparation) {
        startOperation();
    }

    flasher_->flashFirmware();
}

void FlasherConnector::backupFirmware(bool backupOld) {
    bool startApp = (backupOld) ? false : true;

    const QString& firmwarePath = (backupOld) ? tmpBackupFile_.fileName() : filePath_;
    flasher_ = std::make_unique<Flasher>(device_, firmwarePath);

    connect(flasher_.get(), &Flasher::finished, this, &FlasherConnector::handleFlasherFinished);
    connect(flasher_.get(), &Flasher::backupFirmwareProgress, this, &FlasherConnector::backupProgress);
    connect(flasher_.get(), &Flasher::switchToBootloader, this, &FlasherConnector::handleSwitchToBootloader);
    connect(flasher_.get(), &Flasher::devicePropertiesChanged, this, &FlasherConnector::devicePropertiesChanged);

    if (operation_ != Operation::Preparation) {
        startOperation();
    }

    flasher_->backupFirmware(startApp);
}

void FlasherConnector::startOperation() {
    switch (action_) {
    case Action::Flash :
    case Action::FlashNew :
        operation_ = Operation::Flash;
        break;
    case Action::Backup :
        operation_ = Operation::Backup;
        break;
    case Action::BackupOld :
        operation_ = Operation::BackupBeforeFlash;
        break;
    case Action::FlashOld :
        operation_ = Operation::RestoreFromBackup;
        break;
    case Action::None :
        return;
    }
    emit operationStateChanged(operation_, State::Started);
}

void FlasherConnector::processStartupError(const QString& errorString) {
    qCCritical(logCategoryFlasherConnector).noquote() << errorString;
    emit operationStateChanged(operation_, State::Failed, errorString);
    emit finished(Result::Unsuccess);
}

void FlasherConnector::handleFlasherFinished(Flasher::Result flasherResult, QString errorString) {
    flasher_.reset();

    QString errorMessage;
    State result = State::Failed;
    switch (flasherResult) {
    case Flasher::Result::Ok :
        result = State::Finished;
        break;
    case Flasher::Result::NoFirmware :
        result = State::Failed;
        errorMessage = QStringLiteral("The board has no valid firmware.");
        break;
    case Flasher::Result::Error :
        result = State::Failed;
        if (errorString.isEmpty()) {
            errorMessage = QStringLiteral("Unknown error");
        } else {
            errorMessage = errorString;
            qCDebug(logCategoryFlasherConnector).noquote() << "Flasher error:" << errorMessage;
        }
        break;
    case Flasher::Result::Timeout :
        result = State::Failed;
        errorMessage = QStringLiteral("Timeout. No response from board.");
        break;
    case Flasher::Result::Cancelled :
        result = State::Cancelled;
        qCWarning(logCategoryFlasherConnector) << "Firmware operation was cancelled.";
        break;
    }
    if (result == State::Failed) {
        emit operationStateChanged(operation_, result, errorMessage);
    } else {
        emit operationStateChanged(operation_, result);
    }

    switch (action_) {
    case Action::None :
    case Action::Flash :
        action_ = Action::None;
        emit finished((flasherResult == Flasher::Result::Ok) ? Result::Success : Result::Failure);
        break;
    case Action::Backup :
        action_ = Action::None;
        emit finished((flasherResult == Flasher::Result::Ok) ? Result::Success : Result::Unsuccess);
        break;
    case Action::BackupOld :
        if (flasherResult == Flasher::Result::Ok) {
            qCInfo(logCategoryFlasherConnector) << "Starting to flash new firmware.";
            action_ = Action::FlashNew;
            flashFirmware(false);
        } else {
            if (flasherResult == Flasher::Result::NoFirmware) {
                qCInfo(logCategoryFlasherConnector) << "Board has no firmware, cannot backup. Going to flash new firmware.";
                action_ = Action::Flash;
                flashFirmware(false);
            } else {
                if (flasherResult != Flasher::Result::Cancelled) {
                    qCCritical(logCategoryFlasherConnector) << "Failed to backup original firmware.";
                }
                action_ = Action::None;
                emit finished(Result::Unsuccess);
            }
        }
        break;
    case Action::FlashNew :
        if (flasherResult == Flasher::Result::Ok) {
            action_ = Action::None;
            emit finished(Result::Success);
        } else {
            if (flasherResult != Flasher::Result::Cancelled) {
                qCWarning(logCategoryFlasherConnector) << "Failed to flash new firmware. Starting to flash backed up firmware.";
                action_ = Action::FlashOld;
                flashFirmware(true);
            } else {
                emit finished(Result::Failure);
            }
        }
        break;
    case Action::FlashOld :
        action_ = Action::None;
        emit finished((flasherResult == Flasher::Result::Ok) ? Result::Unsuccess : Result::Failure);
        break;
    }
    return;
}

void FlasherConnector::handleSwitchToBootloader(bool done) {
    if (done && (operation_ == Operation::Preparation)) {
        emit operationStateChanged(operation_, State::Finished);
        startOperation();
    }
}

}  // namespace
