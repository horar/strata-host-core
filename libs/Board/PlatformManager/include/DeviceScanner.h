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
     */
    virtual void init() = 0;

    /**
     * Stop scanning for new devices. Will close all open devices.
     */
    virtual void deinit() = 0;

    /**
     * Get scanner type.
     * @return Type of scanner
     */
    virtual Device::Type scannerType() const final;

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
    const Device::Type scannerType_;
};

typedef std::shared_ptr<DeviceScanner> DeviceScannerPtr;

}  // namespace
