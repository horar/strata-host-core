#include "BluetoothLowEnergy/BluetoothLowEnergyScanner.h"
#include "logging/LoggingQtCategories.h"

#include <QBluetoothAddress>
#include <QBluetoothLocalDevice>
#include <QBluetoothDeviceInfo>
#include <QBluetoothUuid>
#include <QDebug>

namespace strata::device::scanner {

BluetoothLowEnergyScanner::BluetoothLowEnergyScanner()
    : DeviceScanner(Device::Type::BLEDevice)
{
}

BluetoothLowEnergyScanner::~BluetoothLowEnergyScanner()
{
}

void BluetoothLowEnergyScanner::init()
{
    discoveryAgent_.setLowEnergyDiscoveryTimeout(discoveryTimeout_.count());

    connect(&discoveryAgent_, &QBluetoothDeviceDiscoveryAgent::finished,
            this, &BluetoothLowEnergyScanner::discoveryFinishedHandler);

    connect(&discoveryAgent_, &QBluetoothDeviceDiscoveryAgent::canceled,
            this, &BluetoothLowEnergyScanner::discoveryCanceledHandler);

    connect(&discoveryAgent_, QOverload<QBluetoothDeviceDiscoveryAgent::Error>::of(&QBluetoothDeviceDiscoveryAgent::error),
            this, &BluetoothLowEnergyScanner::discoveryErrorHandler);
}

void BluetoothLowEnergyScanner::deinit()
{
    discoveryAgent_.disconnect();
}

void BluetoothLowEnergyScanner::startDiscovery()
{
    qCDebug(logCategoryDeviceScanner)
            << "device discovery is about to start"
            << "(takes"<< discoveryAgent_.lowEnergyDiscoveryTimeout() << "ms)";

    discoveryAgent_.start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);
    discoveredDevices_.clear();
}

void BluetoothLowEnergyScanner::stopDiscovery()
{
    discoveryAgent_.stop();
}

const QList<BlootoothLowEnergyInfo> BluetoothLowEnergyScanner::discoveredDevices()
{
    return discoveredDevices_;
}

void BluetoothLowEnergyScanner::tryConnectDevice(const QString &address)
{
    //TODO if we are in the middle of scannig, we should wait until it finishes

    qCDebug(logCategoryDeviceScanner()) << address;

    const QList<QBluetoothDeviceInfo> infoList = discoveryAgent_.discoveredDevices();
    for (const auto &info : infoList) {
        QString infoAddress = getDeviceAddress(info);
        if (infoAddress == address) {
            DevicePtr device = std::make_shared<BluetoothLowEnergyDevice>(info);
            platform::PlatformPtr platform = std::make_shared<platform::Platform>(device);

            emit deviceDetected(platform);
        }
    }
}

void BluetoothLowEnergyScanner::discoveryFinishedHandler()
{
    const QList<QBluetoothDeviceInfo> infoList = discoveryAgent_.discoveredDevices();

    qCDebug(logCategoryDeviceScanner()) << "discovered devices:" << infoList.length();

    qCDebug(logCategoryDeviceScanner) << "eligible devices:";
    for (const auto &info : infoList) {
        if (isEligible(info)) {
            qCDebug(logCategoryDeviceScanner) << "name" << info.name();
            qCDebug(logCategoryDeviceScanner) << "address" << info.address();
            qCDebug(logCategoryDeviceScanner) << "deviceUuid" << info.deviceUuid().toString(QBluetoothUuid::WithoutBraces);
            qCDebug(logCategoryDeviceScanner) << "manufacturerIds" << info.manufacturerIds();
            qCDebug(logCategoryDeviceScanner) << "";

            BlootoothLowEnergyInfo infoItem;
            infoItem.name = info.name();

            infoItem.address = getDeviceAddress(info);
            infoItem.manufacturerIds = info.manufacturerIds();

            discoveredDevices_.append(infoItem);
        }
    }

    emit discoveryFinished();
}

void BluetoothLowEnergyScanner::discoveryCanceledHandler()
{
    qCDebug(logCategoryDeviceScanner()) << "device discovery canceled";

    emit discoveryFinished();
}

void BluetoothLowEnergyScanner::discoveryErrorHandler(QBluetoothDeviceDiscoveryAgent::Error error)
{
    qCWarning(logCategoryDeviceScanner()) << error;
}

bool BluetoothLowEnergyScanner::isEligible(const QBluetoothDeviceInfo &info) const
{
    if ((info.coreConfigurations() & QBluetoothDeviceInfo::LowEnergyCoreConfiguration) == false) {
        return false;
    }

//    const QVector<quint16> manufacturerIds = info.manufacturerIds();
//    for (const auto &id : manufacturerIds) {
//        if (eligibleIds_.indexOf(id) >= 0) {
//            return true;
//        }
//    }

//    return false;

    return true;
}

QString BluetoothLowEnergyScanner::getDeviceAddress(const QBluetoothDeviceInfo &info) const
{
    QString address;

#ifdef Q_OS_MACOS
    address = info.deviceUuid().toString(QBluetoothUuid::WithoutBraces);
#else
    info.address = info.address().toString();
#endif

    return address;
}

}  // namespace
