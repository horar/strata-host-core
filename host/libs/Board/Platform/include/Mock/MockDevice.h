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
     * Send message to mock device.
     * @param msg message to be written to device
     * @return true if message can be sent, otherwise false
     */
    virtual bool sendMessage(const QByteArray msg) override;

    // commands to control mock device behavior

    void mockEmitMessage(const QByteArray msg);
    void mockEmitResponses(const QByteArray msg);

    std::vector<QByteArray> mockGetRecordedMessages();
    std::vector<QByteArray>::size_type mockGetRecordedMessagesCount() const;
    void mockClearRecordedMessages();

    bool mockIsOpened() const;
    bool mockIsBootloader() const;
    bool mockIsLegacy() const;
    bool mockIsAutoResponse() const;
    MockCommand mockGetCommand() const;
    MockResponse mockGetResponse() const;

    bool mockSetLegacy(bool isLegacy);
    bool mockSetAutoResponse(bool autoResponse);
    bool mockSetSaveMessages(bool saveMessages);
    bool mockSetCommand(MockCommand command);
    bool mockSetResponse(MockResponse response);
    bool mockSetResponseForCommand(MockResponse response, MockCommand command);
    bool mockSetVersion(MockVersion version);

private:
    virtual bool sendMessage(const QByteArray msg, quintptr lockId) override;

private:
    bool opened_ = false;
    bool autoResponse_ = true;
    bool saveMessages_;
    std::list<QByteArray> recordedMessages_;
    MockDeviceControl control_;
};

}  // namespace strata::device
