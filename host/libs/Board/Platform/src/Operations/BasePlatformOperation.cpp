#include <Operations/BasePlatformOperation.h>
#include <PlatformOperationsStatus.h>

#include "Commands/PlatformCommands.h"
#include "PlatformOperationsConstants.h"

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

#include <rapidjson/document.h>

namespace strata::platform::operation {

using command::BasePlatformCommand;
using command::CommandResult;

BasePlatformOperation::BasePlatformOperation(const device::DevicePtr& device, Type type):
    type_(type), responseTimer_(this), started_(false), succeeded_(false),
    finished_(false), device_(device), status_(DEFAULT_STATUS)
{
    responseTimer_.setSingleShot(true);
    responseTimer_.setInterval(RESPONSE_TIMEOUT);

    connect(this, &BasePlatformOperation::sendCommand, this, &BasePlatformOperation::handleSendCommand, Qt::QueuedConnection);
    connect(this, &BasePlatformOperation::processCmdResult, this, &BasePlatformOperation::handleProcessCmdResult, Qt::QueuedConnection);
    connect(&responseTimer_, &QTimer::timeout, this, &BasePlatformOperation::handleResponseTimeout);

    //qCDebug(logCategoryPlatformOperations) << device_ << "Created new device operation (" << static_cast<int>(type_) << ").";
}

BasePlatformOperation::~BasePlatformOperation() {
    device_->unlockDevice(reinterpret_cast<quintptr>(this));
    //qCDebug(logCategoryPlatformOperations) << device_ << "Deleted device operation (" << static_cast<int>(type_) << ").";
}

void BasePlatformOperation::run()
{
    if (started_) {
        QString errStr(QStringLiteral("The operation has already run."));
        qCWarning(logCategoryPlatformOperations) << device_ << errStr;
        finishOperation(Result::Error, errStr);
        return;
    }

    if (device_->lockDeviceForOperation(reinterpret_cast<quintptr>(this)) == false) {
        QString errStr(QStringLiteral("Cannot get access to device (another operation is running)."));
        qCWarning(logCategoryPlatformOperations) << device_ << errStr;
        finishOperation(Result::Error, errStr);
        return;
    }

    connect(device_.get(), &device::Device::msgFromDevice, this, &BasePlatformOperation::handleDeviceResponse);
    connect(device_.get(), &device::Device::deviceError, this, &BasePlatformOperation::handleDeviceError);

    currentCommand_ = commandList_.begin();
    started_ = true;

    emit sendCommand(QPrivateSignal());
}

bool BasePlatformOperation::hasStarted() const {
    return started_;
}

bool BasePlatformOperation::isSuccessfullyFinished() const {
    return succeeded_;
}

bool BasePlatformOperation::isFinished() const {
    return finished_;
}

void BasePlatformOperation::cancelOperation()
{
    qCDebug(logCategoryPlatformOperations) << device_ << "Cancelling currently running operation.";
    responseTimer_.stop();
    finishOperation(Result::Cancel);
}

QByteArray BasePlatformOperation::deviceId() const {
    return device_->deviceId();
}

Type BasePlatformOperation::type() const {
    return type_;
}

QString BasePlatformOperation::resolveErrorString(Result result)
{
    switch (result) {
    case Result::Success: return QString();
    case Result::Reject: return QStringLiteral("Command rejected");
    case Result::Cancel: return QStringLiteral("Operation cancelled");
    case Result::Timeout: return QStringLiteral("No response from device");
    case Result::Failure: return QStringLiteral("Faulty response from device");
    case Result::Error: return QStringLiteral("Error during operation");
    }

    qCCritical(logCategoryPlatformOperations) << "Unsupported result value";
    return QStringLiteral("Unknown error");
}

void BasePlatformOperation::setResponseTimeout(std::chrono::milliseconds responseInterval)
{
    responseTimer_.setInterval(responseInterval);
}

bool BasePlatformOperation::bootloaderMode() {
    return device_->bootloaderMode();
}

void BasePlatformOperation::handleSendCommand()
{
    if (currentCommand_ == commandList_.end()) {
        return;
    }

    BasePlatformCommand *command = currentCommand_->get();

    if (command->type() == command::CommandType::Wait) {
        command::CmdWait* cmdWait = dynamic_cast<command::CmdWait*>(command);
        if (cmdWait != nullptr) {
            std::chrono::milliseconds waitTime = cmdWait->waitTime();
            if (waitTime > std::chrono::milliseconds(0)) {
                QString description = cmdWait->description();
                if (description.isEmpty() == false) {
                    qCInfo(logCategoryPlatformOperations) << device_ << description;
                }
                qCInfo(logCategoryPlatformOperations) << device_ << "Waiting " << waitTime.count()
                    << " milliseconds before sending next command.";
                QTimer::singleShot(waitTime, this, [this](){
                    handleProcessCmdResult();
                });
            } else {
                qCDebug(logCategoryPlatformOperations) << device_ << "Skip waiting before the next command.";
                emit processCmdResult(QPrivateSignal());
            }
        } else {
            QString errStr(QStringLiteral("Unexpected 'wait' command error."));
            qCCritical(logCategoryPlatformOperations) << device_ << errStr;
            finishOperation(Result::Error, errStr);
        }

        return;
    }

    QString logMsg(QStringLiteral("Sending '") + command->name() + QStringLiteral("' command."));
    if (command->logSendMessage()) {
        qCInfo(logCategoryPlatformOperations) << device_ << logMsg;
    } else {
        qCDebug(logCategoryPlatformOperations) << device_ << logMsg;
    }

    if (device_->sendMessage(command->message(), reinterpret_cast<quintptr>(this))) {
        responseTimer_.start();
    } else {
        QString errStr(QStringLiteral("Cannot send '") + command->name() + QStringLiteral("' command."));
        qCCritical(logCategoryPlatformOperations) << device_ << errStr;
        finishOperation(Result::Error, errStr);
    }
}

void BasePlatformOperation::handleDeviceResponse(const QByteArray data)
{
    if (currentCommand_ == commandList_.end()) {
        qCDebug(logCategoryPlatformOperations) << device_ << "No command is being processed, message from device is ignored.";
        return;
    }

    rapidjson::Document doc;

    if (CommandValidator::parseJsonCommand(data, doc) == false) {
        qCWarning(logCategoryPlatformOperations) << device_ << "Cannot parse JSON: '" << data << "'.";
        return;
    }

    bool ok = false;

    if (doc.HasMember(JSON_ACK)) {
        if (CommandValidator::validate(CommandValidator::JsonType::ack, doc)) {
            ok = true;

            const QString ackStr = doc[JSON_ACK].GetString();
            qCDebug(logCategoryPlatformOperations) << device_ << "Received '" << ackStr << "' ACK.";
            const rapidjson::Value& payload = doc[JSON_PAYLOAD];
            const bool ackOk = payload[JSON_RETURN_VALUE].GetBool();

            BasePlatformCommand *command = currentCommand_->get();
            if (ackStr == command->name()) {
                if (ackOk) {
                    command->commandAcknowledged();
                } else {
                    const QString ackError = payload[JSON_RETURN_STRING].GetString();
                    qCWarning(logCategoryPlatformOperations) << device_ << "ACK for '" << command->name() << "' command is not OK: '" << ackError << "'.";
                    command->commandRejected();

                    emit processCmdResult(QPrivateSignal());
                }
            } else {
                qCWarning(logCategoryPlatformOperations) << device_ << "Received wrong ACK. Expected '" << command->name() << "', got '" << ackStr << "'.";
                if (ackOk == false) {
                    qCWarning(logCategoryPlatformOperations) << device_ << "ACK is not OK: '" << payload[JSON_RETURN_STRING].GetString() << "'.";
                }
            }
        }
    } else {
        if (doc.HasMember(JSON_NOTIFICATION)) {
            BasePlatformCommand *command = currentCommand_->get();
            if (command->processNotification(doc)) {
                responseTimer_.stop();
                ok = true;

                if (command->isCommandAcknowledged() == false) {
                    qCWarning(logCategoryPlatformOperations) << device_ << "Received notification without previous ACK.";
                }
                qCDebug(logCategoryPlatformOperations) << device_ << "Processed '" << command->name() << "' notification.";

                CommandResult result = command->result();
                if (result == CommandResult::FinaliseOperation || result == CommandResult::Failure) {
                    if (result == CommandResult::Failure) {
                        qCWarning(logCategoryPlatformOperations) << device_ << "Received faulty notification: '" << data << "'.";
                    }

                    const QByteArray status = CommandValidator::notificationStatus(doc);
                    if (status.isEmpty() == false) {
                        qCInfo(logCategoryPlatformOperations) << device_ << "Command '" << command->name() << "' retruned '" << status << "'.";
                    }
                }

                emit processCmdResult(QPrivateSignal());
            }
        }
    }

    if (ok == false) {
        qCWarning(logCategoryPlatformOperations) << device_ << "Received wrong, unexpected or malformed response: '" << data << "'.";
    }
}

void BasePlatformOperation::handleResponseTimeout()
{
    if (currentCommand_ == commandList_.end()) {
        return;
    }
    BasePlatformCommand *command = currentCommand_->get();
    qCWarning(logCategoryPlatformOperations) << device_ << "Command '" << command->name() << "' timed out.";
    command->onTimeout();  // This can change command result.
    // Some commands can timeout - result is other than 'InProgress' then.
    if (command->result() == CommandResult::InProgress) {
        finishOperation(Result::Timeout);
    } else {
        // In this case we move to next command (or do retry).
        emit processCmdResult(QPrivateSignal());
    }
}

void BasePlatformOperation::handleDeviceError(device::Device::ErrorCode errCode, QString errStr)
{
    Q_UNUSED(errCode)
    responseTimer_.stop();
    qCCritical(logCategoryPlatformOperations) << device_ << "Error: " << errStr;
    finishOperation(Result::Error, errStr);
}

void BasePlatformOperation::handleProcessCmdResult()
{
    if (currentCommand_ == commandList_.end()) {
        return;
    }

    BasePlatformCommand *command = currentCommand_->get();
    CommandResult result = command->result();
    status_ = command->status();

    if (postCommandHandler_) {
        postCommandHandler_(result, status_);  // this can modify result and status_
    }

    switch (result) {
    case CommandResult::InProgress :
        //qCDebug(logCategoryPlatformOperations) << device_ << "Waiting for valid notification to '" << command->name() << "' command.";
        break;
    case CommandResult::Done :
        ++currentCommand_;  // move to next command
        if (currentCommand_ == commandList_.end()) {  // end of command list - finish operation
            finishOperation(Result::Success);
        } else {
            emit sendCommand(QPrivateSignal());  // send (next) command
        }
        break;
    case CommandResult::Partial :
        // Operation is not finished yet, so emit only signal and do not call function finishOperation().
        // Do not increment currentCommand_, move to next command should be managed by logic in concrete operatrion.
        emit finished(Result::Success, status_);
        break;
    case CommandResult::Retry :
        emit sendCommand(QPrivateSignal());  // send same command again
        break;
    case CommandResult::Reject :
        finishOperation(Result::Reject);
        break;
    case CommandResult::Failure :
        finishOperation(Result::Failure);
        break;
    case CommandResult::FinaliseOperation :
        finishOperation(Result::Success);
        break;
    }
}

void BasePlatformOperation::finishOperation(Result result, const QString &errorString) {
    reset();
    finished_ = true;

    disconnect(device_.get(), &device::Device::msgFromDevice, this, &BasePlatformOperation::handleDeviceResponse);
    disconnect(device_.get(), &device::Device::deviceError, this, &BasePlatformOperation::handleDeviceError);

    QString effectiveErrorString = errorString;
    if (result == Result::Success) {
        succeeded_ = true;
    } else if (effectiveErrorString.isEmpty()) {
        effectiveErrorString = resolveErrorString(result);
    }

    emit finished(result, status_, effectiveErrorString);
}

void BasePlatformOperation::resume()
{
    if (started_) {
        emit sendCommand(QPrivateSignal());
    }
}

void BasePlatformOperation::reset() {
    commandList_.clear();
    currentCommand_ = commandList_.end();
    device_->unlockDevice(reinterpret_cast<quintptr>(this));
}

}  // namespace
