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
#include <QString>
#include <QByteArray>
#include <QHash>

#include <DeviceScanner.h>
#include <Mock/MockDevice.h>

namespace strata::device::scanner {

class MockDeviceScanner : public DeviceScanner
{
    Q_OBJECT
    Q_DISABLE_COPY(MockDeviceScanner)

public:
    /**
     * MockDeviceScanner constructor
     */
    MockDeviceScanner();

    /**
     * MockDeviceScanner destructor
     */
    ~MockDeviceScanner() override;

    /**
     * Initialize scanner.
     * @param flags flags defining properties for mock device scanner (by default are all flags are unset)
     * Flags are not currently used in mock device scanner.
     */
    virtual void init(quint32 flags = 0) override;

    /**
     * Deinitialize scanner. Will close all open devices.
     */
    virtual void deinit() override;

    /**
     * Create ID for mock device - for external callers.
     * @param mockName name of the mock device
     * @return ID for mock device
     */
    QByteArray mockCreateDeviceId(const QString& mockName);

    /**
     * Will create new mock device and emit detected signal
     * @param deviceId device ID
     * @param name mock device name
     * @param saveMessages true when mock device should save messages (for tests), otherwise false
     * @return an empty (null) string if the device was created, otherwise a string containing an error
     */
    QString mockDeviceDetected(const QByteArray& deviceId, const QString& name, const bool saveMessages);

    /**
     * Will assign platform to an existing mock device and emit detected signal
     * @param mockDevice mock device
     * @return an empty (null) string if the device was assigned to platform, otherwise a string containing an error
     */
    QString mockDeviceDetected(DevicePtr mockDevice);

    /**
     * Will emit lost signal for previously detected device
     * @param deviceId device ID
     * @return true if device existed and was removed, otherwise false
     */
    bool mockDeviceLost(const QByteArray& deviceId);

    /**
     * Will emit lost signal for all previously detected devices
     */
    void mockAllDevicesLost();

    /**
     * Get existing mock device.
     * @param deviceId device ID
     * @return mock device if such device exists for given deviceID, nullptr otherwise
     */
    DevicePtr getMockDevice(const QByteArray& deviceId) const;

private:
    // deviceID <-> MockDevice
    QHash<QByteArray, DevicePtr> devices_;
    bool running_ = false;
};

typedef std::shared_ptr<MockDeviceScanner> MockDeviceScannerPtr;

}  // namespace
