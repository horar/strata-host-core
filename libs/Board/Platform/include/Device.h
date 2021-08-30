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

            DeviceFailedToOpen, // device failed to open (possible cause: port open in another application)
            DeviceFailedToOpenGoingToRetry, // device failed to open, going to retry (possible cause: port open in another application)

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
            MockDevice,
            TcpDevice,
            BLEDevice
            // IMPORTANT: If adding new values, add them to allScannerTypes_ in DeviceScanner.cpp as well.
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
         * Open device communication channel. Non-blocking.
         * Emits opened() on success or deviceError(DeviceFailedToOpenRequestRetry, ...) on failure.
         */
        virtual void open() = 0;

        /**
         * Close device communication channel.
         */
        virtual void close() = 0;

        /**
         * Send message to device. Emits deviceError() signal in case of failure.
         * @param msg message to be written to device
         * @return serial number of the sent message
         */
        virtual unsigned sendMessage(const QByteArray& msg) = 0;

        /**
         * Returns serial number for next message.
         */
        virtual unsigned nextMessageNumber() final;

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

        /**
         * Check if device is connected (communication with it is possible).
         * For example if serial device is plugged to computer and its port is open.
         * @return true if device is connected, otherwise false
         */
        virtual bool isConnected() const = 0;

        /**
         * Reset receiving messages from device (clear internel buffers, etc.).
         */
        virtual void resetReceiving() = 0;

        friend QDebug operator<<(QDebug dbg, const Device* d);
        friend QDebug operator<<(QDebug dbg, const DevicePtr& d);

    signals:
        /**
         * Emitted when device communication channel was opened.
         */
        void opened();

        /**
         * Emitted when there is available new message from device.
         * @param msg message from device
         */
        void messageReceived(QByteArray msg);

        /**
         * Emitted when message was written to device or some problem occured and message cannot be written.
         * @param msg writen message to device
         * @param msgNum serial number of the sent message
         * @param errStr error string if message cannot be sent, empty (null) when everything is OK
         */
        void messageSent(QByteArray msg, unsigned msgNum, QString errStr);

        /**
         * Emitted when error occured during communication or connection.
         * @param errCode error code
         * @param msg error description
         */
        void deviceError(ErrorCode errCode, QString msg);

    protected:
        const QByteArray deviceId_;
        const QString deviceName_;  // name given by system (e.g. COM3)
        const Type deviceType_;

    private:
        unsigned messageNumber_;
    };
}  // namespace
