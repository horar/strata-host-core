/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <Operations/BasePlatformOperation.h>
#include <PlatformOperationsStatus.h>

#include "Commands/PlatformCommands.h"
#include "PlatformOperationsConstants.h"

#include "logging/LoggingQtCategories.h"

namespace strata::platform::operation {

using command::BasePlatformCommand;
using command::CommandResult;

BasePlatformOperation::BasePlatformOperation(const PlatformPtr& platform, Type type):
    type_(type),
    started_(false),
    succeeded_(false),
    finished_(false),
    platform_(platform),
    status_(DEFAULT_STATUS)
{
    connect(this, &BasePlatformOperation::sendCommand, this, &BasePlatformOperation::handleSendCommand, Qt::QueuedConnection);

    //qCDebug(lcPlatformOperation) << platform_ << "Created new platform operation (" << static_cast<int>(type_) << ").";
}

BasePlatformOperation::~BasePlatformOperation()
{
    platform_->unlockDevice(reinterpret_cast<quintptr>(this));

    //qCDebug(lcPlatformOperation) << platform_ << "Deleted platform operation (" << static_cast<int>(type_) << ").";
}

void BasePlatformOperation::run()
{
    if (platform_->deviceConnected() == false) {
        QString errStr(QStringLiteral("Cannot run operation, device is not connected."));
        qCWarning(lcPlatformOperation) << platform_ << errStr;
        finishOperation(Result::Disconnect, errStr);
        return;
    }

    if (started_) {
        QString errStr(QStringLiteral("The operation has already run."));
        qCWarning(lcPlatformOperation) << platform_ << errStr;
        finishOperation(Result::Error, errStr);
        return;
    }

    if (platform_->lockDeviceForOperation(reinterpret_cast<quintptr>(this)) == false) {
        QString errStr(QStringLiteral("Cannot get access to device (another operation is running)."));
        qCWarning(lcPlatformOperation) << platform_ << errStr;
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
    qCDebug(lcPlatformOperation) << platform_ << "Cancelling currently running operation.";

    if (currentCommand_ != commandList_.end()) {
        (*currentCommand_)->cancel();
    } else {
        finishOperation(Result::Cancel, QStringLiteral("Operation cancelled."));
    }
}

QByteArray BasePlatformOperation::deviceId() const
{
    return platform_->deviceId();
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
    return platform_->bootloaderMode();
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
                // Do not send next command, it will be sent by calling BasePlatformOperation::resume() method.
                emit partialStatus(status_);
            }
        }
        break;
    case CommandResult::RepeatAndWait :
        // Operation is not finished yet, so emit only value of status and do not call function finishOperation().
        // Do not increment currentCommand_, the same command will be repeated.
        // Following (repeated) command will be sent by calling BasePlatformOperation::resume() method.
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
    case CommandResult::DeviceDisconnected :
        finishOperation(Result::Disconnect, QStringLiteral("Device unexpectedly disconnected."));
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
    if (finished_) {
        return;
    }

    reset();
    finished_ = true;

    if (result == Result::Success) {
        succeeded_ = true;
    }

    if (postOperationHandler_) {
        postOperationHandler_(result);
    }

    emit finished(result, status_, errorString);
}

void BasePlatformOperation::resume()
{
    if (platform_->deviceConnected()) {
        if (started_ && (finished_ == false)) {
            emit sendCommand(QPrivateSignal());
        }
    } else {
        QString errStr(QStringLiteral("Cannot continue operation, device is not connected."));
        qCWarning(lcPlatformOperation) << platform_ << errStr;
        finishOperation(Result::Disconnect, errStr);
    }
}

void BasePlatformOperation::setPlatformRecognized(bool isRecognized)
{
    platform_->setRecognized(isRecognized);
}

void BasePlatformOperation::reset()
{
    commandList_.clear();
    currentCommand_ = commandList_.end();
    platform_->unlockDevice(reinterpret_cast<quintptr>(this));
}

}  // namespace
