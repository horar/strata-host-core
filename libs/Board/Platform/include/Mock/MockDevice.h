#pragma once

#include <Device.h>
#include <Mock/MockDeviceControl.h>
#include <list>

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
     * @return true if port was opened, otherwise false
     */
    virtual bool open() override;

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

    // commands to control mock device behavior

    void mockEmitMessage(const QByteArray& msg);
    void mockEmitResponses(const QByteArray& msg);

    std::vector<QByteArray> mockGetRecordedMessages();
    std::vector<QByteArray>::size_type mockGetRecordedMessagesCount() const;
    void mockClearRecordedMessages();

    bool mockIsOpened() const;
    bool mockIsOpenEnabled() const;
    bool mockIsLegacy() const;
    bool mockIsBootloader() const;
    bool mockIsAutoResponse() const;
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
    bool mockCreateMockFirmware(bool createFirmware);

private:
    bool opened_ = false;
    bool autoResponse_ = true;
    bool saveMessages_;
    std::list<QByteArray> recordedMessages_;
    MockDeviceControl control_;
};

typedef std::shared_ptr<MockDevice> MockDevicePtr;

}  // namespace strata::device
