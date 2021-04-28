#pragma once

#include <chrono>

#include "BasePlatformCommand.h"

namespace strata::platform::command {

// This is special command used for waiting between commands in command list.
// This command has also its own implementation of sendCommand method.

class CmdWait : public BasePlatformCommand
{
public:
    CmdWait(const PlatformPtr& platform,
            std::chrono::milliseconds waitTime,
            const QString& description);

    void sendCommand(quintptr lockId) override;
    QByteArray message() override;
    bool processNotification(const rapidjson::Document& doc, CommandResult& result) override;
    CommandResult onTimeout() override;

    void setWaitTime(std::chrono::milliseconds waitTime);

private slots:
    void deviceErrorOccured(QByteArray deviceId, device::Device::ErrorCode errCode, QString errStr);

private:
    std::chrono::milliseconds waitTime_;
    QString description_;
};

}  // namespace
