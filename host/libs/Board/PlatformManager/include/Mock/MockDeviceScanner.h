#pragma once

#include <set>

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
     * Start scanning for new devices.
     * @return true if scanning was started, otherwise false
     */
    virtual void init() override;

    /**
     * Stop scanning for new devices. Will close all open devices.
     */
    virtual void deinit() override;

    /**
     * Will create new mock device and emit detected signal
     * @param deviceId device ID
     * @param name mock device name
     * @param saveMessages true when mock device should save messages (for tests), otherwise false
     * @return true if device did not existed and was created, otherwise false
     */
    bool mockDeviceDetected(const QByteArray& deviceId, const QString& name, const bool saveMessages);

    /**
     * Will emit lost signal for previously detected device
     * @param deviceId device ID
     * @return true if device existed and was removed, otherwise false
     */
    bool mockDeviceLost(const QByteArray& deviceId);

private:
    std::set<QByteArray> deviceIds_;
    bool running_ = false;
};

}  // namespace
