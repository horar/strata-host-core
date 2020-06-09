#include "DeviceMock.h"
#include "QtTest.h"

using strata::device::Device;

DeviceMock::DeviceMock()
    : Device(0, "Mock Device",
             Device::Type::SerialDevice)  // TODO maybe other type than SerialDevice?
{
}

DeviceMock::DeviceMock(const int deviceId, const QString &name)
    : Device(deviceId, name, Device::Type::SerialDevice)
{
}

bool DeviceMock::open()
{
    QVERIFY_(!opened_);
    opened_ = true;
    return true;
}

void DeviceMock::close()
{
    QVERIFY(opened_);
    opened_ = false;
}

bool DeviceMock::sendMessage(const QByteArray msg)
{
    lastMsg_ = msg;
    msgCount_++;
    emit messageSent(msg);
    return true;
}

bool DeviceMock::sendMessage(const QByteArray msg, quintptr)
{
    lastMsg_ = msg;
    msgCount_++;
    return true;
}

void DeviceMock::mockEmitMessage(std::string message)
{
    emit msgFromDevice(QByteArray::fromStdString(message));
}
