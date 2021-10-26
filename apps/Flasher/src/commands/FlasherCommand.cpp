/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#include "FlasherCommand.h"

#include <Flasher.h>

using strata::Flasher;

namespace strata::flashercli::commands
{

FlasherCommand::FlasherCommand(const QString &fileName, int deviceNumber, CmdType command)
    : DeviceCommand(deviceNumber), fileName_(fileName), command_(command)
{
    connect(this, &DeviceCommand::criticalDeviceError, this, &FlasherCommand::handleCriticalDeviceError);
}

// Destructor must be defined due to unique pointer to incomplete type.
FlasherCommand::~FlasherCommand()
{
}

void FlasherCommand::process()
{
    if (createSerialDevice() == false) {
        emit finished(EXIT_FAILURE);
        return;
    }

    platform_->open();
}

void FlasherCommand::handlePlatformOpened()
{
    flasher_ = std::make_unique<Flasher>(platform_, fileName_);

    connect(flasher_.get(), &Flasher::finished, this, [=](Flasher::Result result, QString) {
        emit this->finished((result == Flasher::Result::Ok) ? EXIT_SUCCESS : EXIT_FAILURE);
    });

    switch (command_) {
        case CmdType::FlashFirmware:
            flasher_->flashFirmware(Flasher::FinalAction::StartApplication);
            break;
        case CmdType::FlashBootloader:
            flasher_->flashBootloader();
            break;
        case CmdType::BackupFirmware:
            flasher_->backupFirmware(Flasher::FinalAction::PreservePlatformState);
            break;
    }
}

void FlasherCommand::handleCriticalDeviceError()
{
    // Commands in flasher reacts on Device errors, so handle them only if flasher is not created yet
    if (flasher_ == nullptr) {
        emit finished(EXIT_FAILURE);
    }
}

}  // namespace strata::flashercli::commands
