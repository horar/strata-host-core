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
         * @param connectionId device connection ID
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
         * Write data to serial device.
         * @param data message to be written to device
         */
        void write(const QByteArray& data);

        /**
         * Get information about serial device (platform ID, bootloader version, ...).
         * @return QVariantMap filled with information about device
         */
        QVariantMap getDeviceInfo() const;

        /**
         * Get property.
         * @param property value from enum DeviceProperties
         * @return QString filled with value of required property
         */
        QString getProperty(DeviceProperties property) const;

        /**
         * Get device ID.
         * @return Device ID
         */
        int getDeviceId() const;

        friend QDebug operator<<(QDebug dbg, const SerialDevice* d);

    signals:
        /**
         * Emitted when there is available new message from serial port.
         * @param msg message from serial port
         */
        void msgFromDevice(QByteArray msg);

        /**
         * Emitted when error occured during communication on the serial port.
         * @param msg error description
         */
        void serialDeviceError(QString msg);

    // signals only for internal use:
        // Qt5 private signals: https://woboq.com/blog/how-qt-signals-slots-work-part2-qt5.html
        void writeToPort(const QByteArray& data, QPrivateSignal);

    private slots:
        void readMessage();
        void handleError(QSerialPort::SerialPortError error);
        void writeData(const QByteArray& data);

    private:
        // function used by friend class DeviceOperations
        void setProperties(const char* verboseName, const char* platformId, const char* classId, const char* btldrVer, const char* applVer);

        const int deviceId_;
        QString portName_;
        QSerialPort serialPort_;
        std::string readBuffer_;  // std::string keeps allocated memory after clear(), this is why read_buffer_ is std::string

        bool deviceBusy_;

        QString platformId_;
        QString classId_;
        QString verboseName_;
        QString bootloaderVer_;
        QString applicationVer_;
    };

    typedef std::shared_ptr<SerialDevice> SerialDeviceShPtr;
}

#endif
