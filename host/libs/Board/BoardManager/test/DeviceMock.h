#pragma once

#include <CommandResponseMock.h>
#include <Device/Device.h>

class DeviceMock : public strata::device::Device
{
    Q_OBJECT

private:
    DeviceMock() = delete;

public:
    DeviceMock(const int deviceId, const QString& name);
    virtual ~DeviceMock();
    virtual bool open() override;
    virtual void close() override;
    /**
     * Send message to  device. Emits deviceError() signal in case of failure.
     * @param msg message to be written to device
     * @return true if message can be sent, otherwise false
     */
    virtual bool sendMessage(const QByteArray msg) override;

    void mockEmitMessage(std::string message);
    bool mockIsOpened() {return opened_;}
    std::vector<QByteArray> mockGetRecordedMessages() {return recordedMessages_;} //copy the result, recordedMessages_ may change over time
    void mockClearRecordedMessages() {recordedMessages_.clear();}
    int mockGetMsgCount() {return static_cast<int>(recordedMessages_.size());}
    quintptr mockGetLock() {return operationLock_;}
    void mockSetAutoResponse(bool autoResponse) {autoResponse_ = autoResponse;}
    void mockEmitResponses(const QByteArray msg);
    bool mockIsBootloader() {return commandResponseMock_.mockIsBootloader();}
    void mockSetLegacy(bool isLegacy) { commandResponseMock_.mockSetLegacy(isLegacy); }
    void mockSetCommandForResponse(CommandResponseMock::Command command, CommandResponseMock::MockResponse response) { commandResponseMock_.mockSetCommandForResponse(command, response); }
    void mockSetResponse(CommandResponseMock::MockResponse response) { commandResponseMock_.mockSetResponse(response); }

protected:
    virtual bool sendMessage(const QByteArray msg, quintptr lockId) override;

private:
    bool opened_ = false;
    std::vector<QByteArray> recordedMessages_;
    bool autoResponse_ = true;
    CommandResponseMock commandResponseMock_;
};
