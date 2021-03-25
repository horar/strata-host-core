#include "CmdWait.h"

#include "logging/LoggingQtCategories.h"

namespace strata::platform::command {

CmdWait::CmdWait(const device::DevicePtr& device,
                 std::chrono::milliseconds waitTime,
                 const QString& description)
    : BasePlatformCommand(device, QStringLiteral("wait"), CommandType::Wait),
      waitTime_(waitTime), description_(description)
{
    result_ = CommandResult::Done;
}

QByteArray CmdWait::message()
{
    // This metod should be never called!
    Q_ASSERT(false);

    return QByteArray();
}

bool CmdWait::processNotification(rapidjson::Document& doc)
{
    Q_UNUSED(doc)

    // This command sends nothing to device, any message which comes from
    // device when this command is being executed cannot belong to this command.
    // So, return false for every message (notification).
    return false;
}

void CmdWait::setWaitTime(std::chrono::milliseconds waitTime)
{
    waitTime_ = waitTime;
}

std::chrono::milliseconds CmdWait::waitTime() const
{
    return waitTime_;
}

QString CmdWait::description() const
{
    return description_;
}

}  // namespace
