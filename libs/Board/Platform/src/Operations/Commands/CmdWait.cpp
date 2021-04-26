#include "CmdWait.h"

#include "logging/LoggingQtCategories.h"

namespace strata::platform::command {

CmdWait::CmdWait(const PlatformPtr& platform,
                 std::chrono::milliseconds waitTime,
                 const QString& description)
    : BasePlatformCommand(platform, QStringLiteral("wait"), CommandType::Wait),
      waitTime_(waitTime),
      description_(description)
{ }

void CmdWait::sendCommand(quintptr lockId)
{
    Q_UNUSED(lockId)

    qCInfo(logCategoryPlatformCommand) << platform_ << description_
        << ". Next command will be sent after " << waitTime_.count() << " milliseconds.";
    responseTimer_.setInterval(waitTime_);
    responseTimer_.start();
}

QByteArray CmdWait::message()
{
    // This metod should be never called!
    Q_ASSERT(false);

    return QByteArray();
}

bool CmdWait::processNotification(rapidjson::Document& doc, CommandResult& result)
{
    Q_UNUSED(doc)
    Q_UNUSED(result)

    // This command sends nothing to device, any message which comes from
    // device when this command is being executed cannot belong to this command.
    // So, return false for every message (notification).
    return false;
}

CommandResult CmdWait::onTimeout()
{
    return CommandResult::Done;
}

void CmdWait::setWaitTime(std::chrono::milliseconds waitTime)
{
    waitTime_ = waitTime;
}

}  // namespace
