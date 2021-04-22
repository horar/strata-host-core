#include <Mock/MockDevice.h>

#include "logging/LoggingQtCategories.h"

#include <QTimer>

namespace strata::device {

MockDevice::MockDevice(const QByteArray& deviceId, const QString &name, const bool saveMessages)
    : Device(deviceId, name, Device::Type::MockDevice),
      saveMessages_(saveMessages)
{
    qCDebug(logCategoryDeviceMock).nospace().noquote()
        << "Created new mock device, ID: " << deviceId_ << ", name: " << deviceName_
        << ", unique ID: 0x" << hex << reinterpret_cast<quintptr>(this);
}

MockDevice::~MockDevice()
{
    MockDevice::close();
    qCDebug(logCategoryDeviceMock).nospace().noquote()
        << "Deleted mock device, ID: " <<  deviceId_
        << ", unique ID: 0x" << hex << reinterpret_cast<quintptr>(this);
}

bool MockDevice::open()
{
    if (opened_ == true) {
        qCWarning(logCategoryDeviceMock) << this << "Attempt to open already opened mock port";
        return true;
    }

    opened_ = mockIsOpenEnabled();

    return opened_;
}

void MockDevice::close()
{
    opened_ = false;
    recordedMessages_.clear();
}

QByteArray MockDevice::createDeviceId(const QString& mockName)
{
    return QByteArray('m' + QByteArray::number(qHash(mockName), 16));
}

bool MockDevice::sendMessage(const QByteArray msg)
{
    if (opened_ == false) {
        return false;
    }

    qCDebug(logCategoryDeviceMock) << this << "Received request:" << msg;
    if (saveMessages_) {
        if (recordedMessages_.size() >= MAX_STORED_MESSAGES) {
            qCWarning(logCategoryDeviceMock) << this << "Maximum number (" << MAX_STORED_MESSAGES
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

bool MockDevice::isConnected() const
{
    return opened_;
}

void MockDevice::mockEmitMessage(const QByteArray msg)
{
    emit messageReceived(msg);
}

void MockDevice::mockEmitResponses(const QByteArray msg)
{
    auto responses = control_.getResponses(msg);
    QTimer::singleShot(
                10, this, [=]() {
        for (const QByteArray& response : responses) { // deferred emit (if emitted in the same loop, may cause trouble)
            qCDebug(logCategoryDeviceMock) << this << "Returning response:" << response;
            emit messageReceived(response);
        }
    });
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

bool MockDevice::mockIsOpenEnabled() const
{
    return control_.mockIsOpenEnabled();
}

bool MockDevice::mockIsLegacy() const
{
    return control_.mockIsLegacy();
}

bool MockDevice::mockIsBootloader() const
{
    return control_.mockIsBootloader();
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

bool MockDevice::mockSetOpenEnabled(bool enabled)
{
    return control_.mockSetOpenEnabled(enabled);
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

}  // namespace strata::device

