/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "BleDeviceModel.h"
#include "logging/LoggingQtCategories.h"

#include <QTimer>
#include <chrono>
#include <QOperatingSystemVersion>
#include <QJsonArray>

using namespace std::literals::chrono_literals;

BleDeviceModel::BleDeviceModel(
        strata::strataRPC::StrataClient *strataClient,
        CoreInterface *coreInterface,
        QObject *parent)
    : QAbstractListModel(parent),
      strataClient_(strataClient),
      coreInterface_(coreInterface)
{
    setModelRoles();

    connect(coreInterface_, &CoreInterface::bluetoothScan, this, &BleDeviceModel::bluetoothScanFinishedHandler);
    connect(coreInterface_, &CoreInterface::connectDevice, this, &BleDeviceModel::connectReplyHandler);
    connect(coreInterface_, &CoreInterface::disconnectDevice, this, &BleDeviceModel::disconnectReplyHandler);
    connect(coreInterface_, &CoreInterface::connectedPlatformListMessage, this, &BleDeviceModel::updateDeviceConnection);
}

BleDeviceModel::~BleDeviceModel()
{
}

QVariant BleDeviceModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= data_.count()) {
        qCWarning(logCategoryStrataDevStudio) << "index out of range";
        return QVariant();
    }

    const BleDeviceModelItem &item = data_.at(row);

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

int BleDeviceModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return data_.length();
}

QString BleDeviceModel::bleSupportError() const
{
    if (QOperatingSystemVersion::currentType() == QOperatingSystemVersion::MacOS)
    {
        return "";
    }
    if (QOperatingSystemVersion::currentType() == QOperatingSystemVersion::Windows)
    {
        if (QOperatingSystemVersion::current() < QOperatingSystemVersion::Windows8)
        {
            return "Bluetooth Low Energy is not supported on this Windows version";
        }
        if (QT_VERSION < QT_VERSION_CHECK(5, 14, 0))
        {
            return "On Windows operating system, Bluetooth Low Energy requires Qt 5.14+";
        }
        return "";
    }
    return "Bluetooth Low Energy is not supported on this operating system";
}

void BleDeviceModel::startScan()
{
    strata::strataRPC::DeferredRequest *deferredRequest = strataClient_->sendRequest("bluetooth_scan", QJsonObject());

    if (deferredRequest == nullptr) {
        QString errorString = "Failed to send 'bluetooth_scan' request";
        qCCritical(logCategoryStrataDevStudio) << errorString;
        setLastScanError(errorString);
        return;
    }

    setLastScanError("");
    setInScanMode(true);

    connect(deferredRequest, &strata::strataRPC::DeferredRequest::finishedSuccessfully, this, &BleDeviceModel::bluetoothScanReplyHandler);
    connect(deferredRequest, &strata::strataRPC::DeferredRequest::finishedWithError, this, &BleDeviceModel::bluetoothScanErrorReplyHandler);
}

void BleDeviceModel::tryConnect(int row)
{
    if (row < 0 || row >= data_.count()) {
        qCWarning(logCategoryStrataDevStudio) << "index out of range";
        return;
    }

    QString deviceId = data_.at(row).deviceId;

    if (addConnectingDevice(deviceId) == false) {
        qCWarning(logCategoryStrataDevStudio) << "request already in progress" << deviceId;
        return;
    }

    setPropertyAt(row, true, ConnectionInProgressRole);
    setPropertyAt(row, "", ErrorStringRole);

    QJsonObject payload
    {
        {"device_id",  deviceId}
    };

    strataClient_->sendRequest("connect_device", payload);
}

void BleDeviceModel::tryDisconnect(int row)
{
    if (row < 0 || row >= data_.count()) {
        qCWarning(logCategoryStrataDevStudio) << "index out of range";
        return;
    }

    QString deviceId = data_.at(row).deviceId;

    if (addConnectingDevice(deviceId) == false) {
        qCWarning(logCategoryStrataDevStudio) << "request already in progress" << deviceId;
        return;
    }

    setPropertyAt(row, true, ConnectionInProgressRole);
    setPropertyAt(row, "", ErrorStringRole);

    QJsonObject payload
    {
        {"device_id",  deviceId}
    };

    strataClient_->sendRequest("disconnect_device", payload);
}

QVariantMap BleDeviceModel::get(int row)
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

bool BleDeviceModel::inScanMode() const
{
    return inScanMode_;
}

bool BleDeviceModel::isConnecting() const
{
    return (requestedIds_.isEmpty() == false);
}

QString BleDeviceModel::lastScanError() const
{
    return lastScanError_;
}

QHash<int, QByteArray> BleDeviceModel::roleNames() const
{
    return roleByEnumHash_;
}

void BleDeviceModel::bluetoothScanReplyHandler(const QJsonObject &payload)
{
    if (payload.contains("message") ) {
        qCDebug(logCategoryStrataDevStudio) << payload.value("message").toString();
    } else {
        qCWarning(logCategoryStrataDevStudio) << "Succesfully initiated Bluetooth scan, but received malformated reply";
    }
}

void BleDeviceModel::bluetoothScanErrorReplyHandler(const QJsonObject &payload)
{
    QString errorString("Unable to initiate Bluetooth scan");
    if (payload.contains("message") ) {
        errorString += ": " + payload.value("message").toString();
    }

    qCWarning(logCategoryStrataDevStudio) << errorString;

    clear();
    setInScanMode(false);
    setLastScanError(errorString);
}

void BleDeviceModel::bluetoothScanFinishedHandler(const QJsonObject &payload)
{
    setInScanMode(false);

    QString errorString;
    if (payload.contains("error_string") ) {
        errorString = payload.value("error_string").toString();
    } else if (payload.contains("list") == false) {
        errorString = "Bluetooth scan reply not valid";
    }

    if (errorString.isEmpty() == false) {
        clear();
        qCCritical(logCategoryStrataDevStudio) << errorString;
        setLastScanError(errorString);
        return;
    }

    populateModel(payload);
}

void BleDeviceModel::connectReplyHandler(const QJsonObject &payload)
{
    QString deviceId = payload.value("device_id").toString();

    if (removeConnectingDevice(deviceId) == false) {
        // not our request
        return;
    }

    int row = findDeviceIndex(deviceId);
    if (row < 0) {
        return;
    }

    setPropertyAt(row, false, ConnectionInProgressRole);

    QString errorString = payload.value("error_string").toString();
    if (errorString.isEmpty() == false) {
        qCCritical(logCategoryStrataDevStudio) << "connection attempt failed" << deviceId << errorString;
        setPropertyAt(row, errorString, ErrorStringRole);
    }

    emit tryConnectFinished(errorString);
}

void BleDeviceModel::disconnectReplyHandler(const QJsonObject &payload)
{
    QString deviceId = payload.value("device_id").toString();

    if (removeConnectingDevice(deviceId) == false) {
        // not our request
        return;
    }

    int row = findDeviceIndex(deviceId);
    if (row < 0) {
        return;
    }

    setPropertyAt(row, false, ConnectionInProgressRole);

    QString errorString = payload.value("error_string").toString();
    if (errorString.isEmpty() == false) {
        qCCritical(logCategoryStrataDevStudio) << "disconnection attempt failed" << deviceId << errorString;
        setPropertyAt(row, errorString, ErrorStringRole);
    }

    emit tryDisconnectFinished(errorString);
}

void BleDeviceModel::updateDeviceConnection(const QJsonObject &payload)
{
    QJsonArray list = payload.value("list").toArray();
    connectedDeviceIds_.clear();

    for (const QJsonValueRef value : list) {
        QString deviceId = value.toObject().value("device_id").toString();
        connectedDeviceIds_.insert(deviceId);
    }

    for (int i = 0; i < data_.length(); ++i) {
        bool isConnected = connectedDeviceIds_.contains(data_.at(i).deviceId);
        setPropertyAt(i, isConnected, IsConnectedRole);
    }
}

void BleDeviceModel::setModelRoles()
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

void BleDeviceModel::clear()
{
    beginResetModel();

    data_.clear();

    endResetModel();
}

void BleDeviceModel::populateModel(const QJsonObject &payload)
{
    QJsonArray deviceList = payload.value("list").toArray();

    beginResetModel();
    data_.clear();

    for (const QJsonValueRef value : deviceList) {
        QJsonObject device = value.toObject();

        if (device.contains("device_id") == false
                || device.contains("name") == false
                || device.contains("address") == false
                || device.contains("is_strata") == false
                || device.contains("rssi") == false)
        {
            qCCritical(logCategoryStrataDevStudio) << "bluetooth device not valid";
            continue;
        }

        BleDeviceModelItem item;
        item.deviceId = device.value("device_id").toString();
        item.name = device.value("name").toString();
        item.address = device.value("address").toString();
        item.rssi = device.value("rssi").toInt();
        item.isStrata = device.value("is_strata").toBool();
        item.isConnected = connectedDeviceIds_.contains(item.deviceId);

        data_.append(item);
    }

    endResetModel();
}

int BleDeviceModel::findDeviceIndex(const QString &deviceId)
{
    for (int i = 0; i < data_.length(); ++i) {
        if (data_.at(i).deviceId == deviceId) {
            return i;
        }
    }

    return -1;
}

void BleDeviceModel::setPropertyAt(int row, const QVariant &value, int role)
{
    if (row < 0 || row >= data_.count()) {
        qCWarning(logCategoryStrataDevStudio) << "index out of range";
        return;
    }

    BleDeviceModelItem &item = data_[row];

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

void BleDeviceModel::setInScanMode(bool inScanMode)
{
    if (inScanMode_ == inScanMode) {
        return;
    }

    inScanMode_ = inScanMode;
    emit inScanModeChanged();
}

void BleDeviceModel::setLastScanError(QString lastScanError)
{
    if (lastScanError_ == lastScanError) {
        return;
    }

    lastScanError_ = lastScanError;
    emit lastScanErrorChanged();
}

bool BleDeviceModel::addConnectingDevice(const QString &deviceId)
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

bool BleDeviceModel::removeConnectingDevice(const QString &deviceId)
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


