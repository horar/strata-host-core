#include "SciMockDeviceModel.h"
#include <Mock/MockDevice.h>
#include <Mock/MockDeviceScanner.h>
#include "logging/LoggingQtCategories.h"

using strata::PlatformManager;
using strata::device::Device;
using strata::device::DevicePtr;
using strata::device::MockDevice;
using strata::device::scanner::DeviceScanner;
using strata::device::scanner::MockDeviceScanner;
using strata::platform::Platform;
using strata::platform::PlatformPtr;

SciMockDeviceModel::SciMockDeviceModel(PlatformManager *platformManager):
    platformManager_(platformManager)
{ }

SciMockDeviceModel::~SciMockDeviceModel()
{
    platforms_.clear();
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
    platforms_.append(platform);
    endInsertRows();

    qCDebug(logCategorySci) << "Added new mock device to the model:" << platform->deviceId();
    emit countChanged();
}

void SciMockDeviceModel::handleDeviceLost(QByteArray deviceId) {
    for (int index = 0; index < platforms_.count(); ++index) {
        if (platforms_[index]->deviceId() == deviceId) {
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

bool SciMockDeviceModel::connectMockDevice(QString deviceName, QByteArray deviceId)
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

bool SciMockDeviceModel::disconnectMockDevice(QByteArray deviceId)
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

QString SciMockDeviceModel::getLatestMockDeviceName() const {
    return "MOCK" + QString::number(latestMockIdx_).rightJustified(3, '0');
}

QByteArray SciMockDeviceModel::getMockDeviceId(QString deviceName) const {
    return MockDevice::createDeviceId(deviceName);
}

QVariant SciMockDeviceModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= platforms_.count()) {
        qCWarning(logCategorySci) << "Trying to access to out of range index when acquiring data";
        return QVariant();
    }

    const DevicePtr device = platforms_.at(row)->getDevice();
    const auto mockDevice = std::dynamic_pointer_cast<MockDevice>(device);
    if (mockDevice == nullptr) {
        qCCritical(logCategorySci) << "Invalid pointer when acquiring data";
        return QVariant();
    }

    switch (role) {
    case DeviceIdRole:
        return mockDevice->deviceId();
    case DeviceNameRole:
        return mockDevice->deviceName();
    case OpenEnabledRole:
        return mockDevice->mockIsOpenEnabled();
    case LegacyModeRole:
        return mockDevice->mockIsLegacy();
    case AutoResponseRole:
        return mockDevice->mockIsAutoResponse();
    case MockCommandRole:
        return static_cast<int>(mockDevice->mockGetCommand());
    case MockResponseRole:
        return static_cast<int>(mockDevice->mockGetResponse());
    }

    return QVariant();
}

bool SciMockDeviceModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    int row = index.row();
    if (row < 0 || row >= platforms_.count()) {
        qCWarning(logCategorySci) << "Trying to access to out of range index when setting data";
        return false;
    }

    DevicePtr device = platforms_.at(row)->getDevice();
    auto mockDevice = std::dynamic_pointer_cast<MockDevice>(device);
    if (mockDevice == nullptr) {
        qCCritical(logCategorySci) << "Invalid pointer when setting data";
        return false;
    }
    bool success = false;

    switch (role) {
    case OpenEnabledRole:
        success = mockDevice->mockSetOpenEnabled(value.toBool());
        qCDebug(logCategorySci) << "Set open enabled to:" << mockDevice->mockIsOpenEnabled();
        break;
    case LegacyModeRole:
        success = mockDevice->mockSetLegacy(value.toBool());
        qCDebug(logCategorySci) << "Set legacy mode to:" << mockDevice->mockIsLegacy();
        break;
    case AutoResponseRole:
        success = mockDevice->mockSetAutoResponse(value.toBool());
        qCDebug(logCategorySci) << "Set auto response to:" << mockDevice->mockIsAutoResponse();
        break;
    case MockCommandRole:
        success = mockDevice->mockSetCommand(value.value<strata::device::MockCommand>());
        qCDebug(logCategorySci) << "Set mock command to:" << mockDevice->mockGetCommand();
        break;
    case MockResponseRole:
        success = mockDevice->mockSetResponse(value.value<strata::device::MockResponse>());
        qCDebug(logCategorySci) << "Set mock response to:" << mockDevice->mockGetResponse();
        break;
    }

    if (success) {
        emit dataChanged(index, index, {role});
        return true;
    }
    return false;
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
    roles[OpenEnabledRole] = "openEnabled";
    roles[LegacyModeRole] = "legacyMode";
    roles[AutoResponseRole] = "autoResponse";
    roles[MockCommandRole] = "mockCommand";
    roles[MockResponseRole] = "mockResponse";

    return roles;
}
