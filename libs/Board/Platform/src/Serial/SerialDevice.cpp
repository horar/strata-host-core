#include <Serial/SerialDevice.h>
#include "SerialDeviceConstants.h"

#include "logging/LoggingQtCategories.h"

#include <QHash>

#include <QMutexLocker>
#include <QReadLocker>
#include <QWriteLocker>

namespace strata::device {

constexpr std::chrono::milliseconds SERIAL_DEVICE_OPEN_RETRY_INTERVAL(1000);

SerialDevice::SerialDevice(const QByteArray& deviceId, const QString& name, int openRetries)
    : Device(deviceId, name, Type::SerialDevice)
{
    serialPort_ = std::make_unique<QSerialPort>(name);

    initSerialDevice(openRetries);
}

SerialDevice::SerialDevice(const QByteArray& deviceId, const QString& name, SerialPortPtr&& port, int openRetries)
    : Device(deviceId, name, Type::SerialDevice)
{
    if ((port != nullptr) && (port->portName() == name)) {
        serialPort_ = std::move(port);
    } else {
        qCWarning(logCategoryDeviceSerial).noquote()
            << "Provided port will not be used, is not compatible with device " << deviceId_;
        serialPort_ = std::make_unique<QSerialPort>(name);
    }

    initSerialDevice(openRetries);
}

SerialDevice::~SerialDevice() {
    SerialDevice::close();
    serialPort_.reset();
    qCDebug(logCategoryDeviceSerial).nospace().noquote()
        << "Deleted serial device, ID: " <<  deviceId_
        << ", unique ID: 0x" << hex << reinterpret_cast<quintptr>(this);
}

void SerialDevice::initSerialDevice(int openRetries) {
    readBuffer_.reserve(READ_BUFFER_SIZE);
    connected_ = false;
    openRetries_ = openRetries;

    serialPort_->setBaudRate(QSerialPort::Baud115200);
    serialPort_->setDataBits(QSerialPort::Data8);
    serialPort_->setParity(QSerialPort::NoParity);
    serialPort_->setStopBits(QSerialPort::OneStop);
    serialPort_->setFlowControl(QSerialPort::NoFlowControl);

    connect(serialPort_.get(), &QSerialPort::errorOccurred, this, &SerialDevice::handleError);
    connect(serialPort_.get(), &QSerialPort::readyRead, this, &SerialDevice::readMessage);

    openRetryTimer_.setSingleShot(true);
    openRetryTimer_.setInterval(SERIAL_DEVICE_OPEN_RETRY_INTERVAL);
    connect(&openRetryTimer_, &QTimer::timeout, this, &SerialDevice::open);

    qCDebug(logCategoryDeviceSerial).nospace().noquote()
        << "Created new serial device, ID: " << deviceId_ << ", name: '" << deviceName_
        << "', unique ID: 0x" << hex << reinterpret_cast<quintptr>(this);
}

void SerialDevice::open() {
    bool opened = false;

    if (serialPort_->isOpen()) {
        if ((serialPort_->openMode() & QIODevice::ReadWrite) == QIODevice::ReadWrite) {
            opened = true;
        } else {
            serialPort_->close();
        }
    }

    if (opened == false) {
        opened = serialPort_->open(QIODevice::ReadWrite);
        // if 'open' fails 'QSerialPort::errorOccurred' signal is emitted
    }
    connected_ = opened;

    if (opened) {
        serialPort_->clear(QSerialPort::AllDirections);
        emit Device::opened();
    }
    // There is no need to emit 'deviceError(ErrorCode::DeviceFailedToOpen)' when 'opened'
    // is 'false' because this error signal is already emmited from 'handleError()' method.
}

void SerialDevice::close() {
    if (openRetryTimer_.isActive()) {
        openRetryTimer_.stop();
    }
    if (serialPort_->isOpen()) {
        serialPort_->close();
    }
    connected_ = false;
}

SerialDevice::SerialPortPtr SerialDevice::establishPort(const QString& portName) {
    SerialPortPtr serialPort = std::make_unique<QSerialPort>(portName);
    serialPort->setBaudRate(QSerialPort::Baud115200);
    serialPort->setDataBits(QSerialPort::Data8);
    serialPort->setParity(QSerialPort::NoParity);
    serialPort->setStopBits(QSerialPort::OneStop);
    serialPort->setFlowControl(QSerialPort::NoFlowControl);

    if (serialPort->open(QIODevice::ReadWrite)) {
        return serialPort;
    }

    return nullptr;
}

QByteArray SerialDevice::createUniqueHash(const QString& portName)
{
    return QByteArray(QByteArray::number(qHash(portName), 16));
}

void SerialDevice::readMessage() {
    const QByteArray data = serialPort_->readAll();

    // messages from Strata boards ends with new line character
    int from = 0;
    int end;
    while ((end = data.indexOf('\n', from)) > -1) {
        ++end;
        readBuffer_.append(data.data() + from, static_cast<size_t>(end - from));
        from = end;

        // qCDebug(logCategoryDeviceSerial) << this << ": received message: " << QString::fromStdString(readBuffer_);
        emit messageReceived(QByteArray::fromStdString(readBuffer_));
        readBuffer_.clear();
        // std::string keeps allocated memory after clear(), this is why read_buffer_ is std::string
    }

    if (from < data.size()) {  // message contains some data after '\n' (or has no '\n')
        readBuffer_.append(data.data() + from, static_cast<size_t>(data.size() - from));
    }
}

unsigned SerialDevice::sendMessage(const QByteArray& data) {
    // Data cannot be written to serial port from another thread as
    // in which this SerialDevice object was created. Otherwise error
    // "QSocketNotifier: Socket notifiers cannot be enabled or disabled from another thread" occurs.

    unsigned msgNum = Device::nextMessageNumber();

    if (serialPort_->write(data) == data.size()) {
        emit messageSent(data, msgNum, QString());
    } else {
        QString errMsg(QStringLiteral("Cannot write whole data to device."));
        qCCritical(logCategoryDeviceSerial) << this << errMsg;
        emit messageSent(data, msgNum, errMsg);
    }

    return msgNum;
}

bool SerialDevice::isConnected() const
{
    return connected_;
}

void SerialDevice::resetReceiving()
{
    if (readBuffer_.empty() == false) {
        readBuffer_.clear();
        qCDebug(logCategoryDeviceSerial) << this << "Cleared internal buffer for reading of received messages.";
    }
}

void SerialDevice::setOpenRetries(int retries)
{
    openRetries_ = retries;
}

void SerialDevice::handleError(QSerialPort::SerialPortError error) {
    // https://doc.qt.io/qt-5/qserialport.html#SerialPortError-enum
    if (error == QSerialPort::NoError) {
        return;  // Do not emit error signal if there is no error.
    }

    QString errMsg = "Serial port error (" + QString::number(error) + "): " + serialPort_->errorString();
    switch (error) {
        case QSerialPort::PermissionError :
            // QSerialPort::open() has failed.
            qCWarning(logCategoryDeviceSerial) << this << errMsg << ". Unable to open serial port.";
            connected_ = false;
            if (openRetries_ == 0) {
                emit deviceError(ErrorCode::DeviceFailedToOpen, serialPort_->errorString());
            } else {
                if (openRetries_ > 0) {  // negative number (-1) = unlimited count of retries
                    --openRetries_;
                }
                qCInfo(logCategoryDeviceSerial) << this << "Another attempt to open the serial port will be in "
                    << SERIAL_DEVICE_OPEN_RETRY_INTERVAL.count() << " ms.";
                openRetryTimer_.start();

                emit deviceError(ErrorCode::DeviceFailedToOpenGoingToRetry, serialPort_->errorString());
            }
            break;
        case QSerialPort::ResourceError :
            // An I/O error occurred when a resource becomes unavailable, e.g. when the device is unexpectedly removed from the system.
            qCWarning(logCategoryDeviceSerial) << this << errMsg << " (Probably unexpectedly disconnected device.)";
            connected_ = false;
            emit deviceError(ErrorCode::DeviceDisconnected, serialPort_->errorString());
            break;
        default :
            qCCritical(logCategoryDeviceSerial) << this << errMsg;
            emit deviceError(ErrorCode::DeviceError, serialPort_->errorString());
            break;
    }
}

}  // namespace

