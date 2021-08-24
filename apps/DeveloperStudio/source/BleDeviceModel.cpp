#include "BleDeviceModel.h"
#include "logging/LoggingQtCategories.h"

#include <QTimer>
#include <chrono>
#include <QOperatingSystemVersion>

using namespace std::literals::chrono_literals;

BleDeviceModel::BleDeviceModel(
        CoreInterface *coreInterface,
        QObject *parent)
    : QAbstractListModel(parent),
      coreInterface_(coreInterface)
{
    setModelRoles();

    connect(coreInterface_, &CoreInterface::bluetoothScan, this, &BleDeviceModel::bluetoothScanReplyHandler);
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

bool BleDeviceModel::bleSupported() const
{
    if ((QOperatingSystemVersion::currentType() == QOperatingSystemVersion::MacOS) ||
       ((QOperatingSystemVersion::currentType() == QOperatingSystemVersion::Windows) &&
        (QOperatingSystemVersion::current() >= QOperatingSystemVersion::Windows8))) {
        return true;
    }

    return false;
}

void BleDeviceModel::startScan()
{
    QJsonObject cmdMessageObject;
    cmdMessageObject.insert("hcs::cmd", "bluetooth_scan");
    cmdMessageObject.insert("payload", QJsonObject());

    QJsonDocument doc(cmdMessageObject);
    QString strJson(doc.toJson(QJsonDocument::Compact));

    setLastScanError("");
    setInScanMode(true);
    coreInterface_->sendCommand(strJson);
}

void BleDeviceModel::tryConnect(int row)
{
    if (row < 0 || row >= data_.count()) {
        qCWarning(logCategoryStrataDevStudio) << "index out of range";
        return;
    }

    QString deviceId = data_.at(row).deviceId;

    if (requestedIds_.contains(deviceId)) {
        qCWarning(logCategoryStrataDevStudio) << "request already in progress" << deviceId;
        return;
    }

    requestedIds_.insert(data_.at(row).deviceId);

    setPropertyAt(row, true, ConnectionInProgressRole);

    QJsonObject cmdMessageObject;
    cmdMessageObject.insert("hcs::cmd", "connect_device");

    QJsonObject payload;
    payload.insert("device_id", deviceId);

    cmdMessageObject.insert("payload", payload);

    QJsonDocument doc(cmdMessageObject);
    QString strJson(doc.toJson(QJsonDocument::Compact));

    coreInterface_->sendCommand(strJson);
}

void BleDeviceModel::tryDisconnect(int row)
{
    if (row < 0 || row >= data_.count()) {
        qCWarning(logCategoryStrataDevStudio) << "index out of range";
        return;
    }

    QString deviceId = data_.at(row).deviceId;

    if (requestedIds_.contains(deviceId)) {
        qCWarning(logCategoryStrataDevStudio) << "request already in progress" << deviceId;
        return;
    }

    requestedIds_.insert(deviceId);

    setPropertyAt(row, true, ConnectionInProgressRole);

    QJsonObject cmdMessageObject;
    cmdMessageObject.insert("hcs::cmd", "disconnect_device");

    QJsonObject payload;
    payload.insert("device_id", deviceId);

    cmdMessageObject.insert("payload", payload);

    QJsonDocument doc(cmdMessageObject);
    QString strJson(doc.toJson(QJsonDocument::Compact));

    coreInterface_->sendCommand(strJson);
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

QString BleDeviceModel::lastScanError() const
{
    return lastScanError_;
}

QHash<int, QByteArray> BleDeviceModel::roleNames() const
{
    return roleByEnumHash_;
}

void BleDeviceModel::bluetoothScanReplyHandler(QJsonObject payload)
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

void BleDeviceModel::connectReplyHandler(QJsonObject payload)
{
    QString deviceId = payload.value("device_id").toString();

    if (requestedIds_.contains(deviceId) == false) {
        //not our request
        return;
    }

    requestedIds_.remove(deviceId);

    int row = findDeviceIndex(deviceId);
    if (row < 0) {
        return;
    }

    setPropertyAt(row, false, ConnectionInProgressRole);

    QString errorString = payload.value("error_string").toString();
    if (errorString.isEmpty() == false) {
        qCCritical(logCategoryStrataDevStudio) << "connection attempt failed" << deviceId << errorString;

    }

    emit tryConnectFinished(errorString);
}

void BleDeviceModel::disconnectReplyHandler(QJsonObject payload)
{
    QString deviceId = payload.value("device_id").toString();

    if (requestedIds_.contains(deviceId) == false) {
        //not our request
        return;
    }

    requestedIds_.remove(deviceId);

    int row = findDeviceIndex(deviceId);
    if (row < 0) {
        return;
    }

    setPropertyAt(row, false, ConnectionInProgressRole);

    QString errorString = payload.value("error_string").toString();
    if (errorString.isEmpty() == false) {
        qCCritical(logCategoryStrataDevStudio) << "disconnection attempt failed" << deviceId << errorString;
    }

    emit tryDisconnectFinished(errorString);
}

void BleDeviceModel::updateDeviceConnection(QJsonObject payload)
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

    dataChanged(
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

