#ifndef SERIAL_DEVICE_H
#define SERIAL_DEVICE_H

#include <string>
#include <memory>

#include <QString>
#include <QByteArray>
#include <QObject>
#include <QSerialPort>
#include <QTimer>
#include <QVariantMap>

#include <DeviceProperties.h>

namespace strata {

    class SerialDevice : public QObject
    {
        Q_OBJECT
        Q_DISABLE_COPY(SerialDevice)

    friend class DeviceOperations;

    public:
        /**
         * SerialDevice constructor
         * @param deviceId device ID
         * @param name device name
         */
        SerialDevice(const int deviceId, const QString& name);

        /**
         * SerialDevice destructor
         */
        ~SerialDevice();

        /**
         * Open serial port.
         * @return true if port was opened, otherwise false
         */
        bool open();

        /**
         * Close serial port.
         */
        void close();

        /**
         * Send message to serial device. Emits serialDeviceError in case of failure.
         * @param msg message to be written to device
         * @return true if message was sent, otherwise false
         */
        bool sendMessage(const QByteArray msg);

        /**
         * Get information about serial device (platform ID, bootloader version, ...).
         * @return QVariantMap filled with information about device
         */
        [[deprecated("Use deviceId() and property() instead.")]]
        QVariantMap getDeviceInfo() const;

        /**
         * Get property.
         * @param property value from enum DeviceProperties
         * @return QString filled with value of required property
         */
        QString property(DeviceProperties property) const;

        /**
         * Get device ID.
         * @return Device ID
         */
        int deviceId() const;

        friend QDebug operator<<(QDebug dbg, const SerialDevice* d);

    signals:
        /**
         * Emitted when there is available new message from serial port.
         * @param msg message from serial port
         */
        void msgFromDevice(QByteArray msg);

        /**
         * Emitted when message was written to serial port.
         * @param msg writen message to serial port
         */
        void messageSent(QByteArray msg);

        /**
         * Emitted when error occured during communication on the serial port.
         * @param errCode error code (value < 0 is custom error code, other values are from QSerialPort::SerialPortError)
         * @param msg error description
         */
        void serialDeviceError(int errCode, QString msg);

    private slots:
        void readMessage();
        void handleError(QSerialPort::SerialPortError error);

    private:
        bool writeData(const QByteArray& data, quintptr lockId);
        // *** functions used by friend class DeviceOperations:
        void setProperties(const char* verboseName, const char* platformId, const char* classId, const char* btldrVer, const char* applVer);
        bool lockDevice(quintptr lockId);
        void unlockDevice(quintptr lockId);
        bool sendMessage(const QByteArray msg, quintptr lockId);
        // ***

        const int deviceId_;
        QString portName_;
        QSerialPort serialPort_;
        std::string readBuffer_;  // std::string keeps allocated memory after clear(), this is why read_buffer_ is std::string

        // If some operation (identification, flashing firmware, ...) is running, device should be locked
        // for other operations or sending messages. Device can be locked only by DeviceOperations class.
        // Address of DeviceOperations class instance is used as value of deviceLock_. 0 means unlocked.
        quintptr deviceLock_;

        QString platformId_;
        QString classId_;
        QString verboseName_;
        QString bootloaderVer_;
        QString applicationVer_;
    };

    typedef std::shared_ptr<SerialDevice> SerialDevicePtr;
}

#endif