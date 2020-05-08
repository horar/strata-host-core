#include "SerialDevice.h"
#include "SerialDeviceConstants.h"

#include "logging/LoggingQtCategories.h"

#include <rapidjson/document.h>
#include <rapidjson/error/en.h>
#include <rapidjson/writer.h>

#include <QMutexLocker>
#include <QReadLocker>
#include <QWriteLocker>

namespace strata {

QDebug operator<<(QDebug dbg, const SerialDevice* d) {
    return dbg.nospace() << "Serial device 0x" << hex << static_cast<uint>(d->deviceId_) << ": ";
}

SerialDevice::SerialDevice(const int deviceId, const QString& name) :
    deviceId_(deviceId), portName_(name), operationLock_(0)
{
    readBuffer_.reserve(READ_BUFFER_SIZE);

    connect(&serialPort_, &QSerialPort::errorOccurred, this, &SerialDevice::handleError);
    connect(&serialPort_, &QSerialPort::readyRead, this, &SerialDevice::readMessage);
    connect(this, &SerialDevice::writeToPort, this, &SerialDevice::handleWriteToPort);

    qCDebug(logCategorySerialDevice).nospace() << "Created new serial device 0x" << hex << static_cast<uint>(deviceId_)
                                               << ", name: " << portName_ << ", unique ID: 0x" << reinterpret_cast<quintptr>(this);
}

SerialDevice::~SerialDevice() {
    close();
    qCDebug(logCategorySerialDevice).nospace() << "Deleted serial device 0x" << hex << static_cast<uint>(deviceId_)
                                               << ", unique ID: 0x" << reinterpret_cast<quintptr>(this);
}

bool SerialDevice::open() {
    if (serialPort_.isOpen()) {
        qCDebug(logCategorySerialDevice).nospace() << this << "Attempt to open already opened serial port.";
        return true;
    }

    serialPort_.setPortName(portName_);
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

        // qCDebug(logCategorySerialDevice).nospace().noquote() << this << ": received message: " << QString::fromStdString(readBuffer_);
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
    QMutexLocker lock(&operationMutex_);
    if (operationLock_ == lockId) {
        // * Slot connected to below emitted signal emits other signals
        //   and it should'n be locked. Also if we are here it is not necessary
        //   to lock writting to serial port because all writting happens in one thread.
        lock.unlock();

        // * Signal must be emitted because of calling this function from another
        //   thread as in which this SerialDevice object was created. Slot connected
        //   to this signal will be executed in correct thread.
        // * Data cannot be written to serial port from another thread (otherwise error
        //   "QSocketNotifier: Socket notifiers cannot be enabled or disabled from another thread" occurs).
        emit writeToPort(data, QPrivateSignal());
        return true;
    } else {
        QString errMsg(QStringLiteral("Cannot write to device because device is busy."));
        qCWarning(logCategorySerialDevice).noquote() << this << errMsg;
        // We do not want to emit signal in locked block of code.
        lock.unlock();
        emit serialDeviceError(-1, errMsg);
        return false;
    }
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
        qCCritical(logCategorySerialDevice).noquote() << this << errMsg;
        emit serialDeviceError(-1, errMsg);
    }
}

void SerialDevice::handleError(QSerialPort::SerialPortError error) {
    // https://doc.qt.io/qt-5/qserialport.html#SerialPortError-enum
    if (error != QSerialPort::NoError) {  // Do not emit error signal if there is no error.
        QString errMsg = "Serial port error (" + QString::number(error) + "): " + serialPort_.errorString();
        if (error == QSerialPort::ResourceError) {
            // board was unconnected from computer (cable was unplugged)
            qCWarning(logCategorySerialDevice).noquote() << this << ": " << errMsg << " (Probably unexpectedly disconnected device.)";
        }
        else {
            qCCritical(logCategorySerialDevice).noquote() << this << errMsg;
            emit serialDeviceError(error, serialPort_.errorString());
        }
    }
}

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

QString SerialDevice::property(DeviceProperties property) {
    QReadLocker rLock(&properiesLock_);
    switch (property) {
        case DeviceProperties::deviceName:
            return portName_;
        case DeviceProperties::verboseName :
            return verboseName_;
        case DeviceProperties::platformId :
            return platformId_;
        case DeviceProperties::classId :
            return classId_;
        case DeviceProperties::bootloaderVer :
            return bootloaderVer_;
        case DeviceProperties::applicationVer :
            return applicationVer_;
    }
    return QString();
}

int SerialDevice::deviceId() const {
    return deviceId_;
}

void SerialDevice::setProperties(const char* verboseName, const char* platformId, const char* classId, const char* btldrVer, const char* applVer) {
    QWriteLocker wLock(&properiesLock_);
    if (verboseName) { verboseName_ = verboseName; }
    if (platformId)  { platformId_ = platformId; }
    if (classId)     { classId_ = classId; }
    if (btldrVer)    { bootloaderVer_ = btldrVer; }
    if (applVer)     { applicationVer_ = applVer; }
}

bool SerialDevice::lockDeviceForOperation(quintptr lockId) {
    QMutexLocker lock(&operationMutex_);
    if (operationLock_ == 0 && lockId != 0) {
        operationLock_ = lockId;
        return true;
    }
    if (operationLock_ == lockId && lockId != 0) {
        return true;
    }
    return false;
}

void SerialDevice::unlockDevice(quintptr lockId) {
    QMutexLocker lock(&operationMutex_);
    if (operationLock_ == lockId) {
        operationLock_ = 0;
    }
}

}  // namespace
