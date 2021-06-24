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
     * Create ID for mock device
     * @param mockName name of the mock device
     * @return ID for mock device
     */
    static QByteArray createDeviceId(const QString& mockName);

    /**
     * Send message to mock device. Emits messageSent.
     * @param msg message to be written to device
     * @return true if message can be sent, otherwise false
     */
    virtual bool sendMessage(const QByteArray& msg) override;

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
     * Check if mock device behaves as very old board without 'get_firmware_info' command support
     * @return true if behaves as very old board, otherwise false
     */
    bool mockIsLegacy() const;

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
     * Returns which command has configured special response behavior
     * @return the particular command with special response behavior
     */
    MockCommand mockGetCommand() const;

    /**
     * Returns which response is to be used for a particular command
     * @return the special response used for a particular command
     */
    MockResponse mockGetResponse() const;

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
     * Configures if mock device behaves as very old board without 'get_firmware_info' command support
     * @param isLegacy true if behaves as very old board, otherwise false
     * @return true if parameter was changed, otherwise false
     */
    bool mockSetLegacy(bool isLegacy);

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
     * @param command the particular command with special response behavior
     * @return true if parameter was changed, otherwise false
     */
    bool mockSetCommand(MockCommand command);

    /**
     * Configures special response behavior for a particular command
     * @param response the special response used for a particular command
     * @return true if parameter was changed, otherwise false
     */
    bool mockSetResponse(MockResponse response);

    /**
     * Configures special response behavior for a particular command
     * @param response the special response used for a particular command
     * @param command the particular command with special response behavior
     * @return true if parameter was changed, otherwise false
     */
    bool mockSetResponseForCommand(MockResponse response, MockCommand command);

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
     * Configures if mock device emits error on nth message it receives
     * After error is emitted, the counter starts from 0 again
     * @param messageNumber the nth message on which the error is to be emitted, (0 : disabled)
     * @return true if parameter was changed, otherwise false
     */
    bool mockSetErrorOnNthMessage(unsigned messageNumber);

private slots:
    void readMessage(QByteArray msg);
    void handleError(ErrorCode errCode, QString msg);

private:
    bool opened_ = false;
    MockDeviceControl control_;
};

typedef std::shared_ptr<MockDevice> MockDevicePtr;

}  // namespace strata::device
