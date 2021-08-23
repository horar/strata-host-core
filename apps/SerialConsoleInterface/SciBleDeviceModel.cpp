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
    setInDiscoveryMode(true);
    scanner_->startDiscovery();
}

void SciBleDeviceModel::tryConnectDevice(int index)
{
    if (index < 0 || index >= data_.count()) {
        qCWarning(logCategorySci) << "index out of range";
    }

    scanner_->connectDevice(data_.at(index).deviceId);
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

    emit discoveryFinished(effectiveErrorString);
    setInDiscoveryMode(false);
}

void SciBleDeviceModel::populateModel()
{
    const QList<BlootoothLowEnergyInfo> infoList = scanner_->discoveredDevices();

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
}

void SciBleDeviceModel::setInDiscoveryMode(bool inDiscoveryMode)
{
    if (inDiscoveryMode_ == inDiscoveryMode) {
        return;
    }

    inDiscoveryMode_ = inDiscoveryMode;
    emit inDiscoveryModeChanged();
}
