/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#include "InfoCommand.h"

#include "logging/LoggingQtCategories.h"

#include <Operations/Identify.h>
#include <Platform.h>

namespace strata::flashercli::commands
{
InfoCommand::InfoCommand(int deviceNumber) : DeviceCommand(deviceNumber)
{
    connect(this, &DeviceCommand::criticalDeviceError, this, &InfoCommand::handleCriticalDeviceError);
}

// Destructor must be defined due to unique pointer to incomplete type.
InfoCommand::~InfoCommand()
{
}

void InfoCommand::process()
{
    if (createSerialDevice() == false) {
        emit finished(EXIT_FAILURE);
        return;
    }

    platform_->open();
}

void InfoCommand::handlePlatformOpened()
{
    identifyOperation_ = std::make_unique<platform::operation::Identify>(platform_, false);

    connect(identifyOperation_.get(), &platform::operation::BasePlatformOperation::finished, this,
            &InfoCommand::handleIdentifyOperationFinished);

    identifyOperation_->run();
}

void InfoCommand::handleIdentifyOperationFinished(platform::operation::Result result, int status, QString errStr)
{
    Q_UNUSED(status)

    platform::operation::Identify *identifyOp = qobject_cast<platform::operation::Identify *>(QObject::sender());
    if ((identifyOp == nullptr) || (identifyOp != identifyOperation_.get())) {
        qCCritical(lcFlasherCli) << "Received corrupt operation pointer:" << identifyOp;
        emit finished(EXIT_FAILURE);
        return;
    }

    switch (result) {
        case platform::operation::Result::Success: {
            QString message(QStringLiteral("List of available parameters for board:"));

            message.append(QStringLiteral("\nApplication Name: "));
            message.append(platform_->name());
            message.append(QStringLiteral("\nDevice Name: "));
            message.append(platform_->deviceName());
            message.append(QStringLiteral("\nDevice Id: "));
            message.append(platform_->deviceId());
            message.append(QStringLiteral("\nDevice Type: "));
            message.append(QVariant::fromValue(platform_->deviceType()).toString());
            message.append(QStringLiteral("\nController Type: "));
            message.append(QVariant::fromValue(platform_->controllerType()).toString());
            if (platform_->controllerType() == platform::Platform::ControllerType::Assisted) {
                message.append(QStringLiteral(" (Platform Connected: "));
                message.append(QVariant(platform_->isControllerConnectedToPlatform()).toString());
                message.append(QStringLiteral(")"));
            }
            message.append(QStringLiteral("\nBoard Mode: "));
            message.append(QVariant::fromValue(identifyOp->boardMode()).toString());
            message.append(QStringLiteral(" (API: "));
            message.append(QVariant::fromValue(platform_->apiVersion()).toString());
            message.append(QStringLiteral(")\nApplication version: "));
            message.append(platform_->applicationVer());
            message.append(QStringLiteral("\nBootloader version: "));
            message.append(platform_->bootloaderVer());
            message.append(QStringLiteral("\nPlatform Id: "));
            message.append(platform_->platformId());
            message.append(QStringLiteral("\nClass Id: "));
            message.append(platform_->classId());
            message.append(QStringLiteral("\nController Platform Id: "));
            message.append(platform_->controllerPlatformId());
            message.append(QStringLiteral("\nController Class Id: "));
            message.append(platform_->controllerClassId());
            message.append(QStringLiteral("\nFirmware Class Id: "));
            message.append(platform_->firmwareClassId());

            qCInfo(lcFlasherCli).noquote() << message;
            emit finished(EXIT_SUCCESS);
        } break;
        default: {
            qCWarning(lcFlasherCli) << "Identify operation failed:" << errStr;
            emit finished(EXIT_FAILURE);
        } break;
    }
}

void InfoCommand::handleCriticalDeviceError()
{
    // Commands in identify operation reacts on Device errors, so handle them only if this operation is not created yet
    if (identifyOperation_ == nullptr) {
        emit finished(EXIT_FAILURE);
    }
}

}  // namespace strata::flashercli::commands
