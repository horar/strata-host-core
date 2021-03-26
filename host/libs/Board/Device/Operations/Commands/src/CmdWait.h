#pragma once

#include <chrono>
#include <QTimer>

#include "BaseDeviceCommand.h"

namespace strata::device::command {

// This is special command used for waiting between commands in command list.
// This command has also its own implementation of sendCommand method.

class CmdWait : public BaseDeviceCommand
{
public:
    CmdWait(const device::DevicePtr& device,
            std::chrono::milliseconds waitTime,
            const QString& description = QString());

    void sendCommand(quintptr lockId) override;
    void cancel() override;
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc, CommandResult& result) override;

    void setWaitTime(std::chrono::milliseconds waitTime);

private:
    QTimer waitTimer_;
    QString description_;
};

}  // namespace
