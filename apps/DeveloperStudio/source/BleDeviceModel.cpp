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
    connect(coreInterface_, &CoreInterface::connectDevice, this, &BleDeviceModel::connectFinishedHandler);
    connect(coreInterface_, &CoreInterface::disconnectDevice, this, &BleDeviceModel::disconnectFinishedHandler);
    connect(coreInterface_, &CoreInterface::connectedPlatformListMessage, this, &BleDeviceModel::updateDeviceConnection);
}

BleDeviceModel::~BleDeviceModel()
{
}

QVariant BleDeviceModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= data_.count()) {
        qCWarning(lcDevStudio) << "index out of range";
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

void BleDeviceModel::startScan()
{
    setInScanMode(true);
    setLastScanError("");

    strata::strataRPC::DeferredRequest *deferredRequest = strataClient_->sendRequest("bluetooth_scan", QJsonObject());

    if (deferredRequest == nullptr) {
        finishScan("Failed to send 'bluetooth_scan' request");
        return;
    }

    connect(deferredRequest, &strata::strataRPC::DeferredRequest::finishedSuccessfully, this, &BleDeviceModel::bluetoothScanReplyHandler);
    connect(deferredRequest, &strata::strataRPC::DeferredRequest::finishedWithError, this, &BleDeviceModel::bluetoothScanErrorReplyHandler);
}

void BleDeviceModel::finishScan(const QString& errorString)
{
    qCCritical(lcDevStudio) << errorString;
    clear();    // clear the model if it had any previous data
    setLastScanError(errorString);
    setInScanMode(false);
}

void BleDeviceModel::tryConnect(int row)
{
    if (row < 0 || row >= data_.count()) {
        qCWarning(lcDevStudio) << "index out of range";
        return;
    }

    QString deviceId = data_.at(row).deviceId;

    if (addConnectingDevice(deviceId) == false) {
        qCWarning(lcDevStudio).noquote() << "request already in progress, device ID:" << deviceId;
        return;
    }

    setPropertyAt(row, true, ConnectionInProgressRole);
    setPropertyAt(row, "", ErrorStringRole);

    QJsonObject payload
    {
        {"device_id",  deviceId}
    };

    strata::strataRPC::DeferredRequest *deferredRequest = strataClient_->sendRequest("connect_device", payload);

    if (deferredRequest == nullptr) {
        finishConnection(row, "Failed to send 'connect_device' request");
        return;
    }

    connect(deferredRequest, &strata::strataRPC::DeferredRequest::finishedSuccessfully, this, [this, deviceId] (const QJsonObject &payload) {
        connectReplyHandler(deviceId, payload);
    });

    connect(deferredRequest, &strata::strataRPC::DeferredRequest::finishedWithError, this, [this, deviceId] (const QJsonObject &payload) {
        connectErrorReplyHandler(deviceId, payload);
    });
}

void BleDeviceModel::tryDisconnect(int row)
{
    if (row < 0 || row >= data_.count()) {
        qCWarning(lcDevStudio) << "index out of range";
        return;
    }

    QString deviceId = data_.at(row).deviceId;

    if (addConnectingDevice(deviceId) == false) {
        qCWarning(lcDevStudio).noquote() << "request already in progress, device ID:" << deviceId;
        return;
    }

    setPropertyAt(row, true, ConnectionInProgressRole);
    setPropertyAt(row, "", ErrorStringRole);

    QJsonObject payload
    {
        {"device_id",  deviceId}
    };

    strata::strataRPC::DeferredRequest *deferredRequest = strataClient_->sendRequest("disconnect_device", payload);

    if (deferredRequest == nullptr) {
        finishConnection(row, "Failed to send 'disconnect_device' request");
        return;
    }

    connect(deferredRequest, &strata::strataRPC::DeferredRequest::finishedSuccessfully, this, [this, deviceId] (const QJsonObject &payload) {
        disconnectReplyHandler(deviceId, payload);
    });

    connect(deferredRequest, &strata::strataRPC::DeferredRequest::finishedWithError, this, [this, deviceId] (const QJsonObject &payload) {
        disconnectErrorReplyHandler(deviceId, payload);
    });
}

void BleDeviceModel::finishConnection(int row, const QString& errorString)
{
    qCCritical(lcDevStudio) << errorString;
    setPropertyAt(row, errorString, ErrorStringRole);
    setPropertyAt(row, false, ConnectionInProgressRole);
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
    const QJsonValue message = payload.value("message");
    if (message.isString()) {
        qCDebug(lcDevStudio) << message.toString();
    } else {
        qCWarning(lcDevStudio) << "Succesfully initiated Bluetooth scan, but received malformated reply:" << payload;
    }
}

void BleDeviceModel::bluetoothScanErrorReplyHandler(const QJsonObject &payload)
{
    QString errorString("Unable to initiate Bluetooth scan");
    const QJsonValue message = payload.value("message");
    if (message.isString()) {
        errorString += ": " + message.toString();
    } else {
        qCWarning(lcDevStudio) << "received malformated reply:" << payload;
    }

    finishScan(errorString);
}

void BleDeviceModel::bluetoothScanFinishedHandler(const QJsonObject &payload)
{
    QString errorString;
    const QJsonValue errorStringValue = payload.value("error_string");
    if (errorStringValue.isString()) {
        errorString = errorStringValue.toString();
    } else if (payload.contains("list") == false) {
        errorString = "Bluetooth scan reply not valid";
    }

    if (errorString.isEmpty() == false) {
        finishScan(errorString);
        return;
    }

    populateModel(payload);
    setInScanMode(false);
}

void BleDeviceModel::connectReplyHandler(const QString& deviceId, const QJsonObject &payload)
{
    const QJsonValue message = payload.value("message");
    if (message.isString()) {
        qCDebug(lcDevStudio).noquote().nospace() << message.toString() << ", for device ID: " << deviceId;
    } else {
        qCWarning(lcDevStudio).noquote().nospace() << "Succesfully initiated connection to device ID: " << deviceId << ", but received malformated reply";
    }
}

void BleDeviceModel::connectErrorReplyHandler(const QString& deviceId, const QJsonObject &payload)
{
    QJsonObject payloadData;
    payloadData.insert("device_id", deviceId);

    const QJsonValue message = payload.value("message");
    if (message.isString()) {
        payloadData.insert("error_string", message);
    } else {
        qCWarning(lcDevStudio) << "received malformated reply:" << payload;
        payloadData.insert("error_string", "unable to initiate connection");
    }

    connectFinishedHandler(payloadData);
}

void BleDeviceModel::connectFinishedHandler(const QJsonObject &payload)
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

    QString errorString;
    const QJsonValue errorStringValue = payload.value("error_string");
    if (errorStringValue.isString()) {
        errorString = errorStringValue.toString();
    }

    if (errorString.isEmpty() == false) {
        qCCritical(lcDevStudio).noquote().nospace() << "connection attempt failed, device ID: " << deviceId << ", error: " << errorString;
        setPropertyAt(row, errorString, ErrorStringRole);
    }

    emit tryConnectFinished(errorString);
}

void BleDeviceModel::disconnectReplyHandler(const QString& deviceId, const QJsonObject &payload)
{
    const QJsonValue message = payload.value("message");
    if (message.isString()) {
        qCDebug(lcDevStudio).noquote().nospace() << message.toString() << ", for device ID: " << deviceId;
    } else {
        qCWarning(lcDevStudio).noquote().nospace() << "Succesfully initiated disconnection to device ID: " << deviceId << ", but received malformated reply";
    }
}

void BleDeviceModel::disconnectErrorReplyHandler(const QString& deviceId, const QJsonObject &payload)
{
    QJsonObject payloadData;
    payloadData.insert("device_id", deviceId);

    const QJsonValue message = payload.value("message");
    if (message.isString()) {
        payloadData.insert("error_string", message);
    } else {
        qCWarning(lcDevStudio) << "received malformated reply:" << payload;
        payloadData.insert("error_string", "unable to initiate disconnection");
    }

    disconnectFinishedHandler(payloadData);
}

void BleDeviceModel::disconnectFinishedHandler(const QJsonObject &payload)
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

    QString errorString;
    const QJsonValue errorStringValue = payload.value("error_string");
    if (errorStringValue.isString()) {
        errorString = errorStringValue.toString();
    }

    if (errorString.isEmpty() == false) {
        qCCritical(lcDevStudio).noquote().nospace() << "disconnection attempt failed, device ID: " << deviceId << ", error: " << errorString;
        setPropertyAt(row, errorString, ErrorStringRole);
    }

    emit tryDisconnectFinished(errorString);
}

void BleDeviceModel::updateDeviceConnection(const QJsonObject &payload)
{
    const QJsonValue listValue = payload.value("list");
    if (listValue.isArray() == false) {
        qCCritical(lcDevStudio) << "malformatted payload received, missing list:" << payload;
        return;
    }

    QJsonArray list = listValue.toArray();
    connectedDeviceIds_.clear();

    for (const QJsonValueRef value : list) {
        const QJsonValue deviceIdValue = value.toObject().value("device_id");

        if (deviceIdValue.isString()) {
            QString deviceId = deviceIdValue.toString();
            if (deviceId.isEmpty() == false) {
                connectedDeviceIds_.insert(deviceIdValue.toString());
            } else {
                qCCritical(lcDevStudio) << "malformatted payload received, empty device_id:" << value;
            }
        } else {
            qCCritical(lcDevStudio) << "malformatted payload received, missing device_id:" << value;
        }
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
    const QJsonValue listValue = payload.value("list");
    if (listValue.isArray() == false) {
        qCCritical(lcDevStudio) << "malformatted payload received, missing list:" << payload;
        return;
    }

    QJsonArray deviceList = listValue.toArray();

    beginResetModel();
    data_.clear();

    for (const QJsonValueRef value : deviceList) {
        if (value.isObject() == false) {
            qCCritical(lcDevStudio) << "malformatted payload received, invalid value in list:" << value;
            return;
        }

        QJsonObject device = value.toObject();
        const QJsonValue deviceId = device.value("device_id");
        const QJsonValue name = device.value("name");
        const QJsonValue address = device.value("address");
        const QJsonValue rssi = device.value("rssi");
        const QJsonValue isStrata = device.value("is_strata");

        if (deviceId.isString() == false
                || name.isString() == false
                || address.isString() == false
                || rssi.isDouble() == false
                || isStrata.isBool() == false)
        {
            qCCritical(lcDevStudio) << "bluetooth device not valid:" << device;
            continue;
        }

        BleDeviceModelItem item;
        item.deviceId = deviceId.toString();
        item.name = name.toString();
        item.address = address.toString();
        item.rssi = rssi.toInt();
        item.isStrata = isStrata.toBool();
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
        qCWarning(lcDevStudio) << "index out of range";
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


