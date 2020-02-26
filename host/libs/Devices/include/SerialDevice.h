#ifndef SERIAL_DEVICE_H
#define SERIAL_DEVICE_H

#include <string>

#include <QString>
#include <QByteArray>
#include <QObject>
#include <QSerialPort>
#include <QTimer>
#include <QVariantMap>

#include <DeviceProperties.h>

namespace spyglass {

    class SerialDevice : public QObject
    {
        Q_OBJECT
        Q_DISABLE_COPY(SerialDevice)

    public:
        /**
         * SerialDevice constructor
         * @param connectionId device connection ID
         * @param name device name
         */
        SerialDevice(const int connectionId, const QString& name);

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
         * Start device identification - send initial JSON commands and parse responses.
         * @param getFwInfo if true send also get_firmware_info command
         * @return true if device identification has start, otherwise false
         */
        bool launchDevice(bool getFwInfo = true);

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


        friend QDebug operator<<(QDebug dbg, const SerialDevice* d);

    signals:
        /**
         * Emitted when there is available new message from serial port.
         * @param connectionId device connection ID
         * @param msg message from serial port
         */
        void msgFromDevice(int connectionId, QByteArray msg);

        /**
         * Emitted when serial device is ready for communication.
         * @param connectionId device connection ID
         * @param recognized true when device was recognized (identified), otherwise false
         */
        void deviceReady(int connectionId, bool recognized);

        /**
         * Emitted when error occured during communication on the serial port.
         * @param connectionId device connection ID
         * @param msg error description
         */
        void serialDeviceError(int connectionId, QString msg);

    // signals only for internal use:
        // Qt5 private signals: https://woboq.com/blog/how-qt-signals-slots-work-part2-qt5.html
        void identifyDevice(QPrivateSignal);
        void writeToPort(const QByteArray& data, QPrivateSignal);

    private slots:
        void readMessage();
        void handleError(QSerialPort::SerialPortError error);
        void handleDeviceResponse(const int connectionId, const QByteArray& data);
        void handleResponseTimeout();
        void deviceIdentification();
        void writeData(const QByteArray& data);

    private:
        bool parseDeviceResponse(const QByteArray& data, bool& isAck);

        int connection_id_;
        uint ucid_;  // unsigned connection ID - auxiliary variable for logging
        QString port_name_;
        QSerialPort serial_port_;
        std::string read_buffer_;
        QTimer response_timer_;

        bool device_busy_;

        enum class State
        {
            None,
            GetFirmwareInfo,
            GetPlatformInfo,
            DeviceReady,
            UnrecognizedDevice
        };
        State state_;

        enum class Action
        {
            None,
            WaitingForFirmwareInfo,
            WaitingForPlatformInfo,
            Done
        };
        Action action_;

        QString platform_id_;
        QString class_id_;
        QString verbose_name_;
        QString bootloader_ver_;
        QString application_ver_;
    };

}

#endif
