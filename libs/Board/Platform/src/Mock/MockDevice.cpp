#include <Mock/MockDevice.h>
#include "logging/LoggingQtCategories.h"

namespace strata::device {

MockDevice::MockDevice(const QByteArray& deviceId, const QString &name, const bool saveMessages)
    : Device(deviceId, name, Device::Type::MockDevice),
      control_(saveMessages)
{
    qCDebug(logCategoryDeviceMock).nospace().noquote()
        << "Created new mock device, ID: " << deviceId_ << ", name: " << deviceName_
        << ", unique ID: 0x" << hex << reinterpret_cast<quintptr>(this);

    connect(&control_, &MockDeviceControl::errorOccurred, this, &MockDevice::handleError);
    connect(&control_, &MockDeviceControl::messageDispatched, this, &MockDevice::readMessage);
}

MockDevice::~MockDevice()
{
    MockDevice::close();
    qCDebug(logCategoryDeviceMock).nospace().noquote()
        << "Deleted mock device, ID: " <<  deviceId_
        << ", unique ID: 0x" << hex << reinterpret_cast<quintptr>(this);
}

void MockDevice::open()
{
    if (opened_ == true) {
        qCWarning(logCategoryDeviceMock) << this << "Attempt to open already opened mock port";
    } else {
        opened_ = mockIsOpenEnabled();
    }

    if (opened_) {
        emit Device::opened();
    } else {
        emit Device::deviceError(device::Device::ErrorCode::DeviceFailedToOpen, "Unable to open mock device (mockSetOpenEnabled set to true).");
    }
}

void MockDevice::close()
{
    if (opened_) {
        opened_ = false;
        mockClearRecordedMessages();

        if (mockIsErrorOnCloseSet()) {
            QString errMsg(QStringLiteral("Unable to properly close mock device (mockSetErrorOnClose set to true)."));
            qCWarning(logCategoryDeviceMock) << this << errMsg;
            emit deviceError(ErrorCode::DeviceError, errMsg);
        }
    }
}

QByteArray MockDevice::createDeviceId(const QString& mockName)
{
    return QByteArray('m' + QByteArray::number(qHash(mockName), 16));
}

void MockDevice::sendMessage(const QByteArray& msg)
{
    if (opened_ == false) {
        QString errMsg(QStringLiteral("Cannot write data to device, device is not open."));
        qCCritical(logCategoryDeviceMock) << this << errMsg;
        emit messageSent(msg, errMsg);
        return;
    }

    qCDebug(logCategoryDeviceMock) << this << "Received request:" << msg;

    if (control_.writeMessage(msg) == msg.size()) {
        emit messageSent(msg, QString());
        if (mockIsAutoResponse()) {
            mockEmitResponses(msg);
        }
    } else {
        QString errMsg(QStringLiteral("Cannot write message to device (mockSetWriteErrorOnNthMessage set to true)."));
        qCWarning(logCategoryDeviceSerial) << this << errMsg;
        emit messageSent(msg, errMsg);
    }
}

bool MockDevice::isConnected() const
{
    return opened_;
}

void MockDevice::resetReceiving()
{
    // nothing to do for mock device
    return;
}

void MockDevice::readMessage(QByteArray msg)
{
    qCDebug(logCategoryDeviceMock) << this << "Returning response:" << msg;
    emit messageReceived(msg);
}

void MockDevice::handleError(ErrorCode errCode, QString msg) {
    if (errCode != ErrorCode::NoError) {  // Do not emit error signal if there is no error.
        emit deviceError(errCode, msg);
    }
}

void MockDevice::mockEmitResponses(const QByteArray& msg)
{
    control_.emitResponses(msg);
}

void MockDevice::mockEmitError(const ErrorCode& errCode, const QString& msg)
{
    emit deviceError(errCode, msg);
}

std::vector<QByteArray> MockDevice::mockGetRecordedMessages() const
{
    return control_.getRecordedMessages();
}

std::vector<QByteArray>::size_type MockDevice::mockGetRecordedMessagesCount() const
{
    return control_.getRecordedMessagesCount();
}

void MockDevice::mockClearRecordedMessages()
{
    return control_.clearRecordedMessages();
}

bool MockDevice::mockIsOpenEnabled() const
{
    return control_.isOpenEnabled();
}

bool MockDevice::mockIsLegacy() const
{
    return control_.isLegacy();
}

bool MockDevice::mockIsAutoResponse() const
{
    return control_.isAutoResponse();
}

bool MockDevice::mockIsBootloader() const
{
    return control_.isBootloader();
}

bool MockDevice::mockIsFirmwareEnabled() const
{
    return control_.isFirmwareEnabled();
}

bool MockDevice::mockIsErrorOnCloseSet() const
{
    return control_.isErrorOnCloseSet();
}

bool MockDevice::mockIsErrorOnNthMessageSet() const
{
    return control_.isErrorOnNthMessageSet();
}

MockCommand MockDevice::mockGetCommand() const
{
    return control_.getCommand();
}

MockResponse MockDevice::mockGetResponse() const
{
    return control_.getResponse();
}

MockVersion MockDevice::mockGetVersion() const
{
    return control_.getVersion();
}

bool MockDevice::mockSetOpenEnabled(bool enabled)
{
    return control_.setOpenEnabled(enabled);
}

bool MockDevice::mockSetLegacy(bool isLegacy)
{
    return control_.setLegacy(isLegacy);
}

bool MockDevice::mockSetAutoResponse(bool autoResponse)
{
    return control_.setAutoResponse(autoResponse);
}

bool MockDevice::mockSetSaveMessages(bool saveMessages)
{
    return control_.setSaveMessages(saveMessages);
}

bool MockDevice::mockSetCommand(MockCommand command)
{
    return control_.setCommand(command);
}

bool MockDevice::mockSetResponse(MockResponse response)
{
    return control_.setResponse(response);
}

bool MockDevice::mockSetResponseForCommand(MockResponse response, MockCommand command)
{
    return control_.setResponseForCommand(response, command);
}

bool MockDevice::mockSetVersion(MockVersion version)
{
    return control_.setVersion(version);
}

bool MockDevice::mockSetAsBootloader(bool isBootloader)
{
    return control_.setAsBootloader(isBootloader);
}

bool MockDevice::mockSetFirmwareEnabled(bool enabled)
{
    return control_.setFirmwareEnabled(enabled);
}

bool MockDevice::mockSetErrorOnClose(bool enabled) {
    return control_.setErrorOnClose(enabled);
}

bool MockDevice::mockSetWriteErrorOnNthMessage(unsigned messageNumber) {
    return control_.setWriteErrorOnNthMessage(messageNumber);
}

}  // namespace strata::device

