/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SciMockDevice.h"
#include <Mock/MockDeviceScanner.h>
#include "logging/LoggingQtCategories.h"

using strata::PlatformManager;
using strata::device::Device;
using strata::device::DevicePtr;
using strata::device::MockDevice;
using strata::device::MockDevicePtr;
using strata::platform::PlatformPtr;
using strata::device::MockCommand;
using strata::device::MockResponse;
using strata::device::MockVersion;

SciMockDevice::SciMockDevice(PlatformManager *platformManager):
    platformManager_(platformManager)
{
}

SciMockDevice::~SciMockDevice()
{
}

void SciMockDevice::setMockDevice(const strata::device::MockDevicePtr& mockDevice)
{
    if (mockDevice_ != mockDevice) {
        mockDevice_ = mockDevice;
        emit isValidChanged();
        emit canReopenMockDeviceChanged();
        if (mockDevice_ != nullptr) {
            emit openEnabledChanged();
            emit autoResponseChanged();
            emit mockVersionChanged();
            QList<MockCommand> commands = strata::device::MockUtils::supportedCommands(mockGetVersion());
            if ((commands.empty() == false) && (commands.contains(currentCommand_) == false)) {
                currentCommand_ = commands.first();
            }
            mockCommandModel_.updateModelData(mockGetVersion());
            mockResponseModel_.updateModelData(mockGetVersion(), currentCommand_);
            emit mockCommandChanged();
            emit mockResponseChanged();
        }
    }
}

bool SciMockDevice::reopenMockDevice()
{
    PlatformPtr platform = platformManager_->getPlatform(deviceId_, false, true);
    if (platform == nullptr) {
        qCDebug(lcSci) << "Closed Mock Device not found (probably already erased):" << deviceId_;
        return false;
    }

    if (platform->deviceType() != Device::Type::MockDevice) {
        qCWarning(lcSci) << "non-Mock device acquired, it cannot be reopen:" << deviceId_;
        return false;
    }

    auto mockScanner = std::dynamic_pointer_cast<strata::device::scanner::MockDeviceScanner>(platformManager_->getScanner(Device::Type::MockDevice));
    if (mockScanner == nullptr) {
        qCCritical(lcSci) << "Cannot get scanner for mock devices.";
        return false;
    }

    DevicePtr device = mockScanner->getMockDevice(deviceId_);
    if (device == nullptr) {
        qCCritical(lcSci) << "Invalid device pointer in platform:" << deviceId_;
        return false;
    }

    MockDevicePtr mockDevice = std::dynamic_pointer_cast<MockDevice>(device);
    if (mockDevice == nullptr) {
        qCCritical(lcSci) << "Corrupt device pointer in platform:" << deviceId_;
        return false;
    }

    if ((mockDevice->isConnected() == false) && (mockDevice->mockIsOpenEnabled() == false)) {
        mockDevice->mockSetOpenEnabled(true);
        mockDevice->open();
        qCDebug(lcSci) << "Mock Device reopened:" << deviceId_;
        emit canReopenMockDeviceChanged();
        return true;
    }

    qCWarning(lcSci) << "Mock Device in invalid state:" << deviceId_;
    return false;
}

bool SciMockDevice::canReopenMockDevice() const {
    const PlatformPtr platform = platformManager_->getPlatform(deviceId_, true, true);
    if (platform == nullptr) {
        qCDebug(lcSci) << "Mock Device not found:" << deviceId_;
        return false;
    }

    if (platform->deviceType() != Device::Type::MockDevice) {
        qCWarning(lcSci) << "non-Mock device acquired:" << deviceId_;
        return false;
    }

    auto mockScanner = std::dynamic_pointer_cast<strata::device::scanner::MockDeviceScanner>(platformManager_->getScanner(Device::Type::MockDevice));
    if (mockScanner == nullptr) {
        qCCritical(lcSci) << "Cannot get scanner for mock devices.";
        return false;
    }

    const DevicePtr device = mockScanner->getMockDevice(deviceId_);
    if (device == nullptr) {
        qCCritical(lcSci) << "Invalid device pointer in platform:" << deviceId_;
        return false;
    }

    const MockDevicePtr mockDevice = std::dynamic_pointer_cast<MockDevice>(device);
    if (mockDevice == nullptr) {
        qCCritical(lcSci) << "Corrupt device pointer in platform:" << deviceId_;
        return false;
    }

    qCDebug(lcSci) << "Mock Device is valid:" << deviceId_ << "open enabled:" << mockDevice->mockIsOpenEnabled();
    return !mockDevice->mockIsOpenEnabled();
}

SciMockCommandModel *SciMockDevice::mockCommandModel()
{
    return &mockCommandModel_;
}

SciMockResponseModel *SciMockDevice::mockResponseModel()
{
    return &mockResponseModel_;
}

SciMockVersionModel *SciMockDevice::mockVersionModel()
{
    return &mockVersionModel_;
}

bool SciMockDevice::isValid() const
{
    return (mockDevice_ != nullptr);
}

bool SciMockDevice::mockIsOpenEnabled() const
{
    if (mockDevice_ == nullptr) {
        return true;
    }

    return mockDevice_->mockIsOpenEnabled();
}

bool SciMockDevice::mockIsAutoResponse() const
{
    if (mockDevice_ == nullptr) {
        return true;
    }

    return mockDevice_->mockIsAutoResponse();
}

MockCommand SciMockDevice::mockGetCommand() const
{
    return currentCommand_;
}

MockResponse SciMockDevice::mockGetResponse() const
{
    if (mockDevice_ == nullptr) {
        return MockResponse::Normal;
    }

    return mockDevice_->mockGetResponseForCommand(currentCommand_);
}

MockVersion SciMockDevice::mockGetVersion() const
{
    if (mockDevice_ == nullptr) {
        return MockVersion::Version_1;
    }

    return mockDevice_->mockGetVersion();
}

void SciMockDevice::mockSetDeviceId(const QByteArray& deviceId)
{
    deviceId_ = deviceId;
}

void SciMockDevice::mockSetOpenEnabled(bool enabled)
{
    if (mockDevice_ != nullptr) {
        if (mockDevice_->mockSetOpenEnabled(enabled) == true) {
            emit openEnabledChanged();
        }
    }
}

void SciMockDevice::mockSetAutoResponse(bool autoResponse)
{
    if (mockDevice_ != nullptr) {
        if (mockDevice_->mockSetAutoResponse(autoResponse) == true) {
            emit autoResponseChanged();
        }
    }
}

void SciMockDevice::mockSetVersion(MockVersion version)
{
    if (mockDevice_ != nullptr) {
        if (mockDevice_->mockSetVersion(version) == true) {
            QList<MockCommand> commands = strata::device::MockUtils::supportedCommands(version);
            if ((commands.empty() == false) && (commands.contains(currentCommand_) == false)) {
                currentCommand_ = commands.first();
            }
            mockCommandModel_.updateModelData(version);
            mockResponseModel_.updateModelData(version, currentCommand_);
            emit mockVersionChanged();
            emit mockCommandChanged();  // update indexes due to model change
            emit mockResponseChanged(); // update indexes due to model change
        }
    }
}

void SciMockDevice::mockSetCommand(MockCommand command)
{
    if (currentCommand_ != command) {
        currentCommand_ = command;
        mockResponseModel_.updateModelData(mockDevice_->mockGetVersion(), currentCommand_);
        emit mockCommandChanged();
        emit mockResponseChanged(); // update indexes due to model change
    }
}

void SciMockDevice::mockSetResponse(MockResponse response)
{
    if (mockDevice_ != nullptr) {
        if (mockDevice_->mockSetResponseForCommand(response, currentCommand_) == true) {
            emit mockResponseChanged();
        }
    }
}
