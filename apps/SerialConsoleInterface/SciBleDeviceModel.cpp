/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SciBleDeviceModel.h"
#include "logging/LoggingQtCategories.h"

#include <QOperatingSystemVersion>

using strata::device::Device;
using strata::device::scanner::BlootoothLowEnergyInfo;

SciBleDeviceModel::SciBleDeviceModel(
        strata::PlatformManager *platformManager,
        QObject *parent)
    : QAbstractListModel(parent),
      platformManager_(platformManager)
{
    setModelRoles();

    connect(platformManager_, &strata::PlatformManager::platformOpened,
            this, &SciBleDeviceModel::platformOpenedHandler);

    connect(platformManager_, &strata::PlatformManager::platformRemoved,
            this, &SciBleDeviceModel::platformRemovedHandler);
}

SciBleDeviceModel::~SciBleDeviceModel()
{
}

QVariant SciBleDeviceModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= data_.count()) {
        qCWarning(lcSci) << "index out of range";
        return QVariant();
    }

    const SciBleDeviceModelItem &item = data_.at(row);

    switch (role) {
    case NameRole:
        return item.name;
    case AddressRole:
        return item.address;
    case ErrorStringRole:
        return item.errorString;
    case RssiRole:
        return item.rssi;
    case IsStrataRole:
        return item.isStrata;
    case IsConnectedRole:
        return item.isConnected;
    case ConnectionInProgressRole:
        return item.connectionInProgress;
    }

    return QVariant();
}

int SciBleDeviceModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return data_.length();
}

void SciBleDeviceModel::init()
{
    scanner_ = std::static_pointer_cast<BluetoothLowEnergyScanner>(
                platformManager_->getScanner(Device::Type::BLEDevice));

    if (scanner_ == nullptr) {
        qCCritical(lcSci) << "cannot cast Bluetooth Low Energy Scanner";
        return;
    }

    connect(scanner_.get(), &BluetoothLowEnergyScanner::discoveryFinished,
            this, &SciBleDeviceModel::discoveryFinishedHandler);
}

QString SciBleDeviceModel::bleSupportError() const
{
    if (QOperatingSystemVersion::currentType() == QOperatingSystemVersion::MacOS) {
        return "";
    }

    if (QOperatingSystemVersion::currentType() == QOperatingSystemVersion::Windows) {
        if (QOperatingSystemVersion::current() < QOperatingSystemVersion::Windows8) {
            return "Bluetooth Low Energy is not supported on this Windows version";
        }

        if (QT_VERSION < QT_VERSION_CHECK(5, 14, 0)) {
            return "On Windows operating system, Bluetooth Low Energy requires Qt 5.14+";
        }

        return "";
    }

    return "Bluetooth Low Energy is not supported on this operating system";
}

void SciBleDeviceModel::startDiscovery()
{
    setLastDiscoveryError("");
    setInDiscoveryMode(true);
    scanner_->startDiscovery();
}

void SciBleDeviceModel::tryConnectDevice(int index)
{
    if (index < 0 || index >= data_.count()) {
        qCWarning(lcSci) << "index out of range";
        return;
    }

    QByteArray deviceId = data_.at(index).deviceId;

    if (addConnectingDevice(deviceId) == false) {
        qCWarning(lcSci) << "request already in progress" << deviceId;
        return;
    }

    setPropertyAt(index, true, ConnectionInProgressRole);
    setPropertyAt(index, QString(), ErrorStringRole);

    QString err = scanner_->connectDevice(deviceId);

    if (err.isEmpty() == false) {
        setPropertyAt(index, err, ErrorStringRole);
    }
}

void SciBleDeviceModel::tryDisconnectDevice(int index)
{
    if (index < 0 || index >= data_.count()) {
        qCWarning(lcSci) << "index out of range";
        return;
    }

    QByteArray deviceId = data_.at(index).deviceId;

    if (addConnectingDevice(deviceId) == false) {
        qCWarning(lcSci) << "request already in progress" << deviceId;
        return;
    }

    setPropertyAt(index, true, ConnectionInProgressRole);
    setPropertyAt(index, QString(), ErrorStringRole);

    QString err = scanner_->disconnectDevice(deviceId);

    if (err.isEmpty() == false) {
        setPropertyAt(index, err, ErrorStringRole);
    }
}

QVariantMap SciBleDeviceModel::get(int row)
{
    QHashIterator<int, QByteArray> iter(roleByEnumHash_);
    QVariantMap res;
    while (iter.hasNext()) {
        iter.next();
        QModelIndex idx = index(row, 0);
        QVariant data = idx.data(iter.key());
        res[iter.value()] = data;
    }
    return res;
}

bool SciBleDeviceModel::inDiscoveryMode() const
{
    return inDiscoveryMode_;
}

bool SciBleDeviceModel::isConnecting() const
{
    return (requestedIds_.isEmpty() == false);
}

QString SciBleDeviceModel::lastDiscoveryError() const
{
    return lastDiscoveryError_;
}

QHash<int, QByteArray> SciBleDeviceModel::roleNames() const
{
    return roleByEnumHash_;
}

void SciBleDeviceModel::discoveryFinishedHandler(
        BluetoothLowEnergyScanner::DiscoveryFinishStatus status,
        QString errorString)
{
    QString effectiveErrorString;
    if (status == BluetoothLowEnergyScanner::DiscoveryFinishStatus::Finished) {
        populateModel();
    } else if (status == BluetoothLowEnergyScanner::DiscoveryFinishStatus::Cancelled) {
        clearModel();
        effectiveErrorString = "Discovery cancelled.";
    } else if (status == BluetoothLowEnergyScanner::DiscoveryFinishStatus::DiscoveryError) {
        clearModel();
        effectiveErrorString = errorString;
    }

    setInDiscoveryMode(false);
    setLastDiscoveryError(effectiveErrorString);
}

void SciBleDeviceModel::platformOpenedHandler(const QByteArray deviceId)
{
    int row = findDeviceIndex(deviceId);
    if (row >= 0) {
        setPropertyAt(row, false, ConnectionInProgressRole);
        setPropertyAt(row, true, IsConnectedRole);
        setPropertyAt(row, QString(), ErrorStringRole);
    }

    connectedDeviceIds_.insert(deviceId);

    removeConnectingDevice(deviceId);
}

void SciBleDeviceModel::platformRemovedHandler(const QByteArray deviceId, const QString errorString)
{
    int row = findDeviceIndex(deviceId);
    if (row >= 0) {
        setPropertyAt(row, false, ConnectionInProgressRole);
        setPropertyAt(row, false, IsConnectedRole);
        setPropertyAt(row, errorString, ErrorStringRole);
    }

    if (connectedDeviceIds_.contains(deviceId)) {
        connectedDeviceIds_.remove(deviceId);
    }

    removeConnectingDevice(deviceId);
}

void SciBleDeviceModel::populateModel()
{
    const QList<BlootoothLowEnergyInfo> infoList = scanner_->discoveredBleDevices();

    beginResetModel();

    data_.clear();

    for (const auto &info : infoList) {
        SciBleDeviceModelItem item;

        item.deviceId = info.deviceId;
        item.name = info.name;
        item.address = info.address;
        item.rssi = info.rssi;
        item.manufacturerIds = info.manufacturerIds;
        item.isStrata = info.isStrata;
        item.isConnected = connectedDeviceIds_.contains(item.deviceId);
        item.connectionInProgress = false;

        data_.append(item);
    }

    endResetModel();
}

void SciBleDeviceModel::clearModel()
{
    beginResetModel();
    data_.clear();
    endResetModel();
}

void SciBleDeviceModel::setModelRoles()
{
    roleByEnumHash_.clear();
    roleByEnumHash_[NameRole] = "name";
    roleByEnumHash_[AddressRole] = "address";
    roleByEnumHash_[ErrorStringRole] = "errorString";
    roleByEnumHash_[RssiRole] = "rssi";
    roleByEnumHash_[IsStrataRole] = "isStrata";
    roleByEnumHash_[IsConnectedRole] = "isConnected";
    roleByEnumHash_[ConnectionInProgressRole] = "connectionInProgress";
}

int SciBleDeviceModel::findDeviceIndex(const QString &deviceId)
{
    for (int i = 0; i < data_.length(); ++i) {
        if (data_.at(i).deviceId == deviceId) {
            return i;
        }
    }

    return -1;
}

void SciBleDeviceModel::setPropertyAt(int row, const QVariant &value, int role)
{
    if (row < 0 || row >= data_.count()) {
        qCWarning(lcSci) << "index out of range";
        return;
    }

    SciBleDeviceModelItem &item = data_[row];

    switch (role) {
    case NameRole:
        if (item.name == value) {
            return;
        }
        item.name = value.toString();
        break;
    case AddressRole:
        if (item.address == value) {
            return;
        }
        item.address = value.toString();
        break;
    case ErrorStringRole:
        if (item.errorString == value) {
            return;
        }
        item.errorString = value.toString();
        break;
    case RssiRole:
        if (item.rssi == value) {
            return;
        }
        item.rssi = value.toInt();
        break;
    case IsStrataRole:
        if (item.isStrata == value) {
            return;
        }
        item.isStrata = value.toBool();
        break;
    case IsConnectedRole:
        if (item.isConnected == value) {
            return;
        }
        item.isConnected = value.toBool();
        break;
    case ConnectionInProgressRole:
        if (item.connectionInProgress == value) {
            return;
        }
        item.connectionInProgress = value.toBool();
        break;
    }

    emit dataChanged(
                createIndex(row, 0),
                createIndex(row, 0),
                {role});
}

void SciBleDeviceModel::setInDiscoveryMode(bool inDiscoveryMode)
{
    if (inDiscoveryMode_ == inDiscoveryMode) {
        return;
    }

    inDiscoveryMode_ = inDiscoveryMode;
    emit inDiscoveryModeChanged();
}

void SciBleDeviceModel::setLastDiscoveryError(QString lastDiscoveryError)
{
    if (lastDiscoveryError_ == lastDiscoveryError) {
        return;
    }

    lastDiscoveryError_ = lastDiscoveryError;
    emit lastDiscoveryErrorChanged();
}

bool SciBleDeviceModel::addConnectingDevice(const QByteArray &deviceId)
{
    if (requestedIds_.contains(deviceId)) {
        return false;
    }

    requestedIds_.insert(deviceId);

    if (requestedIds_.size() == 1) {
        emit isConnectingChanged();
    }
    return true;
}

bool SciBleDeviceModel::removeConnectingDevice(const QByteArray &deviceId)
{
    if (requestedIds_.contains(deviceId) == false) {
        return false;
    }

    requestedIds_.remove(deviceId);

    if (requestedIds_.isEmpty()) {
        emit isConnectingChanged();
    }
    return true;
}
