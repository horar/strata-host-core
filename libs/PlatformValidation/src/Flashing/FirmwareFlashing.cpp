/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "FirmwareFlashing.h"
#include "ValidationStatus.h"
#include "logging/LoggingQtCategories.h"

#include <QDir>
#include <QFile>
#include <QTemporaryFile>

#include <cstring>

namespace strata::platform::validation {

FirmwareFlashing::FirmwareFlashing(const PlatformPtr &platform, const QString &name, const QString &firmwarePath)
    : platform_(platform),
      name_(name),
      firmwarePath_(firmwarePath),
      currentAction_(Action::None),
      rewriteLastStatus_(false)
{ }

FirmwareFlashing::~FirmwareFlashing()
{
    removeBackupFile();
}

void FirmwareFlashing::run()
{
    if (platform_.get() == nullptr) {
        QString message(QStringLiteral("Device is not set"));
        qCWarning(lcPlatformValidation) << message;
        emit validationStatus(Status::Error, message);
        finishValidation(false);
        return;
    }

    if (platform_->deviceConnected() == false) {
        QString message(QStringLiteral("Cannot run flashing validation, device is not connected"));
        qCWarning(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Error, message);
        finishValidation(false);
        return;
    }

    if (currentAction_ != Action::None) {
        QString message(QStringLiteral("The flashing validation is already running"));
        qCWarning(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Error, message);
        return;
    }

    QString message = name_ + QStringLiteral(" is about to start with firmware file '") + firmwarePath_ + '\'';
    qCInfo(lcPlatformValidation) << platform_ << message;
    emit validationStatus(Status::Plain, message);

    flashFirmware();
}

void FirmwareFlashing::handleFlasherFinished(Flasher::Result result, QString errorString)
{
    flasher_.reset();

    if (result != Flasher::Result::Ok) {
        qCWarning(lcPlatformValidation) << platform_ << errorString;
        emit validationStatus(Status::Error, errorString);
        finishValidation(false);
        return;
    }

    switch (currentAction_) {
    case Action::None :
        break;
    case Action::Flash :
        backupFirmware();
        break;
    case Action::Backup :
        compareFirmwares();
        break;
    }
}

void FirmwareFlashing::handleflasherState(Flasher::State state, bool done)
{
    QString message;

    switch (state) {
    case Flasher::State::FlashFirmware :
        message = (done)
                  ? QStringLiteral("Firmware flashed")
                  : QStringLiteral("Starting to flash firmware '") + firmwarePath_ + '\'';
        break;
    case Flasher::State::BackupFirmware :
        message = (done)
                  ? QStringLiteral("Firmware backed up")
                  : QStringLiteral("Starting to backup firmware");
        break;
    case Flasher::State::StartApplication :
        message = (done)
                  ? QStringLiteral("Application is running")
                  : QStringLiteral("Starting application (firmware)");
        break;
    default :
        return;
        break;
    }

    qCInfo(lcPlatformValidation) << platform_ << message;
    if (done) {
        emit validationStatus(Status::Success, message);
    } else {
        emit validationStatus(Status::Plain, message);
    }
}

void FirmwareFlashing::handleFlashProgress(int chunk, int total)
{
    QString message = QStringLiteral("Flashing firmware: ") + computeProgress(chunk, total);
    qCInfo(lcPlatformValidation) << platform_ << message;
    emit validationStatus(Status::Info, message, rewriteLastStatus_);

    if (rewriteLastStatus_ == false) {
        rewriteLastStatus_ = true;
    }
}

void FirmwareFlashing::handleBackupProgress(int chunk, int total)
{
    QString message = QStringLiteral("Backing up firmware: ") + computeProgress(chunk, total);
    qCInfo(lcPlatformValidation) << platform_ << message;
    emit validationStatus(Status::Info, message, rewriteLastStatus_);

    if (rewriteLastStatus_ == false) {
        rewriteLastStatus_ = true;
    }
}

void FirmwareFlashing::finishValidation(bool passed)
{
    if (passed) {
        QString message = name_ + QStringLiteral(" PASS");
        qCInfo(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Success, message);
    } else {
        QString message = name_ + QStringLiteral(" FAIL");
        qCWarning(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Error, message);
    }

    currentAction_ = Action::None;
    removeBackupFile();

    emit finished();
}

void FirmwareFlashing::flashFirmware()
{
    currentAction_ = Action::Flash;

    flasher_ = std::make_unique<Flasher>(platform_, firmwarePath_);

    // finished() signal must be connected through queued connection because flasher_ is being deleted in handleFlasherFinished()
    connect(flasher_.get(), &Flasher::finished, this, &FirmwareFlashing::handleFlasherFinished, Qt::QueuedConnection);
    connect(flasher_.get(), &Flasher::flasherState, this, &FirmwareFlashing::handleflasherState);
    connect(flasher_.get(), &Flasher::flashFirmwareProgress, this, &FirmwareFlashing::handleFlashProgress);

    rewriteLastStatus_ = false;

    flasher_->flashFirmware(Flasher::FinalAction::StartApplication);
}

void FirmwareFlashing::backupFirmware()
{
    currentAction_ = Action::Backup;

    QTemporaryFile tmpBackupFile(QDir(QDir::tempPath()).filePath(QStringLiteral("test_fw_backup")));
    if (tmpBackupFile.open() == false) {
        QString message(QStringLiteral("Cannot create temporary file name for firmware backup"));
        qCWarning(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Error, message);
        finishValidation(false);
        return;
    }
    tmpBackupFilePath_ = tmpBackupFile.fileName();
    tmpBackupFile.close();
    qCDebug(lcPlatformValidation) << platform_ << "Temporary file for firmware backup: '" << tmpBackupFilePath_ << "'.";

    flasher_ = std::make_unique<Flasher>(platform_, tmpBackupFilePath_);

    // finished() signal must be connected through queued connection because flasher_ is being deleted in handleFlasherFinished()
    connect(flasher_.get(), &Flasher::finished, this, &FirmwareFlashing::handleFlasherFinished, Qt::QueuedConnection);
    connect(flasher_.get(), &Flasher::flasherState, this, &FirmwareFlashing::handleflasherState);
    connect(flasher_.get(), &Flasher::backupFirmwareProgress, this, &FirmwareFlashing::handleBackupProgress);

    rewriteLastStatus_ = false;

    flasher_->backupFirmware(Flasher::FinalAction::StartApplication);
}

void FirmwareFlashing::compareFirmwares()
{
    QFile flashedFw(firmwarePath_);
    QFile backedUpFw(tmpBackupFilePath_);
    bool success = false;
    {
        QString message(QStringLiteral("Going to compare flashed and backed up firmware"));
        qCInfo(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Plain, message);
    }

    if (flashedFw.open(QFile::ReadOnly) && backedUpFw.open(QFile::ReadOnly)) {
        bool filesEqual = false;
        if (flashedFw.size() == backedUpFw.size()) {
            filesEqual = true;
            quint64 readFlashed;
            do {
                constexpr qint64 bufferSize = 4096;
                char flashedBuffer[bufferSize];
                char backedUpBuffer[bufferSize];
                readFlashed = flashedFw.read(flashedBuffer, bufferSize);
                quint64 readBackedUp = backedUpFw.read(backedUpBuffer, bufferSize);
                if ((readFlashed != readBackedUp) || (std::memcmp(flashedBuffer, backedUpBuffer, readFlashed) != 0)) {
                    filesEqual = false;
                    break;
                }
            } while (readFlashed > 0);
        }

        if (filesEqual) {
            if (flashedFw.size() > 0) {
                QString message(QStringLiteral("Flashed and backed up firmware is equal"));
                qCInfo(lcPlatformValidation) << platform_ << message;
                emit validationStatus(Status::Success, message);
                success = true;
            } else {
                QString message(QStringLiteral("Firmware files are empty"));
                qCWarning(lcPlatformValidation) << platform_ << message;
                emit validationStatus(Status::Error, message);
            }
        } else {
            QString message(QStringLiteral("Flashed and backed up firmware is different"));
            qCWarning(lcPlatformValidation) << platform_ << message;
            emit validationStatus(Status::Error, message);
        }
    } else {
        QString message(QStringLiteral("Cannot open firmware files for comparison"));
        qCWarning(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Error, message);
    }

    finishValidation(success);
}

void FirmwareFlashing::removeBackupFile()
{
    if (tmpBackupFilePath_.isEmpty() == false) {
        if (QFile::exists(tmpBackupFilePath_)) {
            QFile::remove(tmpBackupFilePath_);
        }
        tmpBackupFilePath_.clear();
    }
}

QString FirmwareFlashing::computeProgress(int chunk, int total)
{
    if ((chunk > 0) && (total > 0)) {
        int progress = (100 * chunk) / total;
        return QString::number(progress) + '%';
    }
    return QString();
}

}  // namespace
