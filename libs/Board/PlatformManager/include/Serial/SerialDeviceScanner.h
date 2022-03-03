/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <set>

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QHash>
#include <QTimer>
#include <QSet>

#include <DeviceScanner.h>
#include <Serial/SerialDevice.h>

namespace strata::device::scanner {

class SerialDeviceScanner : public DeviceScanner
{
    Q_OBJECT
    Q_DISABLE_COPY(SerialDeviceScanner)

public:
    /**
     * Flags defining properties for serial device scanner.
     * By default, scanner starts with all flags unset.
     */
    enum SerialScannerFlag {
        DisableAutomaticScan = 0x0001
    };
    Q_DECLARE_FLAGS(SerialScannerProperty, SerialScannerFlag)

    /**
     * SerialDeviceScanner constructor
     */
    SerialDeviceScanner();

    /**
     * SerialDeviceScanner destructor
     */
    ~SerialDeviceScanner() override;

    /**
     * Initialize scanner.
     * @param flags flags defining properties for serial device scanner (by default are all flags are unset)
     */
    virtual void init(quint32 flags = 0) override;

    /**
     * Deinitialize scanner and stop scanning for new devices. Will close all open devices.
     */
    virtual void deinit() override;

    /**
     * Return list of deviceIds of all discovered devices
     * @return list of discovered devices
     */
    virtual QList<QByteArray> discoveredDevices() const override;

    /**
     * Initiates connection to discovered device.
     * @param deviceId device ID, returned by discoveredDevices()
     * @return empty string if connecting started, error message if there was an error
     */
    virtual QString connectDevice(const QByteArray& deviceId) override;

    /**
     * Drops connection to discovered device.
     * @param deviceId device ID
     * @return empty string if disconnected, error message if there was an error.
     */
    virtual QString disconnectDevice(const QByteArray& deviceId) override;

    /**
     * Drops connection to all discovered devices.
     */
    virtual void disconnectAllDevices() override;

    /**
     * Set properties for serial device scanner.
     * Calling setProperties(A | B) is equivalent to calling setProperties(A) and then setProperties(B).
     * @param flags flags defining properties for serial device scanner
     */
    void setProperties(quint32 flags);

    /**
     * Unset properties for serial device scanner.
     * Calling unsetProperties(A | B) is equivalent to calling unsetProperties(A) and then unsetProperties(B).
     * To unset all properties (restore default values), call unsetProperties(0xFFFFFFFF).
     * @param flags flags defining properties for serial device scanner
     */
    void unsetProperties(quint32 flags);

private slots:
    void checkNewSerialDevices();

private:
    void startAutomaticScan();
    void stopAutomaticScan();
    void computeListDiff(const QSet<QByteArray>& originalList, const QSet<QByteArray>& newList,
                         QSet<QByteArray>& addedList, QSet<QByteArray>& removedList) const;

    QTimer timer_;
    QSet<QByteArray> deviceIds_;        // Ids of detected Devices for which we emited deviceDetected
    QHash<QByteArray, QString> portNames_;  // serial port names for each detected Device Id
};

}  // namespace
