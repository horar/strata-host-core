#include "SerialDevice.h"
#include "SerialDeviceConstants.h"

#include "logging/LoggingQtCategories.h"

#include <CommandValidator.h>

#include <rapidjson/document.h>
#include <rapidjson/error/en.h>
#include <rapidjson/writer.h>


namespace strata {

QDebug operator<<(QDebug dbg, const SerialDevice* d) {
    return dbg.nospace() << "Serial device 0x" << hex << static_cast<uint>(d->deviceId_);
}

SerialDevice::SerialDevice(const int deviceId, const QString& name) :
    deviceId_(deviceId), portName_(name), deviceBusy_(false)
{
    readBuffer_.reserve(READ_BUFFER_SIZE);

    connect(&serialPort_, &QSerialPort::errorOccurred, this, &SerialDevice::handleError);
    connect(&serialPort_, &QSerialPort::readyRead, this, &SerialDevice::readMessage);
    connect(this, &SerialDevice::writeToPort, this, &SerialDevice::writeData);

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

void SerialDevice::write(const QByteArray& data) {
    emit writeToPort(data, QPrivateSignal());
}

void SerialDevice::writeData(const QByteArray& data) {
    if (deviceBusy_) {  // Device is busy -> device identification is still running.
        qCDebug(logCategorySerialDevice) << this << ": Cannot write to device because device is busy.";
        emit serialDeviceError(QStringLiteral("Cannot write to device because device is busy."));
    }
    else {
        qint64 writtenBytes = serialPort_.write(data);
        qint64 dataSize = data.size();
        // Strata commands must end with '\n'
        if (data.endsWith('\n') == false) {
            writtenBytes += serialPort_.write("\n", 1);
            ++dataSize;
        }
        if (writtenBytes != dataSize) {
            qCCritical(logCategorySerialDevice) << this << ": Cannot write whole data to device.";
            emit serialDeviceError(QStringLiteral("Cannot write whole data to device."));
        }
    }
}

void SerialDevice::handleError(QSerialPort::SerialPortError error) {
    // https://doc.qt.io/qt-5/qserialport.html#SerialPortError-enum
    if (error != QSerialPort::NoError) {  // Do not emit error signal if there is no error.
        QString errMsg = "Serial port error (" + QString::number(error) + "): " + serialPort_.errorString();
        if (error == QSerialPort::ResourceError) {
            // board was unconnected from computer (cable was unplugged)
            qCWarning(logCategorySerialDevice).noquote() << this << ": " << err_msg << " (Probably unexpectedly disconnected device.)";
        }
        else {
            qCCritical(logCategorySerialDevice).noquote() << this << ": " << errMsg;
            emit serialDeviceError(errMsg);
        }
    }
}

QVariantMap SerialDevice::getDeviceInfo() const {
    QVariantMap result;
    result.insert(QStringLiteral("connectionId"), deviceId_);
    if (deviceBusy_ == false) {
        result.insert(QStringLiteral("platformId"), platformId_);
        result.insert(QStringLiteral("classId"), classId_);
        result.insert(QStringLiteral("verboseName"), verboseName_);
        result.insert(QStringLiteral("bootloaderVersion"), bootloaderVer_);
        result.insert(QStringLiteral("applicationVersion"), applicationVer_);
    }
    return result;
}

QString SerialDevice::getProperty(DeviceProperties property) const {
    if (property == DeviceProperties::deviceName) {
        return portName_;
    }

    if (deviceBusy_ == false) {
        switch (property) {
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
            default:
                break;
        }
    }

    // Device is busy (device identification is still running) or property is not supported.
    return QString();
}

int SerialDevice::getDeviceId() const {
    return deviceId_;
}

void SerialDevice::setProperties(const char* verboseName, const char* platformId, const char* classId, const char* btldrVer, const char* applVer) {
    if (verboseName) { verboseName_ = verboseName; }
    if (platformId)  { platformId_ = platformId; }
    if (classId)     { classId_ = classId; }
    if (btldrVer)    { bootloaderVer_ = btldrVer; }
    if (applVer)     { applicationVer_ = applVer; }
}

}  // namespace
