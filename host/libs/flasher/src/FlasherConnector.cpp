#include <QFile>
#include <QDir>

#include "FlasherConnector.h"
#include "logging/LoggingQtCategories.h"

namespace strata {

FlasherConnector::FlasherConnector(const device::DevicePtr& device,
                                   const QString& firmwarePath,
                                   QObject* parent) :
    FlasherConnector(device, firmwarePath, QString(), QString(), parent)
{ }

FlasherConnector::FlasherConnector(const QString& fwClassId,
                                   const device::DevicePtr& device,
                                   QObject* parent) :
    FlasherConnector(device, QString(), QString(), fwClassId, parent)
{ }

FlasherConnector::FlasherConnector(const device::DevicePtr& device,
                                   const QString& firmwarePath,
                                   const QString& firmwareMD5,
                                   QObject* parent) :
    FlasherConnector(device, firmwarePath, firmwareMD5, QString(), parent)
{ }

FlasherConnector::FlasherConnector(const device::DevicePtr& device,
                                   const QString& firmwarePath,
                                   const QString& firmwareMD5,
                                   const QString& fwClassId,
                                   QObject* parent) :
    QObject(parent),
    device_(device),
    filePath_(firmwarePath),
    newFirmwareMD5_(firmwareMD5),
    newFwClassId_(fwClassId),
    tmpBackupFile_(QDir(QDir::tempPath()).filePath(QStringLiteral("firmware_backup"))),
    action_(Action::None)
{
    oldFwClassId_ = (newFwClassId_.isNull()) ? QString() : device_->firmwareClassId();
}

FlasherConnector::~FlasherConnector() { }

bool FlasherConnector::flash(bool backupBeforeFlash) {
    operation_ = Operation::Preparation;
    emit operationStateChanged(operation_, State::Started);

    if (action_ != Action::None) {
        processStartupError(QStringLiteral("Cannot flash firmware because another firmware operation is running."));
        return false;
    }

    if (filePath_.isEmpty()) {
        processStartupError(QStringLiteral("No firmware file was provided."));
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
        processStartupError(QStringLiteral("Cannot backup firmware because another firmware operation is running."));
        return false;
    }

    if (filePath_.isEmpty()) {
        processStartupError(QStringLiteral("No backup file was provided."));
        return false;
    }

    qCInfo(logCategoryFlasherConnector) << "Starting to backup firmware.";
    action_ = Action::Backup;
    backupFirmware(false);

    return true;
}

bool FlasherConnector::setFwClassId() {
    operation_ = Operation::Preparation;
    emit operationStateChanged(operation_, State::Started);

    if (action_ != Action::None) {
        processStartupError(QStringLiteral("Cannot set firmware class ID because another firmware operation is running."));
        return false;
    }

    if (newFwClassId_.isNull()) {
        processStartupError(QStringLiteral("No firmware class ID was provided."));
        return false;
    }

    qCInfo(logCategoryFlasherConnector) << "Starting to set firmware class ID.";
    action_ = Action::SetFwClassId;

    flasher_ = std::make_unique<Flasher>(device_, QString(), QString(), newFwClassId_);

    connect(flasher_.get(), &Flasher::finished, this, &FlasherConnector::handleFlasherFinished);
    connect(flasher_.get(), &Flasher::flasherState, this, &FlasherConnector::handleFlasherState);
    connect(flasher_.get(), &Flasher::devicePropertiesChanged, this, &FlasherConnector::devicePropertiesChanged);

    flasher_->setFwClassId();

    return true;
}

void FlasherConnector::stop() {
    if (flasher_) {
        flasher_->cancel();
    }
}

void FlasherConnector::flashFirmware(bool flashOld) {
    QString firmwarePath;
    if (flashOld) {
        firmwarePath = tmpBackupFile_.fileName();
        flasher_ = std::make_unique<Flasher>(device_, firmwarePath, QString(), oldFwClassId_);
        connect(flasher_.get(), &Flasher::flashFirmwareProgress, this, &FlasherConnector::restoreProgress);
    } else {
        firmwarePath = filePath_;
        flasher_ = std::make_unique<Flasher>(device_, firmwarePath, newFirmwareMD5_, newFwClassId_);
        connect(flasher_.get(), &Flasher::flashFirmwareProgress, this, &FlasherConnector::flashProgress);
    }
    connect(flasher_.get(), &Flasher::finished, this, &FlasherConnector::handleFlasherFinished);
    connect(flasher_.get(), &Flasher::flasherState, this, &FlasherConnector::handleFlasherState);
    connect(flasher_.get(), &Flasher::devicePropertiesChanged, this, &FlasherConnector::devicePropertiesChanged);

    qCDebug(logCategoryFlasherConnector).noquote().nospace() << "Starting to flash firmware from file '" << firmwarePath <<"'.";

    flasher_->flashFirmware();
}

void FlasherConnector::backupFirmware(bool backupOld) {
    bool startApp = (backupOld) ? false : true;

    const QString& firmwarePath = (backupOld) ? tmpBackupFile_.fileName() : filePath_;
    flasher_ = std::make_unique<Flasher>(device_, firmwarePath);

    connect(flasher_.get(), &Flasher::finished, this, &FlasherConnector::handleFlasherFinished);
    connect(flasher_.get(), &Flasher::backupFirmwareProgress, this, &FlasherConnector::backupProgress);
    connect(flasher_.get(), &Flasher::flasherState, this, &FlasherConnector::handleFlasherState);
    connect(flasher_.get(), &Flasher::devicePropertiesChanged, this, &FlasherConnector::devicePropertiesChanged);

    flasher_->backupFirmware(startApp);
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
        if (operation_ == Operation::BackupBeforeFlash || operation_ == Operation::Backup) {
            result = State::NoFirmware;
        } else {
            result = State::Failed;
        }
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

    if (result != State::Finished) {
        emit operationStateChanged(operation_, result, errorMessage);
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
    case Action::SetFwClassId :
        action_ = Action::None;
        emit finished((flasherResult == Flasher::Result::Ok) ? Result::Success : Result::Unsuccess);
        break;
    }

    return;
}

void FlasherConnector::handleFlasherState(Flasher::State flasherState, bool done) {
    Operation newOperation;

    switch (flasherState) {
    case Flasher::State::SwitchToBootloader :
        // When FlasherConnector starts some operation, 'operation_' is set to 'Preparation'.
        // Ignore 'SwitchToBootloader' state if 'operation_' is not 'Preparation' and this state is not done.
        if ((operation_ != Operation::Preparation) || (done == false)) {
            return;
        }
        break;
    case Flasher::State::ClearFwClassId :
        newOperation = Operation::ClearFwClassId;
        break;
    case Flasher::State::SetFwClassId :
        newOperation = Operation::SetFwClassId;
        break;
    case Flasher::State::FlashFirmware :
        newOperation = (action_ == Action::FlashOld) ? Operation::RestoreFromBackup : Operation::Flash;
        break;
    case Flasher::State::BackupFirmware :
        newOperation = (action_ == Action::BackupOld) ? Operation::BackupBeforeFlash : Operation::Backup;
        break;
    default :
        // we do not care about other flasher states (StartApplication, IdentifyBoard, FlashBootloader)
        return;
    }

    if (done) {
        emit operationStateChanged(operation_, State::Finished);
    } else {
        operation_ = newOperation;
        emit operationStateChanged(operation_, State::Started);
    }
}

}  // namespace
