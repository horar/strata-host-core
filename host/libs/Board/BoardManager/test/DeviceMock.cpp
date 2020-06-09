#include "DeviceMock.h"
#include "QtTest.h"

using strata::device::Device;

DeviceMock::DeviceMock(const int deviceId, const QString &name)
    : Device(deviceId, name, Device::Type::SerialDevice)
{
}

DeviceMock::~DeviceMock()
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

void DeviceMock::mockEmitResponses(const QByteArray msg)
{
    auto responses = commandResponseMock_.getResponses(msg);
    for (auto response : responses) {
        QTimer::singleShot(
            10, this, [=]() {  // deferred emit (if emitted in the same loop, may cause trouble)
                emit msgFromDevice(response);
            });
    }
}

bool DeviceMock::sendMessage(const QByteArray msg)
{
    recordedMessages_.push_back(msg);
    emit messageSent(msg);
    if (autoResponse_) {
        mockEmitResponses(msg);
    }
    return true;
}

bool DeviceMock::sendMessage(const QByteArray msg, quintptr)
{
    return sendMessage(msg);
}

void DeviceMock::mockEmitMessage(std::string message)
{
    emit msgFromDevice(QByteArray::fromStdString(message));
}
