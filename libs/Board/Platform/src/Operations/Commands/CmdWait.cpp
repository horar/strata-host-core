/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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

    connect(platform_.get(), &Platform::deviceError, this, &CmdWait::deviceErrorOccured);

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

bool CmdWait::processNotification(const rapidjson::Document& doc, CommandResult& result)
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
    disconnect(platform_.get(), &Platform::deviceError, this, &CmdWait::deviceErrorOccured);
    return CommandResult::Done;
}

void CmdWait::setWaitTime(std::chrono::milliseconds waitTime)
{
    waitTime_ = waitTime;
}

void CmdWait::deviceErrorOccured(device::Device::ErrorCode errCode, QString errStr)
{
    disconnect(platform_.get(), &Platform::deviceError, this, &CmdWait::deviceErrorOccured);
    // responseTimer_ is stopped in BasePlatformCommand::handleDeviceError()
    BasePlatformCommand::handleDeviceError(errCode, errStr);
}

}  // namespace
