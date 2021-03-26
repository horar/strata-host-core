#include "CmdWait.h"

#include "logging/LoggingQtCategories.h"

namespace strata::device::command {

CmdWait::CmdWait(const device::DevicePtr& device,
                 std::chrono::milliseconds waitTime,
                 const QString& description)
    : BaseDeviceCommand(device, QStringLiteral("wait"), CommandType::Wait),
      description_(description)
{
    waitTimer_.setSingleShot(true);
    waitTimer_.setInterval(waitTime);
    waitTimer_.callOnTimeout(this, [this](){ emit finished(CommandResult::Done, status_); } );
}

void CmdWait::sendCommand(quintptr lockId)
{
    Q_UNUSED(lockId)

    qCInfo(logCategoryDeviceCommand) << device_ << description_ << ". Next command will be sent after "
        << waitTimer_.intervalAsDuration().count() << " milliseconds.";
    waitTimer_.start();
}

void CmdWait::cancel()
{
    waitTimer_.stop();
    emit finished(CommandResult::Cancel, status_);
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

void CmdWait::setWaitTime(std::chrono::milliseconds waitTime)
{
    waitTimer_.setInterval(waitTime);
}

}  // namespace
