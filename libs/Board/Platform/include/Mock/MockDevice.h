/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <Device.h>
#include <Mock/MockDeviceControl.h>

namespace strata::device {

class MockDevice : public Device
{
    Q_OBJECT
    Q_DISABLE_COPY(MockDevice)

public:
    /**
     * MockDevice constructor
     * @param deviceId device ID
     * @param name device name
     */
    MockDevice(const QByteArray& deviceId, const QString& name, const bool saveMessages);

    /**
     * MockDevice destructor
     */
    ~MockDevice() override;

    /**
     * Open mock device
     * Emits opened() on success or deviceError(DeviceFailedToOpen, ...) on failure.
     */
    virtual void open() override;

    /**
     * Close mock device
     */
    virtual void close() override;

    /**
     * Creates unique hash for mock device, based on device name.
     * Will be used to generate device ID.
     * @param mockName name of the mock device
     * @return unique hash.
     */
    static QByteArray createUniqueHash(const QString& mockName);

    /**
     * Send message to mock device. Emits messageSent.
     * @param msg message to be written to device
     * @return serial number of the sent message
     */
    virtual unsigned sendMessage(const QByteArray& msg) override;

    /**
     * Check if mock device is connected (communication with it is possible).
     * @return true if device is connected, otherwise false
     */
    virtual bool isConnected() const override;

    /**
     * Reset receiving messages from device - this method does nothing for mock device.
     */
    virtual void resetReceiving() override;

    // commands to control mock device behavior

    /**
     * Force mock device to process the message and emit response (asynchronously)
     * Emits messageReceived() if there is a response to be sent
     * @param msg message to be processed
     */
    void mockEmitResponses(const QByteArray& msg);

    /**
     * Force mock device to emit error. Emits deviceError()
     * @param errCode error code
     * @param msg error description
     */
    void mockEmitError(const ErrorCode& errCode, const QString& msg);

    /**
     * Return the recorded messages received by mock device
     * @return recorded messages
     */
    std::vector<QByteArray> mockGetRecordedMessages() const;

    /**
     * Return size of the recorded messages received by mock device
     * @return size of recorded messages
     */
    std::vector<QByteArray>::size_type mockGetRecordedMessagesCount() const;

    /**
     * Clear all recorded messages saved by mock device
     */
    void mockClearRecordedMessages();

    /**
     * Check if mock device is allowed to open
     * @return true if allowed to open, otherwise false
     */
    bool mockIsOpenEnabled() const;

    /**
     * Check if mock device automatically responds to messages it receives
     * @return true if responds automatically, otherwise false
     */
    bool mockIsAutoResponse() const;

    /**
     * Check if mock device behaves as bootloader
     * @return true if behaves as bootloader, otherwise false
     */
    bool mockIsBootloader() const;

    /**
     * Check if mock device is allowed to have firmware
     * @return true if allowed to have firmware, otherwise false
     */
    bool mockIsFirmwareEnabled() const;

    /**
     * Check if mock device emits error on close
     * @return true if emits error, otherwise false
     */
    bool mockIsErrorOnCloseSet() const;

    /**
     * Check if mock device emits error on nth message it receives
     * @return true if emits error on nth message it receives, otherwise false
     */
    bool mockIsErrorOnNthMessageSet() const;

    /**
     * Returns which response is to be used for a particular command
     * @param command the particular command whose response should be returned
     * @return the special response used for a particular command
     */
    MockResponse mockGetResponseForCommand(MockCommand command) const;

    /**
     * Returns configured mock device version
     * @return mock device version
     */
    MockVersion mockGetVersion() const;

    /**
     * Configures if mock device is allowed to open
     * @param enabled true if allowed to open, otherwise false
     * @return true if parameter was changed, otherwise false
     */
    bool mockSetOpenEnabled(bool enabled);

    /**
     * Configures if mock device automatically responds to messages it receives
     * @note Use mockEmitResponses to send the responses manually
     * @param autoResponse true if responds automatically, otherwise false
     * @return true if parameter was changed, otherwise false
     */
    bool mockSetAutoResponse(bool autoResponse);

    /**
     * Configures if mock device saves messages it receives
     * @param saveMessages true if messages are saved, otherwise false
     * @return true if parameter was changed, otherwise false
     */
    bool mockSetSaveMessages(bool saveMessages);

    /**
     * Configures special response behavior for a particular command
     * @param response the special response used for a particular command
     * @param command the particular command with special response behavior
     * @return true if parameter was changed, otherwise false
     */
    bool mockSetResponseForCommand(MockResponse response, MockCommand command);

    /**
     * Adds notification which will be sent after particular command
     * @param notification the notification sent after a particular command
     * @param command the particular command after which will be sent notification
     */
    void mockAddNotificationAfterCommand(MockNotification notification, MockCommand command);

    /**
     * Configures mock device version (non-OTA / OTA)
     * @param version mock device version
     * @return true if parameter was changed, otherwise false
     */
    bool mockSetVersion(MockVersion version);

    /**
     * Configures if mock device behaves as bootloader
     * @param isBootloader true if bootloader, otherwise false
     * @return true if parameter was changed, otherwise false
     */
    bool mockSetAsBootloader(bool isBootloader);

    /**
     * Configures if mock device is allowed to have firmware
     * @param enabled true if allowed to have firmware, otherwise false
     * @return true if parameter was changed, otherwise false
     */
    bool mockSetFirmwareEnabled(bool enabled);

    /**
     * Configures if mock device emits error on close
     * @param enabled true if emits error, otherwise false
     * @return true if parameter was changed, otherwise false
     */
    bool mockSetErrorOnClose(bool enabled);

    /**
     * Configures if mock device emits write error on nth message it receives
     * After error is emitted, the counter starts from 0 again
     * @param messageNumber the nth message on which the error is to be emitted, (0 : disabled)
     * @return true if parameter was changed, otherwise false
     */
    bool mockSetWriteErrorOnNthMessage(unsigned messageNumber);

    /**
     * Generates mock firmware if needed for comparison in tests
     * @param isBootloader true = 10 chunks; false = 20 chunks of firmware, (default : false)
     * @return QByteArray of mockFirmware
     */
    QByteArray generateMockFirmware(bool isBootloader = false);

private slots:
    void readMessage(QByteArray msg);
    void handleError(strata::device::Device::ErrorCode errCode, QString msg);

private:
    bool opened_ = false;
    MockDeviceControl control_;
};

typedef std::shared_ptr<MockDevice> MockDevicePtr;

}  // namespace strata::device
