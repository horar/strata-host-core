#ifndef SERIAL_DEVICE_H
#define SERIAL_DEVICE_H

#include <string>

#include <Device/Device.h>

#include <QSerialPort>

namespace strata::device::serial {

class SerialDevice : public Device
{
    Q_OBJECT
    Q_DISABLE_COPY(SerialDevice)

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
    ~SerialDevice() override;

    /**
     * Open serial port.
     * @return true if port was opened, otherwise false
     */
    virtual bool open() override;

    /**
     * Close serial port.
     */
    virtual void close() override;

    /**
     * Check if serial port can be opened.
     * @param portName name of port for check
     * @return true if port can be open, false otherwise
     */
    static bool portCanBeOpen(const QString& portName);

    /**
     * Send message to serial device. Emits deviceError in case of failure.
     * @param msg message to be written to device
     * @return true if message can be sent, otherwise false
     */
    bool sendMessage(const QByteArray msg) override;

signals:
    // signals only for internal use:
    // Qt5 private signals: https://woboq.com/blog/how-qt-signals-slots-work-part2-qt5.html
    void writeToPort(const QByteArray data, QPrivateSignal);

private slots:
    void readMessage();
    void handleError(QSerialPort::SerialPortError error);
    void handleWriteToPort(const QByteArray data);

private:
    bool sendMessage(const QByteArray msg, quintptr lockId) override;

    bool writeData(const QByteArray data, quintptr lockId);
    ErrorCode translateQSerialPortError(QSerialPort::SerialPortError error);

    QSerialPort serialPort_;
    std::string readBuffer_;  // std::string keeps allocated memory after clear(), this is why read_buffer_ is std::string
};

}  // namespace

#endif
