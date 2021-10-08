/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "BluetoothLowEnergy/BluetoothLowEnergyScanner.h"
#include "logging/LoggingQtCategories.h"

#include <QBluetoothAddress>
#include <QBluetoothLocalDevice>
#include <QBluetoothDeviceInfo>
#include <QBluetoothUuid>
#include <QDebug>

#if defined(Q_OS_WIN)
  #include <Windows.h>
  #include <BluetoothAPIs.h>
#endif

namespace strata::device::scanner {

BluetoothLowEnergyScanner::BluetoothLowEnergyScanner()
    : DeviceScanner(Device::Type::BLEDevice)
{
    controllerFactory_ = std::make_shared<BluetoothLowEnergyControllerFactory>();
}

BluetoothLowEnergyScanner::~BluetoothLowEnergyScanner()
{
    if ((createdDevices_.isEmpty() == false) || (discoveryAgent_ != nullptr)) {
        BluetoothLowEnergyScanner::deinit();
    }
}

void BluetoothLowEnergyScanner::init(quint32 flags)
{
    Q_UNUSED(flags)
}

void BluetoothLowEnergyScanner::deinit()
{
    stopDiscovery();

    if (discoveryAgent_ != nullptr) {
        disconnect(discoveryAgent_, nullptr, this, nullptr);
        discoveryAgent_->deleteLater();
        discoveryAgent_ = nullptr;
    }

    BluetoothLowEnergyScanner::disconnectAllDevices();
}

void BluetoothLowEnergyScanner::startDiscovery()
{
    if (discoveryAgent_ != nullptr) {
        if (discoveryAgent_->isActive()) {
            qCDebug(logCategoryDeviceScanner) << "device discovery is already in progress";
            return;
        } else {
            disconnect(discoveryAgent_, nullptr, this, nullptr);
            discoveryAgent_->deleteLater();
            discoveryAgent_ = nullptr;
        }
    }

    if (hasLocalAdapters() == false) {
        qCWarning(logCategoryDeviceScanner) << "no valid Bluetooth adapters found, unable to start scan";

        //make sure signal is emitted after this slot is executed
        QTimer::singleShot(1, this, [this](){
            emit discoveryFinished(DiscoveryFinishStatus::DiscoveryError, "Cannot find valid Bluetooth adapter.");
        });

        return;
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

QList<QByteArray> BluetoothLowEnergyScanner::discoveredDevices() const
{
    return discoveredDevicesMap_.keys();
}

const QList<BlootoothLowEnergyInfo> BluetoothLowEnergyScanner::discoveredBleDevices() const
{
    return discoveredDevices_;
}

QString BluetoothLowEnergyScanner::connectDevice(const QByteArray& deviceId)
{
    qCDebug(logCategoryDeviceScanner()) << deviceId;

    if (deviceId.startsWith(scannerPrefix()) == false) {
        qCWarning(logCategoryDeviceScanner()) << "Device ID for incorrect scanner:" << deviceId;
        return "Device ID for incorrect scanner: " + deviceId;
    }

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

    DevicePtr device = std::make_shared<BluetoothLowEnergyDevice>(deviceId, deviceInfo, controllerFactory_);
    platform::PlatformPtr platform = std::make_shared<platform::Platform>(device);

    connect(platform.get(), &platform::Platform::opened,
            this, &BluetoothLowEnergyScanner::deviceOpenedHandler);
    connect(platform.get(), &platform::Platform::deviceError,
            this, &BluetoothLowEnergyScanner::deviceErrorHandler);

    createdDevices_.insert(deviceId, deviceInfo);
    emit deviceDetected(platform);
    return QString();
}

QString BluetoothLowEnergyScanner::disconnectDevice(const QByteArray& deviceId)
{
    qCDebug(logCategoryDeviceScanner()) << deviceId;

    if (deviceId.startsWith(scannerPrefix()) == false) {
        qCWarning(logCategoryDeviceScanner()) << "Device ID for incorrect scanner:" << deviceId;
        return "Device ID for incorrect scanner: " + deviceId;
    }

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

void BluetoothLowEnergyScanner::disconnectAllDevices() {
    for (auto iter = createdDevices_.keyBegin(); iter != createdDevices_.keyEnd(); ++iter) {
        emit deviceLost(*iter);
    }
    createdDevices_.clear();
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
            qCDebug(logCategoryDeviceScanner) << "service UUIDs" << info.serviceUuids();
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
        qCDebug(logCategoryDeviceScanner) << "service UUIDs" << (*it).second.serviceUuids();
        qCDebug(logCategoryDeviceScanner) << "is Strata" << infoItem.isStrata;
        qCDebug(logCategoryDeviceScanner) << "";
    }

    emit discoveryFinished(DiscoveryFinishStatus::Finished, "");
}

BlootoothLowEnergyInfo BluetoothLowEnergyScanner::convertBlootoothLowEnergyInfo(const QBluetoothDeviceInfo &info) const
{
    BlootoothLowEnergyInfo infoItem;
    infoItem.deviceId = createDeviceId(BluetoothLowEnergyDevice::createUniqueHash(info));
    infoItem.name = info.name();
    infoItem.address = getDeviceAddress(info);
    infoItem.rssi = info.rssi();
    infoItem.manufacturerIds = info.manufacturerIds();
    infoItem.isStrata = info.serviceUuids().contains(ble::STRATA_ID_SERVICE);
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
    platform::Platform *platform = qobject_cast<platform::Platform*>(QObject::sender());
    if (platform == nullptr) {
        qCWarning(logCategoryDeviceScanner) << "cannot cast sender to platform object";
        return;
    }
    emit connectDeviceFinished(platform->deviceId());
}

void BluetoothLowEnergyScanner::deviceErrorHandler(Device::ErrorCode error, QString errorString)
{
    platform::Platform *platform = qobject_cast<platform::Platform*>(QObject::sender());
    if (platform == nullptr) {
        qCWarning(logCategoryDeviceScanner) << "cannot cast sender to platform object";
        return;
    }

    if (error == Device::ErrorCode::DeviceFailedToOpen) {
        emit connectDeviceFailed(platform->deviceId(), errorString);
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

bool BluetoothLowEnergyScanner::hasLocalAdapters()
{
#if defined(Q_OS_WIN)
    QList<QBluetoothHostInfo> adapters;

    BLUETOOTH_FIND_RADIO_PARAMS searchParameters = {0};
    searchParameters.dwSize = sizeof(searchParameters);
    HANDLE radioHandle = nullptr;

    const HBLUETOOTH_RADIO_FIND radioSearchHandle = ::BluetoothFindFirstRadio(&searchParameters, &radioHandle);
    if (radioSearchHandle != nullptr) {
        do {
            BLUETOOTH_RADIO_INFO radioInfo = {0};
            radioInfo.dwSize = sizeof(radioInfo);

            if (::BluetoothGetRadioInfo(radioHandle, &radioInfo) == ERROR_SUCCESS) {
                QBluetoothHostInfo adapterInfo;
                adapterInfo.setAddress(QBluetoothAddress(radioInfo.address.ullLong));
                adapterInfo.setName(QString::fromWCharArray(radioInfo.szName));
                adapters.append(adapterInfo);
            }
            ::CloseHandle(radioHandle);
        } while (::BluetoothFindNextRadio(radioSearchHandle, &radioHandle));

        ::BluetoothFindRadioClose(radioSearchHandle);
    }
#else
    QList<QBluetoothHostInfo> adapters = QBluetoothLocalDevice::allDevices();
#endif

    for(const auto& adapter: adapters) {
        qCDebug(logCategoryDeviceScanner).noquote().nospace() << "Found Bluetooth adapter, name: '" << adapter.name() << "', address: '" << adapter.address() << "'";
    }
    return (adapters.empty() == false);
}

}  // namespace
