#ifndef SERIAL_DEVICE_H
#define SERIAL_DEVICE_H

#include <string>
#include <QString>
#include <QByteArray>
#include <QObject>
#include <QSerialPort>
#include <QTimer>
#include <QVariantMap>

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
         * @return true if device identification has start, otherwise false
         */
        bool launchDevice();

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

        int m_connection_id;
        uint m_ucid;  // unsigned connection ID - auxiliary variable for logging
        QString m_name;
        QSerialPort m_serial_port;
        std::string m_read_buffer;
        QTimer m_response_timer;

        bool m_device_busy;

        enum class State
        {
            None,
            GetFirmwareInfo,
            GetPlatformInfo,
            DeviceReady,
            UnrecognizedDevice
        };
        State m_state;

        enum class Action
        {
            None,
            WaitingForFirmwareInfo,
            WaitingForPlatformInfo,
            Done
        };
        Action m_action;

        QString m_platform_id;
        QString m_verbose_name;
        QString m_bootloader_ver;
        QString m_application_ver;
    };

}

#endif
