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
}

void BluetoothLowEnergyScanner::deinit()
{
}

void BluetoothLowEnergyScanner::startDiscovery()
{
    if (discoveryAgent_ != nullptr) {
        if (discoveryAgent_->isActive()) {
            qCDebug(logCategoryDeviceScanner) << "device discovery is already in progress";
            return;
        } else {
            discoveryAgent_->disconnect();
            discoveryAgent_->deleteLater();
        }
    }

    createDiscoveryAgent();
    if (discoveryAgent_ == nullptr) {
        qCCritical(logCategoryDeviceScanner) << "discovery agent not created";

        //make sure signal is emitted after this slot is executed
        QTimer::singleShot(1, this, [this](){
            emit discoveryFinished(DiscoveryFinishStatus::DiscoveryError, "Discovery agent could not be created.");
        });

        return;
    }

    qCDebug(logCategoryDeviceScanner)
            << "device discovery is about to start"
            << "(duration" << discoveryAgent_->lowEnergyDiscoveryTimeout() << "ms)";

    discoveredDevices_.clear();
    discoveredDevicesMap_.clear();

    discoveryAgent_->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);
}

void BluetoothLowEnergyScanner::stopDiscovery()
{
    if (discoveryAgent_ == nullptr) {
        return;
    }

    qCDebug(logCategoryDeviceScanner) << "device discovery is about to be cancelled";
    discoveryAgent_->stop();
}

const QList<BlootoothLowEnergyInfo> BluetoothLowEnergyScanner::discoveredDevices() const
{
    return discoveredDevices_;
}

QString BluetoothLowEnergyScanner::connectDevice(const QByteArray& deviceId)
{
    qCDebug(logCategoryDeviceScanner()) << deviceId;

    if (discoveryAgent_ == nullptr) {
        qCWarning(logCategoryDeviceScanner()) << "Discovery agent not initialized.";
        return "Discovery agent not initialized.";
    }

    if (createdDevices_.contains(deviceId)) {
        qCWarning(logCategoryDeviceScanner()) << "Device already connected or connecting:" << deviceId;
        return "Device already connected or connecting: " + deviceId;
    }

    auto deviceInfoIterator = discoveredDevicesMap_.find(deviceId);
    if (deviceInfoIterator == discoveredDevicesMap_.end()) {
        qCWarning(logCategoryDeviceScanner()) << "No device with deviceId" << deviceId;
        return "No device with deviceId " + deviceId;
    }
    const QBluetoothDeviceInfo & deviceInfo = *deviceInfoIterator;

    DevicePtr device = std::make_shared<BluetoothLowEnergyDevice>(deviceId, deviceInfo);

    connect(device.get(), &Device::opened,
            this, &BluetoothLowEnergyScanner::deviceOpenedHandler);
    connect(device.get(), &Device::deviceError,
            this, &BluetoothLowEnergyScanner::deviceErrorHandler);

    platform::PlatformPtr platform = std::make_shared<platform::Platform>(device);

    createdDevices_.insert(deviceId, deviceInfo);
    emit deviceDetected(platform);
    return QString();
}

QString BluetoothLowEnergyScanner::disconnectDevice(const QByteArray& deviceId)
{
    qCDebug(logCategoryDeviceScanner()) << deviceId;

    if (createdDevices_.remove(deviceId)) {
        emit deviceLost(deviceId);
        return QString();
    }
    if (discoveredDevicesMap_.contains(deviceId)) {
        qCWarning(logCategoryDeviceScanner()) << "Device not connected:" << deviceId;
        return "Device not connected.";
    }
    qCWarning(logCategoryDeviceScanner()) << "No such device ID:" << deviceId;
    return "No such device ID.";
}

void BluetoothLowEnergyScanner::discoveryFinishedHandler()
{
    const QList<QBluetoothDeviceInfo> infoList = discoveryAgent_->discoveredDevices();

    qCDebug(logCategoryDeviceScanner()) << "discovered devices:" << infoList.length();

    qCDebug(logCategoryDeviceScanner) << "eligible devices:";
    qCDebug(logCategoryDeviceScanner) << "";
    for (const auto &info : infoList) {
        if (isEligible(info)) {
            BlootoothLowEnergyInfo infoItem = convertBlootoothLowEnergyInfo(info);

            discoveredDevices_.append(infoItem);
            discoveredDevicesMap_.insert(infoItem.deviceId, info);

            qCDebug(logCategoryDeviceScanner) << "device ID" << infoItem.deviceId;
            qCDebug(logCategoryDeviceScanner) << "name" << infoItem.name;
            qCDebug(logCategoryDeviceScanner) << "address" << info.address();
            qCDebug(logCategoryDeviceScanner) << "deviceUuid" << info.deviceUuid().toString(QBluetoothUuid::WithoutBraces);
            qCDebug(logCategoryDeviceScanner) << "rssi" << infoItem.rssi;
            qCDebug(logCategoryDeviceScanner) << "manufacturerIds" << infoItem.manufacturerIds;
            qCDebug(logCategoryDeviceScanner) << "is Strata" << infoItem.isStrata;
            qCDebug(logCategoryDeviceScanner) << "";
        }
    }
    qCDebug(logCategoryDeviceScanner) << "connected devices:";
    qCDebug(logCategoryDeviceScanner) << "";
    for (auto it = createdDevices_.keyValueBegin(); it != createdDevices_.keyValueEnd(); it++) {
        BlootoothLowEnergyInfo infoItem = convertBlootoothLowEnergyInfo((*it).second);
        infoItem.deviceId = (*it).first; // just in case, deviceId computation may return different value under certain circumstances
        discoveredDevices_.append(infoItem);
        discoveredDevicesMap_.insert((*it).first, (*it).second);

        qCDebug(logCategoryDeviceScanner) << "device ID" << infoItem.deviceId;
        qCDebug(logCategoryDeviceScanner) << "name" << infoItem.name;
        qCDebug(logCategoryDeviceScanner) << "device address" << infoItem.address;
        qCDebug(logCategoryDeviceScanner) << "rssi" << infoItem.rssi;
        qCDebug(logCategoryDeviceScanner) << "manufacturerIds" << infoItem.manufacturerIds;
        qCDebug(logCategoryDeviceScanner) << "is Strata" << infoItem.isStrata;
        qCDebug(logCategoryDeviceScanner) << "";
    }

    emit discoveryFinished(DiscoveryFinishStatus::Finished, "");
}

BlootoothLowEnergyInfo BluetoothLowEnergyScanner::convertBlootoothLowEnergyInfo(const QBluetoothDeviceInfo &info) const
{
    BlootoothLowEnergyInfo infoItem;
    infoItem.deviceId = BluetoothLowEnergyDevice::createDeviceId(info);
    infoItem.name = info.name();
    infoItem.address = getDeviceAddress(info);
    infoItem.rssi = info.rssi();
    infoItem.manufacturerIds = info.manufacturerIds();
    infoItem.isStrata = infoItem.manufacturerIds.contains(BluetoothLowEnergyDevice::MANUFACTURER_ID_ON_SEMICONDICTOR); // TODO!!! replace by real detection once the service+detection design is final
    return infoItem;
}

void BluetoothLowEnergyScanner::discoveryCancelledHandler()
{
    qCDebug(logCategoryDeviceScanner()) << "device discovery cancelled";

    emit discoveryFinished(DiscoveryFinishStatus::Cancelled, "");
}

void BluetoothLowEnergyScanner::discoveryErrorHandler(QBluetoothDeviceDiscoveryAgent::Error error)
{
    qCWarning(logCategoryDeviceScanner()) << error << discoveryAgent_->errorString();

    emit discoveryFinished(DiscoveryFinishStatus::DiscoveryError, discoveryAgent_->errorString());
}

void BluetoothLowEnergyScanner::deviceOpenedHandler()
{
    Device *device = qobject_cast<Device*>(QObject::sender());
    if (device == nullptr) {
        qCWarning(logCategoryDeviceScanner) << "cannot cast sender to device object";
        return;
    }
    emit connectDeviceFinished(device->deviceId());
}

void BluetoothLowEnergyScanner::deviceErrorHandler(Device::ErrorCode error, QString errorString)
{
    Q_UNUSED(errorString)

    Device *device = qobject_cast<Device*>(QObject::sender());
    if (device == nullptr) {
        qCWarning(logCategoryDeviceScanner) << "cannot cast sender to device object";
        return;
    }

    createdDevices_.remove(device->deviceId());

    if (error == Device::ErrorCode::DeviceFailedToOpen) {
        emit connectDeviceFailed(device->deviceId(), errorString);
    }

    if (error == Device::ErrorCode::DeviceDisconnected || error == Device::ErrorCode::DeviceFailedToOpen) {
        //loss is reported after error is processed in Platform
        QByteArray deviceId = device->deviceId();
        QTimer::singleShot(1, this, [this, deviceId](){
            qCDebug(logCategoryDeviceScanner) << "device loss is about to be reported for" << deviceId;
            emit deviceLost(deviceId);
        });
    }
}

bool BluetoothLowEnergyScanner::isEligible(const QBluetoothDeviceInfo &info) const
{
    if ((info.coreConfigurations() & QBluetoothDeviceInfo::LowEnergyCoreConfiguration) == false) {
        return false;
    }

    return true;
}

QString BluetoothLowEnergyScanner::getDeviceAddress(const QBluetoothDeviceInfo &info) const
{
    QString address;

#ifdef Q_OS_MACOS
    address = info.deviceUuid().toString(QBluetoothUuid::WithoutBraces);
#else
    address = info.address().toString();
#endif

    return address;
}

void BluetoothLowEnergyScanner::createDiscoveryAgent()
{
    discoveryAgent_ = new QBluetoothDeviceDiscoveryAgent(this);
    if (discoveryAgent_ == nullptr) {
        return;
    }

    discoveryAgent_->setLowEnergyDiscoveryTimeout(discoveryTimeout_.count());

    connect(discoveryAgent_, &QBluetoothDeviceDiscoveryAgent::finished,
            this, &BluetoothLowEnergyScanner::discoveryFinishedHandler, Qt::QueuedConnection);

    connect(discoveryAgent_, &QBluetoothDeviceDiscoveryAgent::canceled,
            this, &BluetoothLowEnergyScanner::discoveryCancelledHandler, Qt::QueuedConnection);

    connect(discoveryAgent_, QOverload<QBluetoothDeviceDiscoveryAgent::Error>::of(&QBluetoothDeviceDiscoveryAgent::error),
            this, &BluetoothLowEnergyScanner::discoveryErrorHandler, Qt::QueuedConnection);
}

}  // namespace
