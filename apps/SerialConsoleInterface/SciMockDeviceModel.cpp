#include "SciMockDeviceModel.h"
#include <Mock/MockDevice.h>
#include <Mock/MockDeviceScanner.h>
#include "logging/LoggingQtCategories.h"

using strata::PlatformManager;
using strata::device::Device;
using strata::device::DevicePtr;
using strata::device::MockDevice;
using strata::device::MockDevicePtr;
using strata::device::scanner::DeviceScanner;
using strata::device::scanner::MockDeviceScanner;
using strata::platform::Platform;
using strata::platform::PlatformPtr;

SciMockDeviceModel::SciMockDeviceModel(PlatformManager *platformManager):
    platformManager_(platformManager)
{ }

SciMockDeviceModel::~SciMockDeviceModel()
{
    clear();
}

void SciMockDeviceModel::clear()
{
    beginResetModel();

    platforms_.clear();

    endResetModel();
    emit countChanged();
}

void SciMockDeviceModel::init()
{
    scanner_ = platformManager_->getScanner(Device::Type::MockDevice);

    if (scanner_ == nullptr) {
        qCCritical(logCategorySci) << "Received empty Mock Scanner pointer:" << scanner_.get();
        return;
    }

    connect(scanner_.get(), &DeviceScanner::deviceDetected, this, &SciMockDeviceModel::handleDeviceDetected);
    connect(scanner_.get(), &DeviceScanner::deviceLost, this, &SciMockDeviceModel::handleDeviceLost);
}

void SciMockDeviceModel::handleDeviceDetected(PlatformPtr platform) {
    if (platform == nullptr) {
        qCCritical(logCategorySci) << "Received corrupt platform pointer:" << platform;
        return;
    }

    beginInsertRows(QModelIndex(), platforms_.length(), platforms_.length());
    platforms_.append({platform->deviceId(), platform->deviceName()});
    endInsertRows();

    qCDebug(logCategorySci) << "Added new mock device to the model:" << platform->deviceId();
    emit countChanged();
}

void SciMockDeviceModel::handleDeviceLost(QByteArray deviceId) {
    for (int index = 0; index < platforms_.count(); ++index) {
        if (platforms_[index].deviceId_ == deviceId) {
            beginRemoveRows(QModelIndex(), index, index);
            platforms_.removeAt(index);
            endRemoveRows();

            qCDebug(logCategorySci) << "Removed mock device from the model:" << deviceId;
            emit countChanged();
            return;
        }
    }

    qCDebug(logCategorySci) << "Device not present in the mock model:" << deviceId;
}

bool SciMockDeviceModel::connectMockDevice(const QString& deviceName, const QByteArray& deviceId)
{
    if (scanner_ == nullptr) {
        return false;
    }

    if (static_cast<MockDeviceScanner*>(scanner_.get())->
            mockDeviceDetected(deviceId, deviceName, false) == true) {
        ++latestMockIdx_;
        return true;
    }

    return false;
}

bool SciMockDeviceModel::disconnectMockDevice(const QByteArray& deviceId)
{
    if (scanner_ == nullptr) {
        return false;
    }

    return static_cast<MockDeviceScanner*>(scanner_.get())->mockDeviceLost(deviceId);
}

void SciMockDeviceModel::disconnectAllMockDevices() {
    if (scanner_ == nullptr) {
        return;
    }

    return static_cast<MockDeviceScanner*>(scanner_.get())->mockAllDevicesLost();
}

bool SciMockDeviceModel::reopenMockDevice(const QByteArray& deviceId)
{
    PlatformPtr platform = platformManager_->getPlatform(deviceId, false, true);
    if (platform == nullptr) {
        qCDebug(logCategorySci) << "Closed Mock Device not found (probably already erased):" << deviceId;
        return false;
    }

    if (platform->deviceType() != strata::device::Device::Type::MockDevice) {
        qCWarning(logCategorySci) << "non-Mock device acquired, it cannot be reopen:" << deviceId;
        return false;
    }

    DevicePtr device = platform->getDevice();
    if (device == nullptr) {
        qCCritical(logCategorySci) << "Invalid device pointer in platform:" << deviceId;
        return false;
    }

    MockDevicePtr mockDevice = std::dynamic_pointer_cast<MockDevice>(device);
    if (mockDevice == nullptr) {
        qCCritical(logCategorySci) << "Corrupt device pointer in platform:" << deviceId;
        return false;
    }

    if ((mockDevice->isConnected() == false) && (mockDevice->mockIsOpenEnabled() == false)) {
        mockDevice->mockSetOpenEnabled(true);
        qCDebug(logCategorySci) << "Mock Device configured to open during next interval:" << deviceId;
        return true;
    }

    qCWarning(logCategorySci) << "Mock Device in invalid state:" << deviceId;
    return false;
}

bool SciMockDeviceModel::canReopenMockDevice(const QByteArray& deviceId) const {
    const PlatformPtr platform = platformManager_->getPlatform(deviceId, true, true);
    if (platform == nullptr) {
        qCDebug(logCategorySci) << "Mock Device not found:" << deviceId;
        return false;
    }

    if (platform->deviceType() != strata::device::Device::Type::MockDevice) {
        qCWarning(logCategorySci) << "non-Mock device acquired:" << deviceId;
        return false;
    }

    const DevicePtr device = platform->getDevice();
    if (device == nullptr) {
        qCCritical(logCategorySci) << "Invalid device pointer in platform:" << deviceId;
        return false;
    }

    const MockDevicePtr mockDevice = std::dynamic_pointer_cast<MockDevice>(device);
    if (mockDevice == nullptr) {
        qCCritical(logCategorySci) << "Corrupt device pointer in platform:" << deviceId;
        return false;
    }

    qCDebug(logCategorySci) << "Mock Device is valid:" << deviceId << "open enabled:" << mockDevice->mockIsOpenEnabled();
    return !mockDevice->mockIsOpenEnabled();
}

QString SciMockDeviceModel::getLatestMockDeviceName() const {
    return "MOCK" + QString::number(latestMockIdx_).rightJustified(3, '0');
}

QByteArray SciMockDeviceModel::getMockDeviceId(const QString& deviceName) const {
    return MockDevice::createDeviceId(deviceName);
}

QVariant SciMockDeviceModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= platforms_.count()) {
        qCWarning(logCategorySci) << "Attempting to access out of range index when acquiring data";
        return QVariant();
    }

    switch (role) {
    case DeviceIdRole:
        return platforms_.at(row).deviceId_;
    case DeviceNameRole:
        return platforms_.at(row).deviceName_;
    }

    return QVariant();
}

int SciMockDeviceModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return platforms_.length();
}

int SciMockDeviceModel::count() const
{
    return platforms_.length();
}

QHash<int, QByteArray> SciMockDeviceModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[DeviceIdRole] = "deviceId";
    roles[DeviceNameRole] = "deviceName";

    return roles;
}
