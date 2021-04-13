#pragma once

#include <memory>

#include <QObject>
#include <QString>
#include <QByteArray>

Q_DECLARE_SMART_POINTER_METATYPE(std::shared_ptr)

namespace strata::device {

    class Device;

    typedef std::shared_ptr<Device> DevicePtr;

    class Device : public QObject
    {
        Q_OBJECT
        Q_DISABLE_COPY(Device)

    public:
        /**
        * The ErrorCode enum for deviceError() signal.
        */
        enum class ErrorCode {
            // [OK]

            NoError = 0,        // not emitted, just a placeholder

            // [WARNING] - device does not have to be disconnected

            DeviceBusy,         // device is currently locked by another operation (possible cause: more than 1 operation ongoing)
            DeviceFailedToOpen, // device failed to open (possible cause: port open in another application)

            // [ERROR] - device should be disconnected

            DeviceDisconnected, // device was disconnected
            DeviceError,        // device reported error
        };
        Q_ENUM(ErrorCode)

        /**
        * The Type enum to recognize device type.
        */
        enum class Type {
            SerialDevice,
            MockDevice
        };
        Q_ENUM(Type)

        /**
         * Device constructor
         * @param deviceId device ID
         * @param name device name
         * @param type device type (value form Type enum)
         */
        Device(const QByteArray& deviceId, const QString& name, const Type type);

        /**
         * Device destructor
         */
        virtual ~Device();

        /**
         * Open device communication channel.
         * @return true if device was opened, otherwise false
         */
        virtual bool open() = 0;

        /**
         * Close device communication channel.
         */
        virtual void close() = 0;

        /**
         * Send message to device. Emits deviceError() signal in case of failure.
         * @param msg message to be written to device
         * @return true if message can be sent, otherwise false
         */
        virtual bool sendMessage(const QByteArray msg) = 0;

        /**
         * Get device ID.
         * @return Device ID
         */
        virtual QByteArray deviceId() const final;

        /**
         * Get device name given by system (e.g. COM3)
         * @return Device name
         */
        virtual const QString deviceName() const final;

        /**
         * Get device type.
         * @return Type of device
         */
        virtual Type deviceType() const final;

        friend QDebug operator<<(QDebug dbg, const Device* d);
        friend QDebug operator<<(QDebug dbg, const DevicePtr& d);

    signals:
        /**
         * Emitted when there is available new message from device.
         * @param msg message from device
         */
        void messageReceived(QByteArray msg);

        /**
         * Emitted when message was written to device.
         * @param msg writen message to device
         */
        void messageSent(QByteArray msg);

        /**
         * Emitted when error occured during communication on the serial port.
         * @param errCode error code
         * @param msg error description
         */
        void deviceError(ErrorCode errCode, QString msg);

    protected:
        const QByteArray deviceId_;
        const QString deviceName_;  // name given by system (e.g. COM3)
        const Type deviceType_;
    };
}  // namespace
