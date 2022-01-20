/*
 * Copyright (c) 2018-2022 onsemi.
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
            qCDebug(lcDeviceScanner) << "device discovery is already in progress";
            return;
        } else {
            disconnect(discoveryAgent_, nullptr, this, nullptr);
            discoveryAgent_->deleteLater();
            discoveryAgent_ = nullptr;
        }
    }

    if (hasLocalAdapters() == false) {
        qCWarning(lcDeviceScanner) << "no valid Bluetooth adapters found, unable to start scan";

        //make sure signal is emitted after this slot is executed
        QTimer::singleShot(1, this, [this](){
            emit discoveryFinished(DiscoveryFinishStatus::DiscoveryError, "Cannot find valid Bluetooth adapter.");
        });

        return;
    }

    createDiscoveryAgent();
    if (discoveryAgent_ == nullptr) {
        qCCritical(lcDeviceScanner) << "discovery agent not created";

        //make sure signal is emitted after this slot is executed
        QTimer::singleShot(1, this, [this](){
            emit discoveryFinished(DiscoveryFinishStatus::DiscoveryError, "Discovery agent could not be created.");
        });

        return;
    }

    qCDebug(lcDeviceScanner)
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

    qCDebug(lcDeviceScanner) << "device discovery is about to be cancelled";
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
    qCDebug(lcDeviceScanner()) << deviceId;

    if (deviceId.startsWith(scannerPrefix()) == false) {
        qCWarning(lcDeviceScanner()) << "Device ID for incorrect scanner:" << deviceId;
        return "Device ID for incorrect scanner: " + deviceId;
    }

    if (discoveryAgent_ == nullptr) {
        qCWarning(lcDeviceScanner()) << "Discovery agent not initialized.";
        return "Discovery agent not initialized.";
    }

    if (createdDevices_.contains(deviceId)) {
        qCWarning(lcDeviceScanner()) << "Device already connected or connecting:" << deviceId;
        return "Device already connected or connecting: " + deviceId;
    }

    auto deviceInfoIterator = discoveredDevicesMap_.find(deviceId);
    if (deviceInfoIterator == discoveredDevicesMap_.end()) {
        qCWarning(lcDeviceScanner()) << "No device with deviceId" << deviceId;
        return "No device with deviceId " + deviceId;
    }
    const QBluetoothDeviceInfo & deviceInfo = *deviceInfoIterator;

    DevicePtr device = std::make_shared<BluetoothLowEnergyDevice>(deviceId, deviceInfo, controllerFactory_);
    platform::PlatformPtr platform = std::make_shared<platform::Platform>(device);

    createdDevices_.insert(deviceId, deviceInfo);
    emit deviceDetected(platform);
    return QString();
}

QString BluetoothLowEnergyScanner::disconnectDevice(const QByteArray& deviceId)
{
    qCDebug(lcDeviceScanner()) << deviceId;

    if (deviceId.startsWith(scannerPrefix()) == false) {
        qCWarning(lcDeviceScanner()) << "Device ID for incorrect scanner:" << deviceId;
        return "Device ID for incorrect scanner: " + deviceId;
    }

    if (createdDevices_.remove(deviceId)) {
        emit deviceLost(deviceId, QString());
        return QString();
    }

    if (discoveredDevicesMap_.contains(deviceId)) {
        qCWarning(lcDeviceScanner()) << "Device not connected:" << deviceId;
        return "Device not connected.";
    }

    qCWarning(lcDeviceScanner()) << "No such device ID:" << deviceId;
    return "No such device ID.";
}

void BluetoothLowEnergyScanner::disconnectAllDevices() {
    for (auto iter = createdDevices_.keyBegin(); iter != createdDevices_.keyEnd(); ++iter) {
        emit deviceLost(*iter, QString());
    }
    createdDevices_.clear();
}

void BluetoothLowEnergyScanner::discoveryFinishedHandler()
{
    const QList<QBluetoothDeviceInfo> infoList = discoveryAgent_->discoveredDevices();

    qCDebug(lcDeviceScanner()) << "discovered devices:" << infoList.length();

    qCDebug(lcDeviceScanner) << "eligible devices:";
    qCDebug(lcDeviceScanner) << "";
    for (const auto &info : infoList) {
        if (isEligible(info)) {
            BlootoothLowEnergyInfo infoItem = convertBlootoothLowEnergyInfo(info);

            discoveredDevices_.append(infoItem);
            discoveredDevicesMap_.insert(infoItem.deviceId, info);

            qCDebug(lcDeviceScanner) << "device ID" << infoItem.deviceId;
            qCDebug(lcDeviceScanner) << "name" << infoItem.name;
            qCDebug(lcDeviceScanner) << "address" << info.address();
            qCDebug(lcDeviceScanner) << "deviceUuid" << info.deviceUuid().toString(QBluetoothUuid::WithoutBraces);
            qCDebug(lcDeviceScanner) << "rssi" << infoItem.rssi;
            qCDebug(lcDeviceScanner) << "manufacturerIds" << infoItem.manufacturerIds;
            qCDebug(lcDeviceScanner) << "service UUIDs" << info.serviceUuids();
            qCDebug(lcDeviceScanner) << "is Strata" << infoItem.isStrata;
            qCDebug(lcDeviceScanner) << "";
        }
    }
    qCDebug(lcDeviceScanner) << "connected devices:";
    qCDebug(lcDeviceScanner) << "";
    for (auto it = createdDevices_.keyValueBegin(); it != createdDevices_.keyValueEnd(); it++) {
        BlootoothLowEnergyInfo infoItem = convertBlootoothLowEnergyInfo((*it).second);
        infoItem.deviceId = (*it).first; // just in case, deviceId computation may return different value under certain circumstances
        discoveredDevices_.append(infoItem);
        discoveredDevicesMap_.insert((*it).first, (*it).second);

        qCDebug(lcDeviceScanner) << "device ID" << infoItem.deviceId;
        qCDebug(lcDeviceScanner) << "name" << infoItem.name;
        qCDebug(lcDeviceScanner) << "device address" << infoItem.address;
        qCDebug(lcDeviceScanner) << "rssi" << infoItem.rssi;
        qCDebug(lcDeviceScanner) << "manufacturerIds" << infoItem.manufacturerIds;
        qCDebug(lcDeviceScanner) << "service UUIDs" << (*it).second.serviceUuids();
        qCDebug(lcDeviceScanner) << "is Strata" << infoItem.isStrata;
        qCDebug(lcDeviceScanner) << "";
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
    qCDebug(lcDeviceScanner()) << "device discovery cancelled";

    emit discoveryFinished(DiscoveryFinishStatus::Cancelled, "");
}

void BluetoothLowEnergyScanner::discoveryErrorHandler(QBluetoothDeviceDiscoveryAgent::Error error)
{
    qCWarning(lcDeviceScanner()) << error << discoveryAgent_->errorString();

    emit discoveryFinished(DiscoveryFinishStatus::DiscoveryError, discoveryAgent_->errorString());
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
        qCDebug(lcDeviceScanner).noquote().nospace() << "Found Bluetooth adapter, name: '" << adapter.name() << "', address: '" << adapter.address() << "'";
    }
    return (adapters.empty() == false);
}

}  // namespace
