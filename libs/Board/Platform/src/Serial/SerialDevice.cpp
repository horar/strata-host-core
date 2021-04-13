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

    serialPort_->setBaudRate(QSerialPort::Baud115200);
    serialPort_->setDataBits(QSerialPort::Data8);
    serialPort_->setParity(QSerialPort::NoParity);
    serialPort_->setStopBits(QSerialPort::OneStop);
    serialPort_->setFlowControl(QSerialPort::NoFlowControl);

    connect(serialPort_.get(), &QSerialPort::errorOccurred, this, &SerialDevice::handleError);
    connect(serialPort_.get(), &QSerialPort::readyRead, this, &SerialDevice::readMessage);
    connect(this, &SerialDevice::writeToPort, this, &SerialDevice::handleWriteToPort);

    qCDebug(logCategoryDeviceSerial).nospace().noquote()
        << "Created new serial device, ID: " << deviceId_ << ", name: '" << deviceName_
        << "', unique ID: 0x" << hex << reinterpret_cast<quintptr>(this);
}

bool SerialDevice::open() {
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
    }

    if (opened) {
        serialPort_->clear(QSerialPort::AllDirections);
    }

    return opened;
}

void SerialDevice::close() {
    if (serialPort_->isOpen()) {
        serialPort_->close();
    }
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

QByteArray SerialDevice::createDeviceId(const QString& portName)
{
    return QByteArray('s' + QByteArray::number(qHash(portName), 16));
}

void SerialDevice::readMessage() {
    const QByteArray data = serialPort_->readAll();

    // messages from Strata boards ends with new line character
    int from = 0;
    int end;
    while ((end = data.indexOf('\n', from)) > -1) {
        readBuffer_.append(data.data() + from, static_cast<size_t>(end - from));
        from = end + 1;  // +1 due to skip '\n'

        // qCDebug(logCategoryDeviceSerial) << this << ": received message: " << QString::fromStdString(readBuffer_);
        emit msgFromDevice(QByteArray::fromStdString(readBuffer_));
        readBuffer_.clear();
        // std::string keeps allocated memory after clear(), this is why read_buffer_ is std::string
    }

    if (from < data.size()) {  // message contains some data after '\n' (or has no '\n')
        readBuffer_.append(data.data() + from, static_cast<size_t>(data.size() - from));
    }
}

// public method
bool SerialDevice::sendMessage(const QByteArray msg) {
    return writeData(msg, 0);
}

// private method
bool SerialDevice::sendMessage(const QByteArray msg, quintptr lockId) {
    return writeData(msg, lockId);
}

bool SerialDevice::writeData(const QByteArray data, quintptr lockId) {
    bool canWrite = false;
    {
        QMutexLocker lock(&operationMutex_);
        if (operationLock_ == lockId) {
            canWrite = true;
        }
    }
    if (canWrite) {
        // * Slot connected to below emitted signal emits other signals
        //   and it should'n be locked. Also if we are here it is not necessary
        //   to lock writting to serial port because all writting happens in one thread.
        // * Signal must be emitted because of calling this function from another
        //   thread as in which this SerialDevice object was created. Slot connected
        //   to this signal will be executed in correct thread.
        // * Data cannot be written to serial port from another thread (otherwise error
        //   "QSocketNotifier: Socket notifiers cannot be enabled or disabled from another thread" occurs).
        emit writeToPort(data, QPrivateSignal());
        return true;
    } else {
        QString errMsg(QStringLiteral("Cannot write to device because device is busy."));
        qCWarning(logCategoryDeviceSerial) << this << errMsg;
        emit deviceError(ErrorCode::DeviceBusy, errMsg);
        return false;
    }
}

Device::ErrorCode SerialDevice::translateQSerialPortError(QSerialPort::SerialPortError error) {
    switch (error) {
        case QSerialPort::SerialPortError::NoError :
            return ErrorCode::NoError;
        case QSerialPort::SerialPortError::DeviceNotFoundError :
            return ErrorCode::SP_DeviceNotFoundError;
        case QSerialPort::SerialPortError::PermissionError :
            return ErrorCode::SP_PermissionError;
        case QSerialPort::SerialPortError::OpenError :
            return ErrorCode::SP_OpenError;
        case QSerialPort::SerialPortError::ParityError :
            return ErrorCode::SP_ParityError;
        case QSerialPort::SerialPortError::FramingError :
            return ErrorCode::SP_FramingError;
        case QSerialPort::SerialPortError::BreakConditionError :
            return ErrorCode::SP_BreakConditionError;
        case QSerialPort::SerialPortError::WriteError :
            return ErrorCode::SP_WriteError;
        case QSerialPort::SerialPortError::ReadError :
            return ErrorCode::SP_ReadError;
        case QSerialPort::SerialPortError::ResourceError :
            return ErrorCode::SP_ResourceError;
        case QSerialPort::SerialPortError::UnsupportedOperationError :
            return ErrorCode::SP_UnsupportedOperationError;
        case QSerialPort::SerialPortError::UnknownError :
            return ErrorCode::SP_UnknownError;
        case QSerialPort::SerialPortError::TimeoutError :
            return ErrorCode::SP_TimeoutError;
        case QSerialPort::SerialPortError::NotOpenError :
            return ErrorCode::SP_NotOpenError;
    }
    return ErrorCode::UndefinedError;
}

void SerialDevice::handleWriteToPort(const QByteArray data) {
    qint64 writtenBytes = serialPort_->write(data);
    qint64 dataSize = data.size();
    // Strata commands must end with '\n'
    if (data.endsWith('\n') == false) {
        writtenBytes += serialPort_->write("\n", 1);
        ++dataSize;
    }
    if (writtenBytes == dataSize) {
        emit messageSent(data);
    } else {
        QString errMsg(QStringLiteral("Cannot write whole data to device."));
        qCCritical(logCategoryDeviceSerial) << this << errMsg;
        emit deviceError(ErrorCode::SendMessageError, errMsg);
    }
}

void SerialDevice::handleError(QSerialPort::SerialPortError error) {
    // https://doc.qt.io/qt-5/qserialport.html#SerialPortError-enum
    if (error != QSerialPort::NoError) {  // Do not emit error signal if there is no error.
        QString errMsg = "Serial port error (" + QString::number(error) + "): " + serialPort_->errorString();
        if (error == QSerialPort::ResourceError) {
            // board was unconnected from computer (cable was unplugged)
            qCWarning(logCategoryDeviceSerial) << this << ": " << errMsg << " (Probably unexpectedly disconnected device.)";
        }
        else {
            qCCritical(logCategoryDeviceSerial) << this << errMsg;
        }
        emit deviceError(translateQSerialPortError(error), serialPort_->errorString());
    }
}

}  // namespace

