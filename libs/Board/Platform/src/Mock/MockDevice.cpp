/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <Mock/MockDevice.h>
#include "logging/LoggingQtCategories.h"

namespace strata::device {

MockDevice::MockDevice(const QByteArray& deviceId, const QString &name, const bool saveMessages)
    : Device(deviceId, name, Device::Type::MockDevice),
      control_(saveMessages)
{
    qCDebug(lcDeviceMock).nospace().noquote()
        << "Created new mock device, ID: " << deviceId_ << ", name: " << deviceName_
        << ", unique ID: 0x" << hex << reinterpret_cast<quintptr>(this);

    connect(&control_, &MockDeviceControl::errorOccurred, this, &MockDevice::handleError);
    connect(&control_, &MockDeviceControl::messageDispatched, this, &MockDevice::readMessage);
}

MockDevice::~MockDevice()
{
    MockDevice::close();
    qCDebug(lcDeviceMock).nospace().noquote()
        << "Deleted mock device, ID: " <<  deviceId_
        << ", unique ID: 0x" << hex << reinterpret_cast<quintptr>(this);
}

void MockDevice::open()
{
    if (opened_ == true) {
        qCWarning(lcDeviceMock) << this << "Attempt to open already opened mock port";
    } else {
        opened_ = mockIsOpenEnabled();
    }

    if (opened_) {
        emit Device::opened();
    } else {
        emit Device::deviceError(device::Device::ErrorCode::DeviceFailedToOpenGoingToRetry, "Unable to open mock device (mockSetOpenEnabled set to false).");
    }
}

void MockDevice::close()
{
    if (opened_) {
        opened_ = false;
        mockClearRecordedMessages();

        if (mockIsErrorOnCloseSet()) {
            QString errMsg(QStringLiteral("Unable to properly close mock device (mockSetErrorOnClose set to true)."));
            qCWarning(lcDeviceMock) << this << errMsg;
            emit deviceError(ErrorCode::DeviceError, errMsg);
        }
    }
}

QByteArray MockDevice::createUniqueHash(const QString& mockName)
{
    return QByteArray(QByteArray::number(qHash(mockName), 16));
}

unsigned MockDevice::sendMessage(const QByteArray& msg)
{
    unsigned msgNum = Device::nextMessageNumber();

    if (opened_ == false) {
        QString errMsg(QStringLiteral("Cannot write data to device, device is not open."));
        qCCritical(lcDeviceMock) << this << errMsg;
        emit messageSent(msg, msgNum, errMsg);
        return msgNum;
    }

    qCDebug(lcDeviceMock) << this << "Received request:" << msg;

    if (control_.writeMessage(msg) == msg.size()) {
        emit messageSent(msg, msgNum, QString());
        if (mockIsAutoResponse()) {
            mockEmitResponses(msg);
        }
    } else {
        QString errMsg(QStringLiteral("Cannot write message to device (mockSetWriteErrorOnNthMessage enabled)."));
        qCWarning(lcDeviceSerial) << this << errMsg;
        emit messageSent(msg, msgNum, errMsg);
    }
    return msgNum;
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
    qCDebug(lcDeviceMock) << this << "Returning response:" << msg;
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

MockResponse MockDevice::mockGetResponseForCommand(MockCommand command) const
{
    return control_.getResponseForCommand(command);
}

MockVersion MockDevice::mockGetVersion() const
{
    return control_.getVersion();
}

bool MockDevice::mockSetOpenEnabled(bool enabled)
{
    return control_.setOpenEnabled(enabled);
}

bool MockDevice::mockSetAutoResponse(bool autoResponse)
{
    return control_.setAutoResponse(autoResponse);
}

bool MockDevice::mockSetSaveMessages(bool saveMessages)
{
    return control_.setSaveMessages(saveMessages);
}

bool MockDevice::mockSetResponseForCommand(MockResponse response, MockCommand command)
{
    return control_.setResponseForCommand(response, command);
}

void MockDevice::mockAddNotificationAfterCommand(MockNotification notification, MockCommand command)
{
    control_.addNotificationAfterCommand(notification, command);
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

QByteArray MockDevice::generateMockFirmware(bool isBootloader)
{
    return control_.generateMockFirmware(isBootloader);
}

}  // namespace strata::device

