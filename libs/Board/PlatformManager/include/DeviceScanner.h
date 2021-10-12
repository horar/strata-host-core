/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>
#include <QByteArray>

#include <Platform.h>

namespace strata::device::scanner {

class DeviceScanner : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(DeviceScanner)

public:
    /**
     * DeviceScanner constructor
     * @param scanner type (value form Type enum)
     */
    DeviceScanner(const Device::Type scannerType);

    /**
     * Device destructor
     */
    virtual ~DeviceScanner();

    /**
     * Start scanning for new devices.
     * @return true if scanning was started, otherwise false
     * @param flags flags defining properties for scanner (by default are all flags are unset)
     */
    virtual void init(quint32 flags = 0) = 0;

    /**
     * Stop scanning for new devices. Will close all open devices.
     */
    virtual void deinit() = 0;

    /**
     * Return list of deviceIds of all discovered devices
     * @return list of discovered devices
     */
    virtual QList<QByteArray> discoveredDevices() const = 0;

    /**
     * Initiates connection to discovered device.
     * @param deviceId device ID, returned by discoveredDevices()
     * @return empty string if connecting started, error message if there was an error
     */
    virtual QString connectDevice(const QByteArray& deviceId) = 0;

    /**
     * Drops connection to discovered device.
     * @param deviceId device ID
     * @return empty string if disconnected, error message if there was an error.
     */
    virtual QString disconnectDevice(const QByteArray& deviceId) = 0;

    /**
     * Drops connection to all discovered devices.
     */
    virtual void disconnectAllDevices() = 0;

    /**
     * Get scanner type.
     * @return Type of scanner
     */
    virtual Device::Type scannerType() const final;

    /**
     * Get scanner prefix - should be added at the start of deviceId.
     * Must be unique. Two scanners with coliding prefixes can't run.
     * @return scanner prefix
     */
    virtual QByteArray scannerPrefix() const final;

    /**
     * Mapping of deviceId to scanner/device type
     * @param deviceId deviceId to be checked for type
     * @return scanner/device type
     */
    static Device::Type scannerType(const QByteArray& deviceId);

    /**
     * Mapping of Type to deviceId prefix added by scanner.
     * @param type device type
     * @return deviceId prefix
     */
    static const QByteArray scannerPrefix(const Device::Type type);
signals:
    /**
     * Emitted when new device was detected.
     * @param platform pointer
     */
    void deviceDetected(platform::PlatformPtr platform);

    /**
     * Emitted when device was physically disconnected.
     * @param device id
     */
    void deviceLost(QByteArray deviceId);

protected:
    /**
     * Creates device ID string, based on unique hash identifying the device.
     * Adds scanner prefix to the hash.
     * @param uniqueHash unique hash, identifying the device.
     * @return device ID.
     */
    virtual QByteArray createDeviceId(const QByteArray &uniqueHash) const final;

    const static QMap<Device::Type, QByteArray> allScannerTypes_;
    const Device::Type scannerType_;
};

typedef std::shared_ptr<DeviceScanner> DeviceScannerPtr;

}  // namespace
