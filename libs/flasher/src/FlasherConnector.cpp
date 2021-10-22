/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <QFile>
#include <QDir>

#include "FlasherConnector.h"
#include "logging/LoggingQtCategories.h"

#include <cstring>

namespace strata {

using platform::PlatformPtr;

FlasherConnector::FlasherConnector(const PlatformPtr& platform,
                                   const QString& firmwarePath,
                                   QObject* parent) :
    FlasherConnector(platform, firmwarePath, QString(), QString(), parent)
{ }

FlasherConnector::FlasherConnector(const QString& fwClassId,
                                   const PlatformPtr& platform,
                                   QObject* parent) :
    FlasherConnector(platform, QString(), QString(), fwClassId, parent)
{ }

FlasherConnector::FlasherConnector(const PlatformPtr& platform,
                                   const QString& firmwarePath,
                                   const QString& firmwareMD5,
                                   QObject* parent) :
    FlasherConnector(platform, firmwarePath, firmwareMD5, QString(), parent)
{ }

FlasherConnector::FlasherConnector(const PlatformPtr& platform,
                                   const QString& firmwarePath,
                                   const QString& firmwareMD5,
                                   const QString& fwClassId,
                                   QObject* parent) :
    QObject(parent),
    platform_(platform),
    flasher_(nullptr, nullptr),
    platformOperations_(true, true),
    filePath_(firmwarePath),
    newFirmwareMD5_(firmwareMD5),
    newFwClassId_(fwClassId),
    action_(Action::None)
{
    oldFwClassId_ = (newFwClassId_.isNull()) ? QString() : platform_->firmwareClassId();

    connect(&platformOperations_, &platform::operation::PlatformOperations::finished, this, &FlasherConnector::handlePlatformOperationFinished);
}

FlasherConnector::~FlasherConnector()
{
    platformOperations_.stopAllOperations();
    removeBackupFile();
}

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
        QTemporaryFile tmpBackupFile(QDir(QDir::tempPath()).filePath(QStringLiteral("firmware_backup")));
        if (tmpBackupFile.open() == false) {
            processStartupError(QStringLiteral("Cannot create temporary file name for firmware backup."));
            return false;
        }
        tmpBackupFileName_ = tmpBackupFile.fileName();
        tmpBackupFile.close();
        qCInfo(logCategoryFlasherConnector) << "Starting to backup current firmware.";
        qCDebug(logCategoryFlasherConnector).noquote() << "Temporary file for firmware backup:" << tmpBackupFileName_;
        action_ = Action::BackupOld;
        backupFirmware(true, Flasher::FinalAction::StayInBootloader);
    } else {
        qCInfo(logCategoryFlasherConnector) << "Starting to flash firmware.";
        action_ = Action::Flash;
        flashFirmware(false);
    }

    return true;
}

bool FlasherConnector::backup(Flasher::FinalAction finalAction) {
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
    backupFirmware(false, finalAction);

    return true;
}

bool FlasherConnector::setFwClassId(Flasher::FinalAction finalAction) {
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

    flasher_ = FlasherPtr(new Flasher(platform_, QString(), QString(), newFwClassId_), flasherDeleter);

    connect(flasher_.get(), &Flasher::finished, this, &FlasherConnector::handleFlasherFinished);
    connect(flasher_.get(), &Flasher::flasherState, this, &FlasherConnector::handleFlasherState);
    connect(flasher_.get(), &Flasher::devicePropertiesChanged, this, &FlasherConnector::devicePropertiesChanged);

    flasher_->setFwClassId(finalAction);

    return true;
}

void FlasherConnector::stop() {
    if (flasher_) {
        flasher_->cancel();
    }
}

void FlasherConnector::flasherDeleter(Flasher* flasher) {
    flasher->deleteLater();
}

void FlasherConnector::flashFirmware(bool flashOldFw) {
    bool skipFlash = false;

    if (flashOldFw == false
        && action_ == Action::FlashNew
        && tmpBackupFileName_.isEmpty() == false
        && QFile::exists(tmpBackupFileName_))
    {
        // FW backup is done and exists, skip flash if backed up FW is the same as new one
        QFile oldFw(tmpBackupFileName_);
        QFile newFw(filePath_);
        if (oldFw.open(QFile::ReadOnly) && newFw.open(QFile::ReadOnly)) {
            if (oldFw.size() == newFw.size()) {
                skipFlash = true;
                quint64 readOld, readNew;
                do {
                    constexpr qint64 bufferSize = 4096;
                    char oldBuffer[bufferSize], newBuffer[bufferSize];
                    readOld = oldFw.read(oldBuffer, bufferSize);
                    readNew = newFw.read(newBuffer, bufferSize);
                    if (readOld > 0 && readOld == readNew && std::memcmp(oldBuffer, newBuffer, readOld) != 0) {
                        skipFlash = false;
                        break;
                    }
                } while (readOld > 0);
            }
        }
    }

    if (skipFlash) {
        qCInfo(logCategoryFlasherConnector) << "Backed up firmware is the same as new one, flashing will be skipped.";
        removeBackupFile();

        // FlasherConnector will act as there was flashing (due to compatibility with Strata applications),
        // so we need to send same signals as during flashing. Do it by calling slots for Flasher signals.
        handleFlasherState(Flasher::State::FlashFirmware, false);

        if (platformOperations_.StartApplication(platform_) == nullptr) {
            // platform operation cannot start - same situation as if it failed
            startApplicationFailed(QStringLiteral("Cannot run operation to start application"));
        }

        return;
    }

    QString firmwarePath;
    if (flashOldFw) {
        firmwarePath = tmpBackupFileName_;
        flasher_ = FlasherPtr(new Flasher(platform_, firmwarePath, QString(), oldFwClassId_), flasherDeleter);
        connect(flasher_.get(), &Flasher::flashFirmwareProgress, this, &FlasherConnector::restoreProgress);
    } else {
        firmwarePath = filePath_;
        flasher_ = FlasherPtr(new Flasher(platform_, firmwarePath, newFirmwareMD5_, newFwClassId_), flasherDeleter);
        connect(flasher_.get(), &Flasher::flashFirmwareProgress, this, &FlasherConnector::flashProgress);
    }
    connect(flasher_.get(), &Flasher::finished, this, &FlasherConnector::handleFlasherFinished);
    connect(flasher_.get(), &Flasher::flasherState, this, &FlasherConnector::handleFlasherState);
    connect(flasher_.get(), &Flasher::devicePropertiesChanged, this, &FlasherConnector::devicePropertiesChanged);

    qCDebug(logCategoryFlasherConnector).noquote().nospace() << "Starting to flash firmware from file '" << firmwarePath <<"'.";

    // Flash firmware process is not completed until application is not started
    // because application writes data like its version into FIB.
    flasher_->flashFirmware(Flasher::FinalAction::StartApplication);
}

void FlasherConnector::backupFirmware(bool backupOldFw, Flasher::FinalAction finalAction) {
    const QString& firmwarePath = (backupOldFw) ? tmpBackupFileName_ : filePath_;
    flasher_ = FlasherPtr(new Flasher(platform_, firmwarePath), flasherDeleter);

    connect(flasher_.get(), &Flasher::finished, this, &FlasherConnector::handleFlasherFinished);
    connect(flasher_.get(), &Flasher::backupFirmwareProgress, this, &FlasherConnector::backupProgress);
    connect(flasher_.get(), &Flasher::flasherState, this, &FlasherConnector::handleFlasherState);
    connect(flasher_.get(), &Flasher::devicePropertiesChanged, this, &FlasherConnector::devicePropertiesChanged);

    flasher_->backupFirmware(finalAction);
}

void FlasherConnector::processStartupError(const QString& errorString) {
    qCCritical(logCategoryFlasherConnector).noquote() << errorString;
    emit operationStateChanged(operation_, State::Failed, errorString);
    emit finished(Result::Unsuccess);
}

void FlasherConnector::removeBackupFile()
{
    if (tmpBackupFileName_.isEmpty() == false) {
        if (QFile::exists(tmpBackupFileName_)) {
            QFile::remove(tmpBackupFileName_);
        }
        tmpBackupFileName_.clear();
    }
}

void FlasherConnector::startApplicationFailed(const QString& errorString)
{
    // attempt to star application was not successful - emit the same signals as if flashing has failed
    emit operationStateChanged(operation_, State::Failed, errorString);
    action_ = Action::None;
    // finish with 'Unsuccess' result - (original) firmware is still present, but platform is in bootloader
    emit finished(Result::Unsuccess);
}

void FlasherConnector::handleFlasherFinished(Flasher::Result flasherResult, QString errorString) {
    // We cannot delete object while we are handling signal emitted by it.
    // This is reason why custom deleter which calls deleteLater() is needed.
    flasher_.reset();

    QString errorMessage;
    State state = State::Failed;

    switch (flasherResult) {
    case Flasher::Result::Ok :
        state = State::Finished;
        break;
    case Flasher::Result::NoFirmware :
        if (operation_ == Operation::BackupBeforeFlash || operation_ == Operation::Backup) {
            state = State::NoFirmware;
        } else {
            state = State::Failed;
        }
        errorMessage = QStringLiteral("Platform has no valid firmware.");
        break;
    case Flasher::Result::BadFirmware :
        state = State::BadFirmware;
        errorMessage = QStringLiteral("Platform firmware is unable to start.");
        break;
    case Flasher::Result::Error :
    case Flasher::Result::Disconnect :
        state = State::Failed;
        if (errorString.isEmpty()) {
            errorMessage = QStringLiteral("Unknown error");
        } else {
            errorMessage = errorString;
            qCWarning(logCategoryFlasherConnector).noquote() << "Flasher error:" << errorMessage;
        }
        break;
    case Flasher::Result::Timeout :
        state = State::Failed;
        errorMessage = QStringLiteral("Timeout. No response from platform.");
        break;
    case Flasher::Result::Cancelled :
        state = State::Cancelled;
        qCWarning(logCategoryFlasherConnector) << "Firmware operation was cancelled.";
        break;
    }

    if (state != State::Finished) {
        emit operationStateChanged(operation_, state, errorMessage);
    }

    switch (action_) {
    case Action::None :
    case Action::Flash :
        action_ = Action::None;
        emit finished((flasherResult == Flasher::Result::Ok) ? Result::Success : Result::Failure);
        break;
    case Action::Backup :
        action_ = Action::None;
        {
            Result connectorResult;
            if (flasherResult == Flasher::Result::Ok) {
                connectorResult = Result::Success;
            } else if (flasherResult == Flasher::Result::BadFirmware) {
                connectorResult = Result::Unsuccess;
            } else {
                connectorResult = Result::Failure;
            }
            emit finished(connectorResult);
        }
        break;
    case Action::BackupOld :
        switch (flasherResult) {
        case Flasher::Result::BadFirmware :
            qCInfo(logCategoryFlasherConnector) << "Backed up firmware is bad.";
            [[fallthrough]];
        case Flasher::Result::Ok :
            qCInfo(logCategoryFlasherConnector) << "Starting to flash new firmware.";
            action_ = Action::FlashNew;
            flashFirmware(false);
            break;
        case Flasher::Result::NoFirmware :
            qCInfo(logCategoryFlasherConnector) << "Platform has no firmware, cannot backup. Going to flash new firmware.";
            action_ = Action::Flash;
            flashFirmware(false);
            break;
        case Flasher::Result::Error :
        case Flasher::Result::Disconnect :
        case Flasher::Result::Timeout :
            qCCritical(logCategoryFlasherConnector) << "Failed to backup original firmware.";
            [[fallthrough]];
        case Flasher::Result::Cancelled :
            action_ = Action::None;
            removeBackupFile();
            emit finished(Result::Unsuccess);
            break;
        }
        break;
    case Action::FlashNew :
        if (flasherResult == Flasher::Result::Ok) {
            action_ = Action::None;
            removeBackupFile();
            emit finished(Result::Success);
        } else {
            if ((flasherResult == Flasher::Result::Disconnect) || (flasherResult == Flasher::Result::Cancelled)) {
                action_ = Action::None;
                removeBackupFile();
                emit finished(Result::Failure);
            } else {
                qCWarning(logCategoryFlasherConnector) << "Failed to flash new firmware. Starting to flash backed up firmware.";
                action_ = Action::FlashOld;
                flashFirmware(true);
            }
        }
        break;
    case Action::FlashOld :
        action_ = Action::None;
        removeBackupFile();
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
        if (done == true) {
            emit bootloaderActive();
            if (operation_ != Operation::Preparation) {
                return;
            }
        } else {
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
    case Flasher::State::StartApplication :
        if (done == true) {
            emit applicationActive();
        }
        return;  // return from function, we do not care about this flasher state anymore
        break;
    default :
        // we do not care about other flasher states (IdentifyBoard, FlashBootloader)
        return;
    }

    if (done) {
        emit operationStateChanged(operation_, State::Finished);
    } else {
        operation_ = newOperation;
        emit operationStateChanged(operation_, State::Started);
    }
}

void FlasherConnector::handlePlatformOperationFinished(QByteArray deviceId,
                                                       platform::operation::Type type,
                                                       platform::operation::Result result,
                                                       int status,
                                                       QString errorString)
{
    Q_UNUSED(status)

    if (type == platform::operation::Type::StartApplication) {
        // Current firmware was started instead of flashing new one.
        // Emit the same signals as during normal flashing (by calling
        // slots for Flasher signals if possible).

        if (result == platform::operation::Result::Success) {
            emit flashProgress(1, 1);
            emit devicePropertiesChanged();
            handleFlasherState(Flasher::State::FlashFirmware, true);
            handleFlasherState(Flasher::State::StartApplication, true);
            handleFlasherFinished(Flasher::Result::Ok, QString());
        } else {
            qCWarning(logCategoryFlasherConnector).noquote()
                << "Cannot start firmware for device" << deviceId << '-' << errorString;
            startApplicationFailed(errorString);
        }
    }
}

}  // namespace
