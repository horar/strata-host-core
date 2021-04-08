#pragma once

#include <QObject>
#include <QByteArray>

#include <Device.h>

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
        Device::Type scannerType() const;

    signals:
        /**
         * Emitted when new device was detected.
         * @note this signal only works with Qt::DirectConnection, not with Qt::QueuedConnection
         * @note in such case change DevicePtr to QSharedPointer or use Q_DECLARE_SMART_POINTER_METATYPE
         * @param device pointer
         */
        void deviceDetected(DevicePtr device);

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
