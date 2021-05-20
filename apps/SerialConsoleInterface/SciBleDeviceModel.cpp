#include "SciBleDeviceModel.h"
#include "logging/LoggingQtCategories.h"

using strata::device::Device;
using strata::device::scanner::BluetoothLowEnergyScanner;
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
            this, &SciBleDeviceModel::populateModel);
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

    scanner_->tryConnectDevice(data_.at(index).address);
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

bool SciBleDeviceModel::inDiscoveryMode()
{
    return inDiscoveryMode_;
}

QHash<int, QByteArray> SciBleDeviceModel::roleNames() const
{
    return roleByEnumHash_;
}

void SciBleDeviceModel::populateModel()
{
    const QList<BlootoothLowEnergyInfo> infoList = scanner_->discoveredDevices();

    beginResetModel();

    data_.clear();

    for (const auto &info : infoList) {
        SciBleDeviceModelItem item;

        item.name = info.name;
        item.address = info.address;
        item.manufacturerIds = info.manufacturerIds;

        data_.append(item);
    }

    endResetModel();

    setInDiscoveryMode(false);
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
