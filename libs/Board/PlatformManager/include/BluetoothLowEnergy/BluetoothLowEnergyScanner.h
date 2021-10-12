/*
 * Copyright (c) 2018-2021 onsemi.
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
     * Possible outcomes:
     * - immediate error -> will return non-empty string
     * - error during connecting -> will emit connectDeviceFailed
     * - success -> will emit connectDeviceFinished
     * @param deviceId device ID, returned by discoveredDevices()
     * @return empty string if connecting started (doesn't mean successful connection, only initiation of connection process).
     * Error message if there was an error.
     */
    virtual QString connectDevice(const QByteArray& deviceId) override;

    /**
     * Drops connection to discovered BLE device.
     * @param deviceId device ID
     * @return empty string if disconnected.
     * Error message if there was an error.
     */
    virtual QString disconnectDevice(const QByteArray& deviceId) override;

    /**
     * Drops connection to all discovered devices.
     */
    virtual void disconnectAllDevices() override;

signals:
    void discoveryFinished(DiscoveryFinishStatus status, QString errorString);
    void connectDeviceFinished(const QByteArray deviceId);
    void connectDeviceFailed(const QByteArray deviceId, const QString errorString);

private slots:
    void discoveryFinishedHandler();
    void discoveryCancelledHandler();
    void discoveryErrorHandler(QBluetoothDeviceDiscoveryAgent::Error error);
    void deviceOpenedHandler();
    void deviceErrorHandler(Device::ErrorCode error, QString errorString);

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
