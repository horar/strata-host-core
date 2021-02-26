#include <Device/Mock/MockDevice.h>

#include "logging/LoggingQtCategories.h"

#include <QTimer>

namespace strata::device::mock {

MockDevice::MockDevice(const int deviceId, const QString &name, const bool saveMessages)
    : Device(deviceId, name, Device::Type::MockDevice),
      saveMessages_(saveMessages)
{
    qCDebug(logCategoryMockDevice).nospace() << "Created new mock device 0x" << hex << static_cast<uint>(deviceId_)
                                             << ", name: " << deviceName_ << ", unique ID: 0x" << reinterpret_cast<quintptr>(this);
}

MockDevice::~MockDevice()
{
    MockDevice::close();
    qCDebug(logCategoryMockDevice).nospace() << "Deleted mock device 0x" << hex << static_cast<uint>(deviceId_)
                                             << ", unique ID: 0x" << reinterpret_cast<quintptr>(this);
}

bool MockDevice::open()
{
    if (opened_ == true) {
        qCWarning(logCategoryMockDevice) << this << "Attempt to open already opened mock port";
        return false;
    }

    opened_ = true;
    return true;
}

void MockDevice::close()
{
    if (opened_ == true) {
        opened_ = false;
    }
}

bool MockDevice::sendMessage(const QByteArray msg)
{
    qCDebug(logCategoryMockDevice) << this << "Received request:" << msg;
    if (saveMessages_) {
        if (recordedMessages_.size() >= MAX_STORED_MESSAGES) {
            qCWarning(logCategoryMockDevice) << this << "Maximum number (" << MAX_STORED_MESSAGES
                                             << ") of stored messages reached";
            recordedMessages_.pop_front();
        }

        recordedMessages_.push_back(msg);
    }

    emit messageSent(msg);
    if (autoResponse_) {
        mockEmitResponses(msg);
    }
    return true;
}

bool MockDevice::sendMessage(const QByteArray msg, quintptr)
{
    return sendMessage(msg);
}

void MockDevice::mockEmitMessage(const QByteArray msg)
{
    emit msgFromDevice(msg);
}

void MockDevice::mockEmitResponses(const QByteArray msg)
{
    auto responses = control_.getResponses(msg);
    for (const QByteArray& response : responses) {
        qCDebug(logCategoryMockDevice) << this << "Returning response:" << response;
        QTimer::singleShot(
            10, this, [=]() {  // deferred emit (if emitted in the same loop, may cause trouble)
                emit msgFromDevice(response);
            });
    }
}

std::vector<QByteArray> MockDevice::mockGetRecordedMessages()
{
    // copy the result, recordedMessages_ may change over time
    std::vector<QByteArray> result(recordedMessages_.size());
    std::copy(recordedMessages_.begin(), recordedMessages_.end(), result.begin());

    return result;
}

std::vector<QByteArray>::size_type MockDevice::mockGetRecordedMessagesCount() const
{
    return recordedMessages_.size();
}

void MockDevice::mockClearRecordedMessages()
{
    recordedMessages_.clear();
}

bool MockDevice::mockIsOpened() const
{
    return opened_;
}

bool MockDevice::mockIsBootloader() const
{
    return control_.mockIsBootloader();
}

bool MockDevice::mockIsLegacy() const
{
    return control_.mockIsLegacy();
}

bool MockDevice::mockIsAutoResponse() const
{
    return autoResponse_;
}

MockCommand MockDevice::mockGetCommand() const
{
    return control_.mockGetCommand();
}

MockResponse MockDevice::mockGetResponse() const
{
    return control_.mockGetResponse();
}

bool MockDevice::mockSetLegacy(bool isLegacy)
{
    return control_.mockSetLegacy(isLegacy);
}

bool MockDevice::mockSetAutoResponse(bool autoResponse)
{
    if (autoResponse_ != autoResponse) {
        autoResponse_ = autoResponse;
        return true;
    }
    return false;
}

bool MockDevice::mockSetSaveMessages(bool saveMessages)
{
    if (saveMessages_ != saveMessages) {
        saveMessages_ = saveMessages;
        return true;
    }
    return false;
}

bool MockDevice::mockSetCommand(MockCommand command)
{
    return control_.mockSetCommand(command);
}

bool MockDevice::mockSetResponse(MockResponse response)
{
    return control_.mockSetResponse(response);
}

bool MockDevice::mockSetResponseForCommand(MockResponse response, MockCommand command)
{
    return control_.mockSetResponseForCommand(response, command);
}

bool MockDevice::mockSetVersion(MockVersion version)
{
    return control_.mockSetVersion(version);
}

}  // namespace strata::device::mock

