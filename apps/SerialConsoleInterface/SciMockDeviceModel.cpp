/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SciMockDeviceModel.h"
#include <Mock/MockDevice.h>
#include "logging/LoggingQtCategories.h"

using strata::PlatformManager;
using strata::device::Device;
using strata::device::MockDevice;
using strata::device::scanner::DeviceScanner;
using strata::device::scanner::MockDeviceScanner;
using strata::device::scanner::MockDeviceScannerPtr;
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
    if (platforms_.empty() == false) {
        beginResetModel();

        platforms_.clear();

        endResetModel();
        emit countChanged();
    }
}

void SciMockDeviceModel::init()
{
    scanner_ = std::dynamic_pointer_cast<MockDeviceScanner>(platformManager_->getScanner(Device::Type::MockDevice));

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

QString SciMockDeviceModel::connectMockDevice(const QString& deviceName, const QByteArray& deviceId)
{
    if (scanner_ == nullptr) {
        return QString("Scanner for mock devices does not exist.");
    }

    QString errorString = scanner_->mockDeviceDetected(deviceId, deviceName, false);

    if (errorString.isEmpty()) {
        ++latestMockIdx_;
    }

    return errorString;
}

bool SciMockDeviceModel::disconnectMockDevice(const QByteArray& deviceId)
{
    if (scanner_ == nullptr) {
        return false;
    }

    return scanner_->disconnectDevice(deviceId).isEmpty();
}

void SciMockDeviceModel::disconnectAllMockDevices() {
    if (scanner_ == nullptr) {
        return;
    }

    scanner_->disconnectAllDevices();
}

QString SciMockDeviceModel::getLatestMockDeviceName() const {
    return "MOCK" + QString::number(latestMockIdx_).rightJustified(3, '0');
}

QByteArray SciMockDeviceModel::getMockDeviceId(const QString& deviceName) const {
    if (scanner_ == nullptr) {
        return QByteArray();
    }

    return scanner_->mockCreateDeviceId(deviceName);
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
