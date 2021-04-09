#include <Operations/BasePlatformOperation.h>
#include <PlatformOperationsStatus.h>

#include "Commands/PlatformCommands.h"
#include "PlatformOperationsConstants.h"

#include "logging/LoggingQtCategories.h"

namespace strata::platform::operation {

using command::BasePlatformCommand;
using command::CommandResult;

BasePlatformOperation::BasePlatformOperation(const device::DevicePtr& device, Type type):
    type_(type), started_(false), succeeded_(false),
    finished_(false), device_(device), status_(DEFAULT_STATUS)
{
    connect(this, &BasePlatformOperation::sendCommand, this, &BasePlatformOperation::handleSendCommand, Qt::QueuedConnection);

    //qCDebug(logCategoryPlatformOperation) << device_ << "Created new platform operation (" << static_cast<int>(type_) << ").";
}

BasePlatformOperation::~BasePlatformOperation()
{
    device_->unlockDevice(reinterpret_cast<quintptr>(this));

    //qCDebug(logCategoryPlatformOperation) << device_ << "Deleted platform operation (" << static_cast<int>(type_) << ").";
}

void BasePlatformOperation::run()
{
    if (started_) {
        QString errStr(QStringLiteral("The operation has already run."));
        qCWarning(logCategoryPlatformOperation) << device_ << errStr;
        finishOperation(Result::Error, errStr);
        return;
    }

    if (device_->lockDeviceForOperation(reinterpret_cast<quintptr>(this)) == false) {
        QString errStr(QStringLiteral("Cannot get access to device (another operation is running)."));
        qCWarning(logCategoryPlatformOperation) << device_ << errStr;
        finishOperation(Result::Error, errStr);
        return;
    }

    currentCommand_ = commandList_.begin();
    started_ = true;

    emit sendCommand(QPrivateSignal());
}

bool BasePlatformOperation::hasStarted() const
{
    return started_;
}

bool BasePlatformOperation::isSuccessfullyFinished() const
{
    return succeeded_;
}

bool BasePlatformOperation::isFinished() const
{
    return finished_;
}

void BasePlatformOperation::cancelOperation()
{
    qCDebug(logCategoryPlatformOperation) << device_ << "Cancelling currently running operation.";

    if (currentCommand_ != commandList_.end()) {
        (*currentCommand_)->cancel();
    } else {
        finishOperation(Result::Cancel, QStringLiteral("Operation cancelled."));
    }
}

QByteArray BasePlatformOperation::deviceId() const
{
    return device_->deviceId();
}

Type BasePlatformOperation::type() const
{
    return type_;
}

#ifdef BUILD_TESTING
void BasePlatformOperation::setResponseTimeouts(std::chrono::milliseconds responseTimeout)
{
    for (auto it = commandList_.begin(); it != commandList_.end(); ++it) {
        (*it)->setAckTimeout(responseTimeout);
        (*it)->setNotificationTimeout(responseTimeout);
    }
}
#endif

bool BasePlatformOperation::bootloaderMode()
{
    return device_->bootloaderMode();
}

void BasePlatformOperation::handleSendCommand()
{
    if (currentCommand_ == commandList_.end()) {
        return;
    }

    (*currentCommand_)->sendCommand(reinterpret_cast<quintptr>(this));
}

void BasePlatformOperation::handleCommandFinished(CommandResult result, int status)
{
    status_ = status;

    if (postCommandHandler_) {
        postCommandHandler_(result, status_);  // this can modify result and status_
    }

    switch (result) {
    case CommandResult::Done :
    case CommandResult::DoneAndWait :
        ++currentCommand_;  // move to next command
        if (currentCommand_ == commandList_.end()) {  // end of command list - finish operation
            finishOperation(Result::Success, QString());
        } else {
            if (result == CommandResult::Done) {
                emit sendCommand(QPrivateSignal());  // send (next) command
            } else {
                // Do not send next command, it will be sent by calling BaseDeviceOperation::resume() method.
                emit partialStatus(status_);
            }
        }
        break;
    case CommandResult::RepeatAndWait :
        // Operation is not finished yet, so emit only value of status and do not call function finishOperation().
        // Do not increment currentCommand_, the same command will be repeated.
        // Following (repeated) command will be sent by calling BaseDeviceOperation::resume() method.
        emit partialStatus(status_);
        break;
    case CommandResult::Retry :
        emit sendCommand(QPrivateSignal());  // send same command again
        break;
    case CommandResult::Reject :
        finishOperation(Result::Reject, QStringLiteral("Command was rejected."));
        break;
    case CommandResult::Failure :
        finishOperation(Result::Failure, QStringLiteral("Faulty response from device."));
        break;
    case CommandResult::FinaliseOperation :
        finishOperation(Result::Success, QString());
        break;
    case CommandResult::Timeout :
        finishOperation(Result::Timeout, QStringLiteral("No response from device."));
        break;
    case CommandResult::MissingAck :
        finishOperation(Result::Failure, QStringLiteral("Command was not acknowledged."));
        break;
    case CommandResult::Unsent :
        finishOperation(Result::Failure, QStringLiteral("Sending command has failed."));
        break;
    case CommandResult::Cancel :
        finishOperation(Result::Cancel, QStringLiteral("Operation cancelled."));
        break;
    case CommandResult::DeviceError :
        finishOperation(Result::Failure, QStringLiteral("Unexpected device error has occured."));
        break;
    }
}

void BasePlatformOperation::initCommandList()
{
    for (auto it = commandList_.begin(); it != commandList_.end(); ++it) {
        connect(it->get(), &BasePlatformCommand::finished, this, &BasePlatformOperation::handleCommandFinished);
    }

    currentCommand_ = commandList_.end();
}

void BasePlatformOperation::finishOperation(Result result, const QString &errorString)
{
    reset();
    finished_ = true;

    if (result == Result::Success) {
        succeeded_ = true;
    }

    emit finished(result, status_, errorString);
}

void BasePlatformOperation::resume()
{
    if (started_) {
        emit sendCommand(QPrivateSignal());
    }
}

void BasePlatformOperation::reset()
{
    commandList_.clear();
    currentCommand_ = commandList_.end();
    device_->unlockDevice(reinterpret_cast<quintptr>(this));
}

}  // namespace
