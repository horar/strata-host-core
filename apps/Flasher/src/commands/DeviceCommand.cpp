/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#include "DeviceCommand.h"
#include "SerialPortList.h"

#include "logging/LoggingQtCategories.h"

#include <Serial/SerialDevice.h>

namespace strata::flashercli::commands
{
constexpr int OPEN_MAX_RETRIES(4);

using device::SerialDevice;

DeviceCommand::DeviceCommand(int deviceNumber) : deviceNumber_(deviceNumber), openCount_(0)
{
}

// Destructor must be defined due to unique pointer to incomplete type.
DeviceCommand::~DeviceCommand()
{
}

bool DeviceCommand::createSerialDevice()
{
    flashercli::SerialPortList serialPorts;

    if (serialPorts.count() == 0) {
        qCCritical(logCategoryFlasherCli) << "No board is connected.";
        return false;
    }

    const QString name = serialPorts.name(deviceNumber_ - 1);
    if (name.isEmpty()) {
        qCCritical(logCategoryFlasherCli) << "Board number" << deviceNumber_ << "is not available.";
        return false;
    }

    const QByteArray deviceId =
        SerialDevice::createUniqueHash(name);  // no scanner prefix in deviceId, because there is no scanner
    device::DevicePtr device = std::make_shared<SerialDevice>(deviceId, name, OPEN_MAX_RETRIES);
    platform_ = std::make_shared<platform::Platform>(device);

    connect(platform_.get(), &platform::Platform::opened, this, &DeviceCommand::handlePlatformOpened);
    connect(platform_.get(), &platform::Platform::deviceError, this, &DeviceCommand::handleDeviceError);

    return true;
}

void DeviceCommand::handleDeviceError(device::Device::ErrorCode errCode, QString errStr)
{
    switch (errCode) {
        case device::Device::ErrorCode::NoError:
            break;
        case device::Device::ErrorCode::DeviceFailedToOpen:
        case device::Device::ErrorCode::DeviceFailedToOpenGoingToRetry: {
            ++openCount_;
            QString errorMessage(QStringLiteral("Cannot open board (serial device) "));
            errorMessage.append(platform_->deviceName());
            errorMessage.append(QStringLiteral(", attempt "));
            errorMessage.append(QString::number(openCount_));
            errorMessage.append(QStringLiteral(" of "));
            errorMessage.append(QString::number(OPEN_MAX_RETRIES + 1));

            if (errCode == device::Device::ErrorCode::DeviceFailedToOpen) {
                qCCritical(logCategoryFlasherCli).noquote() << errorMessage;
                emit finished(EXIT_FAILURE);
            } else {
                qCInfo(logCategoryFlasherCli).noquote() << errorMessage;
            }
        } break;
        case device::Device::ErrorCode::DeviceDisconnected:
        case device::Device::ErrorCode::DeviceError:
            qCCritical(logCategoryFlasherCli).noquote() << QStringLiteral("Device error:") << errStr;
            emit criticalDeviceError();
            break;
    }
}

}  // namespace strata::flashercli::commands
