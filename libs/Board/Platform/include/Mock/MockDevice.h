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
     * Send message to mock device.
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

    void mockEmitResponses(const QByteArray& msg);
    void mockEmitError(const ErrorCode& errCode, const QString& msg);

    std::vector<QByteArray> mockGetRecordedMessages() const;
    std::vector<QByteArray>::size_type mockGetRecordedMessagesCount() const;
    void mockClearRecordedMessages();

    bool mockIsOpenEnabled() const;
    bool mockIsLegacy() const;
    bool mockIsAutoResponse() const;
    bool mockIsBootloader() const;
    bool mockIsFirmwareEnabled() const;
    bool mockIsErrorOnCloseSet() const;
    bool mockIsErrorOnNthMessageSet() const;
    MockCommand mockGetCommand() const;
    MockResponse mockGetResponse() const;
    MockVersion mockGetVersion() const;

    bool mockSetOpenEnabled(bool enabled);
    bool mockSetLegacy(bool isLegacy);
    bool mockSetAutoResponse(bool autoResponse);
    bool mockSetSaveMessages(bool saveMessages);
    bool mockSetCommand(MockCommand command);
    bool mockSetResponse(MockResponse response);
    bool mockSetResponseForCommand(MockResponse response, MockCommand command);
    bool mockSetVersion(MockVersion version);
    bool mockSetAsBootloader(bool isBootloader);
    bool mockSetFirmwareEnabled(bool enabled);
    bool mockSetErrorOnClose(bool enabled);
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
