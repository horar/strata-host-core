#include "SciMockDevice.h"
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
            emit legacyModeChanged();
            emit autoResponseChanged();
            emit mockCommandChanged();
            emit mockResponseChanged();
            emit mockVersionChanged();
        }
    }
}

bool SciMockDevice::reopenMockDevice()
{
    PlatformPtr platform = platformManager_->getPlatform(deviceId_, false, true);
    if (platform == nullptr) {
        qCDebug(logCategorySci) << "Closed Mock Device not found (probably already erased):" << deviceId_;
        return false;
    }

    if (platform->deviceType() != Device::Type::MockDevice) {
        qCWarning(logCategorySci) << "non-Mock device acquired, it cannot be reopen:" << deviceId_;
        return false;
    }

    DevicePtr device = platform->getDevice();
    if (device == nullptr) {
        qCCritical(logCategorySci) << "Invalid device pointer in platform:" << deviceId_;
        return false;
    }

    MockDevicePtr mockDevice = std::dynamic_pointer_cast<MockDevice>(device);
    if (mockDevice == nullptr) {
        qCCritical(logCategorySci) << "Corrupt device pointer in platform:" << deviceId_;
        return false;
    }

    if ((mockDevice->isConnected() == false) && (mockDevice->mockIsOpenEnabled() == false)) {
        mockDevice->mockSetOpenEnabled(true);
        qCDebug(logCategorySci) << "Mock Device configured to open during next interval:" << deviceId_;
        emit canReopenMockDeviceChanged();
        return true;
    }

    qCWarning(logCategorySci) << "Mock Device in invalid state:" << deviceId_;
    return false;
}

bool SciMockDevice::canReopenMockDevice() const {
    const PlatformPtr platform = platformManager_->getPlatform(deviceId_, true, true);
    if (platform == nullptr) {
        qCDebug(logCategorySci) << "Mock Device not found:" << deviceId_;
        return false;
    }

    if (platform->deviceType() != Device::Type::MockDevice) {
        qCWarning(logCategorySci) << "non-Mock device acquired:" << deviceId_;
        return false;
    }

    const DevicePtr device = platform->getDevice();
    if (device == nullptr) {
        qCCritical(logCategorySci) << "Invalid device pointer in platform:" << deviceId_;
        return false;
    }

    const MockDevicePtr mockDevice = std::dynamic_pointer_cast<MockDevice>(device);
    if (mockDevice == nullptr) {
        qCCritical(logCategorySci) << "Corrupt device pointer in platform:" << deviceId_;
        return false;
    }

    qCDebug(logCategorySci) << "Mock Device is valid:" << deviceId_ << "open enabled:" << mockDevice->mockIsOpenEnabled();
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
    if (mockDevice_ != nullptr) {
        return mockDevice_->mockIsOpenEnabled();
    } else {
        return true;
    }
}

bool SciMockDevice::mockIsLegacy() const
{
    if (mockDevice_ != nullptr) {
        return mockDevice_->mockIsLegacy();
    } else {
        return false;
    }
}

bool SciMockDevice::mockIsAutoResponse() const
{
    if (mockDevice_ != nullptr) {
        return mockDevice_->mockIsAutoResponse();
    } else {
        return true;
    }
}

MockCommand SciMockDevice::mockGetCommand() const
{
    if (mockDevice_ != nullptr) {
        return mockDevice_->mockGetCommand();
    } else {
        return MockCommand::Any_command;
    }
}

MockResponse SciMockDevice::mockGetResponse() const
{
    if (mockDevice_ != nullptr) {
        return mockDevice_->mockGetResponse();
    } else {
        return MockResponse::Normal;
    }
}

MockVersion SciMockDevice::mockGetVersion() const
{
    if (mockDevice_ != nullptr) {
        return mockDevice_->mockGetVersion();
    } else {
        return MockVersion::Version_1;
    }
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

void SciMockDevice::mockSetLegacy(bool isLegacy)
{
    if (mockDevice_ != nullptr) {
        if (mockDevice_->mockSetLegacy(isLegacy) == true) {
            emit legacyModeChanged();
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

void SciMockDevice::mockSetCommand(MockCommand command)
{
    if (mockDevice_ != nullptr) {
        if (mockDevice_->mockSetCommand(command) == true) {
            emit mockCommandChanged();
        }
    }
}

void SciMockDevice::mockSetResponse(MockResponse response)
{
    if (mockDevice_ != nullptr) {
        if (mockDevice_->mockSetResponse(response) == true) {
            emit mockResponseChanged();
        }
    }
}

void SciMockDevice::mockSetVersion(MockVersion version)
{
    if (mockDevice_ != nullptr) {
        if (mockDevice_->mockSetVersion(version) == true) {
            emit mockVersionChanged();
        }
    }
}
