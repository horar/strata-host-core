#pragma once

#include <chrono>

#include "BaseDeviceCommand.h"

namespace strata::device::command {

// This is special command used for waiting between commands in command list.
// This command has also its own implementation of sendCommand method.

class CmdWait : public BaseDeviceCommand
{
public:
    CmdWait(const device::DevicePtr& device,
            std::chrono::milliseconds waitTime,
            const QString& description);

    void sendCommand(quintptr lockId) override;
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc, CommandResult& result) override;
    CommandResult onTimeout() override;

    void setWaitTime(std::chrono::milliseconds waitTime);

private:
    std::chrono::milliseconds waitTime_;
    QString description_;
};

}  // namespace
