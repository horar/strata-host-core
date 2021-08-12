#include <Serial/SerialDevice.h>
#include "SerialDeviceConstants.h"

#include "logging/LoggingQtCategories.h"

#include <QHash>

#include <QMutexLocker>
#include <QReadLocker>
#include <QWriteLocker>

namespace strata::device {

SerialDevice::SerialDevice(const QByteArray& deviceId, const QString& name)
    : Device(deviceId, name, Type::SerialDevice)
{
    serialPort_ = std::make_unique<QSerialPort>(name);

    initSerialDevice();
}

SerialDevice::SerialDevice(const QByteArray& deviceId, const QString& name, SerialPortPtr&& port)
    : Device(deviceId, name, Type::SerialDevice)
{
    if ((port != nullptr) && (port->portName() == name)) {
        serialPort_ = std::move(port);
    } else {
        qCWarning(logCategoryDeviceSerial).noquote()
            << "Provided port will not be used, is not compatible with device " << deviceId_;
        serialPort_ = std::make_unique<QSerialPort>(name);
    }

    initSerialDevice();
}

SerialDevice::~SerialDevice() {
    SerialDevice::close();
    serialPort_.reset();
    qCDebug(logCategoryDeviceSerial).nospace().noquote()
        << "Deleted serial device, ID: " <<  deviceId_
        << ", unique ID: 0x" << hex << reinterpret_cast<quintptr>(this);
}

void SerialDevice::initSerialDevice() {
    readBuffer_.reserve(READ_BUFFER_SIZE);
    connected_ = false;

    serialPort_->setBaudRate(QSerialPort::Baud115200);
    serialPort_->setDataBits(QSerialPort::Data8);
    serialPort_->setParity(QSerialPort::NoParity);
    serialPort_->setStopBits(QSerialPort::OneStop);
    serialPort_->setFlowControl(QSerialPort::NoFlowControl);

    connect(serialPort_.get(), &QSerialPort::errorOccurred, this, &SerialDevice::handleError);
    connect(serialPort_.get(), &QSerialPort::readyRead, this, &SerialDevice::readMessage);

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
    // There is no need to emit 'deviceError(ErrorCode::DeviceFailedToOpenRequestRetry)' when 'opened'
    // is 'false' because this error signal is already emmited from 'handleError()' method.
}

void SerialDevice::close() {
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

Device::ErrorCode SerialDevice::translateQSerialPortError(QSerialPort::SerialPortError error) {
    switch (error) {
        case QSerialPort::SerialPortError::NoError :
            return ErrorCode::NoError;
        case QSerialPort::SerialPortError::PermissionError :
            return ErrorCode::DeviceFailedToOpenRequestRetry;
        case QSerialPort::SerialPortError::ResourceError :
            return ErrorCode::DeviceDisconnected;
        case QSerialPort::SerialPortError::DeviceNotFoundError :
        case QSerialPort::SerialPortError::OpenError :
        case QSerialPort::SerialPortError::ParityError :
        case QSerialPort::SerialPortError::FramingError :
        case QSerialPort::SerialPortError::BreakConditionError :
        case QSerialPort::SerialPortError::WriteError :
        case QSerialPort::SerialPortError::ReadError :
        case QSerialPort::SerialPortError::UnsupportedOperationError :
        case QSerialPort::SerialPortError::UnknownError :
        case QSerialPort::SerialPortError::TimeoutError :
        case QSerialPort::SerialPortError::NotOpenError :
            return ErrorCode::DeviceError;
        default:
            return ErrorCode::DeviceError;
    }
}

void SerialDevice::handleError(QSerialPort::SerialPortError error) {
    // https://doc.qt.io/qt-5/qserialport.html#SerialPortError-enum
    if (error != QSerialPort::NoError) {  // Do not emit error signal if there is no error.
        QString errMsg = "Serial port error (" + QString::number(error) + "): " + serialPort_->errorString();
        switch (error) {
            case QSerialPort::PermissionError :
                // QSerialPort::open() has failed
                qCWarning(logCategoryDeviceSerial) << this << errMsg << ". Unable to open serial port.";
                connected_ = false;
                break;
            case QSerialPort::ResourceError :
                // board was unconnected from computer (cable was unplugged)
                qCWarning(logCategoryDeviceSerial) << this << errMsg << " (Probably unexpectedly disconnected device.)";
                connected_ = false;
                break;
            default :
                qCCritical(logCategoryDeviceSerial) << this << errMsg;
                break;
        }
        emit deviceError(translateQSerialPortError(error), serialPort_->errorString());
    }
}

}  // namespace

