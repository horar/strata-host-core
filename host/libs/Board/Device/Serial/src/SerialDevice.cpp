#include <Device/Serial/SerialDevice.h>
#include "SerialDeviceConstants.h"

#include "logging/LoggingQtCategories.h"

#include <QMutexLocker>
#include <QReadLocker>
#include <QWriteLocker>

namespace strata::device::serial {

SerialDevice::SerialDevice(const int deviceId, const QString& name) : Device(deviceId, name, Type::SerialDevice)
{
    readBuffer_.reserve(READ_BUFFER_SIZE);

    connect(&serialPort_, &QSerialPort::errorOccurred, this, &SerialDevice::handleError);
    connect(&serialPort_, &QSerialPort::readyRead, this, &SerialDevice::readMessage);
    connect(this, &SerialDevice::writeToPort, this, &SerialDevice::handleWriteToPort);

    qCDebug(logCategorySerialDevice).nospace() << "Created new serial device 0x" << hex << static_cast<uint>(deviceId_)
                                               << ", name: " << deviceName_ << ", unique ID: 0x" << reinterpret_cast<quintptr>(this);
}

SerialDevice::~SerialDevice() {
    close();
    qCDebug(logCategorySerialDevice).nospace() << "Deleted serial device 0x" << hex << static_cast<uint>(deviceId_)
                                               << ", unique ID: 0x" << reinterpret_cast<quintptr>(this);
}

bool SerialDevice::open() {
    if (serialPort_.isOpen()) {
        qCDebug(logCategorySerialDevice) << this << "Attempt to open already opened serial port.";
        return true;
    }

    serialPort_.setPortName(deviceName_);
    serialPort_.setBaudRate(QSerialPort::Baud115200);
    serialPort_.setDataBits(QSerialPort::Data8);
    serialPort_.setParity(QSerialPort::NoParity);
    serialPort_.setStopBits(QSerialPort::OneStop);
    serialPort_.setFlowControl(QSerialPort::NoFlowControl);

    bool opened = serialPort_.open(QIODevice::ReadWrite);
    if (opened) {
        serialPort_.clear(QSerialPort::AllDirections);
    }
    return opened;
}

void SerialDevice::close() {
    if (serialPort_.isOpen()) {
        serialPort_.close();
    }
}

void SerialDevice::readMessage() {
    const QByteArray data = serialPort_.readAll();

    // messages from Strata boards ends with new line character
    int from = 0;
    int end;
    while ((end = data.indexOf('\n', from)) > -1) {
        readBuffer_.append(data.data() + from, static_cast<size_t>(end - from));
        from = end + 1;  // +1 due to skip '\n'

        // qCDebug(logCategorySerialDevice) << this << ": received message: " << QString::fromStdString(readBuffer_);
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
        qCWarning(logCategorySerialDevice) << this << errMsg;
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
    qint64 writtenBytes = serialPort_.write(data);
    qint64 dataSize = data.size();
    // Strata commands must end with '\n'
    if (data.endsWith('\n') == false) {
        writtenBytes += serialPort_.write("\n", 1);
        ++dataSize;
    }
    if (writtenBytes == dataSize) {
        emit messageSent(data);
    } else {
        QString errMsg(QStringLiteral("Cannot write whole data to device."));
        qCCritical(logCategorySerialDevice) << this << errMsg;
        emit deviceError(ErrorCode::SendMessageError, errMsg);
    }
}

void SerialDevice::handleError(QSerialPort::SerialPortError error) {
    // https://doc.qt.io/qt-5/qserialport.html#SerialPortError-enum
    if (error != QSerialPort::NoError) {  // Do not emit error signal if there is no error.
        QString errMsg = "Serial port error (" + QString::number(error) + "): " + serialPort_.errorString();
        if (error == QSerialPort::ResourceError) {
            // board was unconnected from computer (cable was unplugged)
            qCWarning(logCategorySerialDevice) << this << ": " << errMsg << " (Probably unexpectedly disconnected device.)";
        }
        else {
            qCCritical(logCategorySerialDevice) << this << errMsg;
        }
        emit deviceError(translateQSerialPortError(error), serialPort_.errorString());
    }
}

// DEPRECATED
QVariantMap SerialDevice::getDeviceInfo() {
    QReadLocker rLock(&properiesLock_);
    QVariantMap result;
    result.insert(QStringLiteral("connectionId"), deviceId_);
    result.insert(QStringLiteral("platformId"), platformId_);
    result.insert(QStringLiteral("classId"), classId_);
    result.insert(QStringLiteral("verboseName"), verboseName_);
    result.insert(QStringLiteral("bootloaderVersion"), bootloaderVer_);
    result.insert(QStringLiteral("applicationVersion"), applicationVer_);

    return result;
}

}  // namespace

