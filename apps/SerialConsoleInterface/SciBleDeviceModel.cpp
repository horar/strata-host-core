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
}

SciBleDeviceModel::~SciBleDeviceModel()
{
}

QVariant SciBleDeviceModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= data_.count()) {
        qCWarning(logCategorySci) << "index out of range";
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
        qCCritical(logCategorySci) << "cannot cast Bluetooth Low Energy Scanner";
        return;
    }

    connect(scanner_.get(), &BluetoothLowEnergyScanner::discoveryFinished,
            this, &SciBleDeviceModel::discoveryFinishedHandler);

    connect(scanner_.get(), &BluetoothLowEnergyScanner::connectDeviceFinished,
            this, &SciBleDeviceModel::connectDeviceFinishedHandler);

    connect(scanner_.get(), &BluetoothLowEnergyScanner::connectDeviceFailed,
            this, &SciBleDeviceModel::connectDeviceFailedHandler);

    connect(scanner_.get(), &BluetoothLowEnergyScanner::deviceLost,
            this, &SciBleDeviceModel::deviceLostHandler);
}

bool SciBleDeviceModel::bleSupported() const
{
    if ((QOperatingSystemVersion::currentType() == QOperatingSystemVersion::MacOS) ||
       ((QOperatingSystemVersion::currentType() == QOperatingSystemVersion::Windows) &&
        (QOperatingSystemVersion::current() >= QOperatingSystemVersion::Windows8))) {
        return true;
    }

    return false;
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
        qCWarning(logCategorySci) << "index out of range";
    }

    QByteArray deviceId = data_.at(index).deviceId;

    if (requestedIds_.contains(deviceId)) {
        qCWarning(logCategorySci) << "request already in progress" << deviceId;
        return;
    }

    requestedIds_.insert(deviceId);

    setPropertyAt(index, true, ConnectionInProgressRole);

    QString err = scanner_->connectDevice(deviceId);

    setPropertyAt(index, err, ErrorStringRole);
}

void SciBleDeviceModel::tryDisconnectDevice(int index)
{
    if (index < 0 || index >= data_.count()) {
        qCWarning(logCategorySci) << "index out of range";
        return;
    }

    QByteArray deviceId = data_.at(index).deviceId;

    if (requestedIds_.contains(deviceId)) {
        qCWarning(logCategorySci) << "request already in progress" << deviceId;
        return;
    }

    requestedIds_.insert(deviceId);

    setPropertyAt(index, true, ConnectionInProgressRole);

    QString err = scanner_->disconnectDevice(deviceId);

    setPropertyAt(index, err, ErrorStringRole);
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

void SciBleDeviceModel::connectDeviceFinishedHandler(const QByteArray deviceId)
{
    int row = findDeviceIndex(deviceId);
    if (row >= 0) {
        setPropertyAt(row, false, ConnectionInProgressRole);
        setPropertyAt(row, true, IsConnectedRole);
        setPropertyAt(row, "", ErrorStringRole);
    }

    connectedDeviceIds_.insert(deviceId);

    if (requestedIds_.contains(deviceId)) {
        requestedIds_.remove(deviceId);
    }
}

void SciBleDeviceModel::connectDeviceFailedHandler(const QByteArray deviceId, const QString errorString)
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

    if (requestedIds_.contains(deviceId)) {
        requestedIds_.remove(deviceId);
    }
}

void SciBleDeviceModel::deviceLostHandler(QByteArray deviceId)
{
    int row = findDeviceIndex(deviceId);
    if (row >= 0) {
        setPropertyAt(row, false, ConnectionInProgressRole);
        setPropertyAt(row, false, IsConnectedRole);
    }

    if (connectedDeviceIds_.contains(deviceId)) {
        connectedDeviceIds_.remove(deviceId);
    }

    if (requestedIds_.contains(deviceId)) {
        requestedIds_.remove(deviceId);
    }
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
        item.isStrata = info.isStrata;
        item.isConnected = connectedDeviceIds_.contains(item.deviceId);

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
        qCWarning(logCategorySci) << "index out of range";
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
