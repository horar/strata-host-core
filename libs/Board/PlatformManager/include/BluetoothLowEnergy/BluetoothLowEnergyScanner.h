/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <DeviceScanner.h>
#include <BluetoothLowEnergy/BluetoothLowEnergyDevice.h>
#include "BluetoothLowEnergy/BluetoothLowEnergyControllerFactory.h"

#include <QBluetoothDeviceDiscoveryAgent>

namespace strata::device::scanner {

struct BlootoothLowEnergyInfo {
    QByteArray deviceId;
    QString name;
    QString address; // contains deviceUuid on macOS, address elsewhere
    qint16 rssi;
    QVector<quint16> manufacturerIds;
    bool isStrata;
};


class BluetoothLowEnergyScanner : public DeviceScanner
{
    Q_OBJECT
    Q_DISABLE_COPY(BluetoothLowEnergyScanner);

public:

    enum DiscoveryFinishStatus {
        Finished,
        Cancelled,
        DiscoveryError,
    };

    BluetoothLowEnergyScanner();

    ~BluetoothLowEnergyScanner() override;

    virtual void init(quint32 flags = 0) override;
    virtual void deinit() override;

    void startDiscovery();
    void stopDiscovery();

    /**
     * Return list of deviceIds of all discovered devices
     * @return list of discovered devices
     */
    virtual QList<QByteArray> discoveredDevices() const override;

    /**
     * Return list of informations of all discovered devices
     * @return list of discovered devices and their info
     */
    const QList<BlootoothLowEnergyInfo> discoveredBleDevices() const;

    /**
     * Initiates connection to discovered BLE device.
     * @param deviceId device ID, returned by discoveredDevices()
     * @return empty string if connecting started, error message if there was an error (i.e. device already connected)
     * @note empty returned string doesn't mean successful connection, only initiation of connection process through PlatformManager
     */
    virtual QString connectDevice(const QByteArray& deviceId) override;

    /**
     * Drops connection to connected BLE device.
     * @param deviceId device ID
     * @return empty string if disconnecting started, error message if there was an error (i.e. device not connected)
     * @note empty returned string doesn't mean successful disconnection, only initiation of disconnection process through PlatformManager
     */
    virtual QString disconnectDevice(const QByteArray& deviceId) override;

    /**
     * Drops connection to all discovered devices.
     */
    virtual void disconnectAllDevices() override;

signals:
    void discoveryFinished(DiscoveryFinishStatus status, QString errorString);

private slots:
    void discoveryFinishedHandler();
    void discoveryCancelledHandler();
    void discoveryErrorHandler(QBluetoothDeviceDiscoveryAgent::Error error);

private:
    bool isEligible(const QBluetoothDeviceInfo &info) const;
    QString getDeviceAddress(const QBluetoothDeviceInfo &info) const;
    BlootoothLowEnergyInfo convertBlootoothLowEnergyInfo(const QBluetoothDeviceInfo &info) const;

    void createDiscoveryAgent();
    bool hasLocalAdapters();

    QBluetoothDeviceDiscoveryAgent *discoveryAgent_ = nullptr;
    const std::chrono::milliseconds discoveryTimeout_ = std::chrono::milliseconds(5000);
    QList<BlootoothLowEnergyInfo> discoveredDevices_;
    QHash<QByteArray, QBluetoothDeviceInfo> createdDevices_;
    QHash<QByteArray, QBluetoothDeviceInfo> discoveredDevicesMap_; // map deviceId -> QBluetoothDeviceInfo

    BluetoothLowEnergyControllerFactoryPtr controllerFactory_;
};

typedef std::shared_ptr<BluetoothLowEnergyScanner> BluetoothLowEnergyScannerPtr;

}  // namespace
