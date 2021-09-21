/*
 * Copyright (c) 2018-2021 onsemi.
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
    void computeListDiff(const std::set<QByteArray>& originalList, const std::set<QByteArray>& newList,
                         std::set<QByteArray>& addedList, std::set<QByteArray>& removedList) const;
    bool addSerialDevice(const QByteArray& deviceId);

    QTimer timer_;
    std::set<QByteArray> deviceIds_;        // Ids of detected Devices for which we emited deviceDetected
    QHash<QByteArray, QString> portNames_;  // serial port names for each detected Device Id
};

}  // namespace
