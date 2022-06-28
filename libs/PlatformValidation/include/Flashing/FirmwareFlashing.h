/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <memory>

#include <QObject>
#include <QString>

#include <Platform.h>
#include <Flasher.h>

namespace strata::platform::validation {

enum class Status : short;

class FirmwareFlashing : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(FirmwareFlashing)

public:
    /*!
     * FirmwareFlashing constructor
     */
    FirmwareFlashing(const PlatformPtr& platform, const QString& name, const QString& firmwarePath);

    /*!
     * FirmwareFlashing destructor
     */
    ~FirmwareFlashing();

    /*!
     * Run application flashing validation.
     */
    void run();

signals:
    /*!
     * This signal is emitted when flashing validation finishes.
     */
    void finished();

    /*!
     * This signal is emitted when some warning occurs during flashing validation.
     * \param status - value from validation::Status enum
     * \param description - contains description of had happened during validation
     * \param rewriteLast - if set to true, last shown status should be rewritten by this one
     */
    void validationStatus(strata::platform::validation::Status status, QString description, bool rewriteLast = false);

private slots:
    void handleFlasherFinished(strata::Flasher::Result result, QString errorString);
    void handleflasherState(strata::Flasher::State state, bool done);
    void handleFlashProgress(int chunk, int total);
    void handleBackupProgress(int chunk, int total);

private:
    enum class Action : short {
        None,
        Flash,
        Backup
    };

    void finishValidation(bool passed);
    void flashFirmware();
    void backupFirmware();
    void compareFirmwares();
    void removeBackupFile();
    QString computeProgress(int chunk, int total);

    PlatformPtr platform_;
    std::unique_ptr<Flasher> flasher_;
    const QString name_;
    const QString firmwarePath_;
    QString tmpBackupFilePath_;
    Action currentAction_;
    bool rewriteLastStatus_;
};

}  // namespace
