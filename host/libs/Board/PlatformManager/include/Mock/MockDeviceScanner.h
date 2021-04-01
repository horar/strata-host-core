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

private:
    bool addMockDevice(const QByteArray& deviceId);

    std::set<QByteArray> deviceIds_;
    bool running_ = false;
};

}  // namespace
