#pragma once

#include <Device/Device.h>

class DeviceMock : public strata::device::Device
{
    Q_OBJECT

public:
    DeviceMock();
    DeviceMock(const int deviceId, const QString& name);
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
    QByteArray mockGetLastMsg() {return lastMsg_;}
    int mockGetMsgCount() {return msgCount_;}
    quintptr mockGetLock() {return operationLock_;}

protected:
    virtual bool sendMessage(const QByteArray msg, quintptr lockId) override;

private:
    bool opened_ = false;
    QByteArray lastMsg_;
    int msgCount_ = 0;
};
