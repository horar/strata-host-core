#include <Device/Operations/BaseDeviceOperation.h>
#include <DeviceOperationsStatus.h>

#include "Commands/include/DeviceCommands.h"
#include "DeviceOperationsConstants.h"

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

#include <rapidjson/document.h>

namespace strata::device::operation {

using command::BaseDeviceCommand;
using command::CommandResult;


BaseDeviceOperation::BaseDeviceOperation(const device::DevicePtr& device, Type type):
    type_(type), responseTimer_(this), started_(false), succeeded_(false),
    finished_(false), device_(device), status_(DEFAULT_STATUS)
{
    responseTimer_.setSingleShot(true);
    setResponseInterval();

    connect(this, &BaseDeviceOperation::sendCommand, this, &BaseDeviceOperation::handleSendCommand, Qt::QueuedConnection);
    connect(&responseTimer_, &QTimer::timeout, this, &BaseDeviceOperation::handleResponseTimeout);

    //qCDebug(logCategoryDeviceOperations) << device_ << "Created new device operation (" << static_cast<int>(type_) << ").";
}

BaseDeviceOperation::~BaseDeviceOperation() {
    device_->unlockDevice(reinterpret_cast<quintptr>(this));
    //qCDebug(logCategoryDeviceOperations) << device_ << "Deleted device operation (" << static_cast<int>(type_) << ").";
}

void BaseDeviceOperation::run()
{
    if (started_) {
        QString errStr(QStringLiteral("The operation has already run."));
        qCWarning(logCategoryDeviceOperations) << device_ << errStr;
        finishOperation(Result::Error, errStr);
        return;
    }

    if (device_->lockDeviceForOperation(reinterpret_cast<quintptr>(this)) == false) {
        QString errStr(QStringLiteral("Cannot get access to device (another operation is running)."));
        qCWarning(logCategoryDeviceOperations) << device_ << errStr;
        finishOperation(Result::Error, errStr);
        return;
    }

    connect(device_.get(), &Device::msgFromDevice, this, &BaseDeviceOperation::handleDeviceResponse);
    connect(device_.get(), &Device::deviceError, this, &BaseDeviceOperation::handleDeviceError);

    currentCommand_ = commandList_.begin();
    started_ = true;

    emit sendCommand(QPrivateSignal());
}

bool BaseDeviceOperation::hasStarted() const {
    return started_;
}

bool BaseDeviceOperation::isSuccessfullyFinished() const {
    return succeeded_;
}

bool BaseDeviceOperation::isFinished() const {
    return finished_;
}

void BaseDeviceOperation::cancelOperation()
{
    qCDebug(logCategoryDeviceOperations) << device_ << "Cancelling currently running operation.";
    responseTimer_.stop();
    finishOperation(Result::Cancel);
}

int BaseDeviceOperation::deviceId() const {
    return device_->deviceId();
}

Type BaseDeviceOperation::type() const {
    return type_;
}

QString BaseDeviceOperation::resolveErrorString(Result result)
{
    switch (result) {
    case Result::Success: return QString();
    case Result::Reject: return QStringLiteral("Command rejected");
    case Result::Cancel: return QStringLiteral("Operation cancelled");
    case Result::Timeout: return QStringLiteral("No response from device");
    case Result::Failure: return QStringLiteral("Faulty response from device");
    case Result::Error: return QStringLiteral("Error during operation");
    }

    qCCritical(logCategoryDeviceOperations) << "Unsupported result value";
    return QStringLiteral("Unknown error");
}

void BaseDeviceOperation::setResponseInterval(bool isTest)
{
    responseTimer_.setInterval(isTest ? RESPONSE_TIMEOUT_TESTS : RESPONSE_TIMEOUT);
}

bool BaseDeviceOperation::bootloaderMode() {
    return device_->bootloaderMode();
}

void BaseDeviceOperation::handleSendCommand()
{
    if (currentCommand_ == commandList_.end()) {
        return;
    }

    BaseDeviceCommand *command = currentCommand_->get();
    QString logMsg(QStringLiteral("Sending '") + command->name() + QStringLiteral("' command."));
    if (command->logSendMessage()) {
        qCInfo(logCategoryDeviceOperations) << device_ << logMsg;
    } else {
        qCDebug(logCategoryDeviceOperations) << device_ << logMsg;
    }

    if (device_->sendMessage(command->message(), reinterpret_cast<quintptr>(this))) {
        responseTimer_.start();
    } else {
        QString errStr(QStringLiteral("Cannot send '") + command->name() + QStringLiteral("' command."));
        qCCritical(logCategoryDeviceOperations) << device_ << errStr;
        finishOperation(Result::Error,errStr);
    }
}

void BaseDeviceOperation::handleDeviceResponse(const QByteArray data)
{
    if (currentCommand_ == commandList_.end()) {
        qCDebug(logCategoryDeviceOperations) << device_ << "No command is being processed, message from device is ignored.";
        return;
    }

    rapidjson::Document doc;

    if (CommandValidator::parseJsonCommand(data, doc) == false) {
        qCWarning(logCategoryDeviceOperations) << device_ << "Cannot parse JSON: '" << data << "'.";
        return;
    }

    bool ok = false;

    if (doc.HasMember(JSON_ACK)) {
        if (CommandValidator::validate(CommandValidator::JsonType::ack, doc)) {
            ok = true;

            const QString ackStr = doc[JSON_ACK].GetString();
            qCDebug(logCategoryDeviceOperations) << device_ << "Received '" << ackStr << "' ACK.";
            const rapidjson::Value& payload = doc[JSON_PAYLOAD];
            const bool ackOk = payload[JSON_RETURN_VALUE].GetBool();

            BaseDeviceCommand *command = currentCommand_->get();
            if (ackStr == command->name()) {
                if (ackOk) {
                    command->commandAcknowledged();
                } else {
                    const QString ackError = payload[JSON_RETURN_STRING].GetString();
                    qCWarning(logCategoryDeviceOperations) << device_ << "ACK for '" << command->name() << "' command is not OK: '" << ackError << "'.";
                    command->commandRejected();
                    nextCommand();
                }
            } else {
                qCWarning(logCategoryDeviceOperations) << device_ << "Received wrong ACK. Expected '" << command->name() << "', got '" << ackStr << "'.";
                if (ackOk == false) {
                    qCWarning(logCategoryDeviceOperations) << device_ << "ACK is not OK: '" << payload[JSON_RETURN_STRING].GetString() << "'.";
                }
            }
        }
    } else {
        if (doc.HasMember(JSON_NOTIFICATION)) {
            BaseDeviceCommand *command = currentCommand_->get();
            if (command->processNotification(doc)) {
                responseTimer_.stop();
                ok = true;

                if (command->isCommandAcknowledged() == false) {
                    qCWarning(logCategoryDeviceOperations) << device_ << "Received notification without previous ACK.";
                }
                qCDebug(logCategoryDeviceOperations) << device_ << "Processed '" << command->name() << "' notification.";

                CommandResult result = command->result();
                if (result == CommandResult::FinaliseOperation || result == CommandResult::Failure) {
                    if (result == CommandResult::Failure) {
                        qCWarning(logCategoryDeviceOperations) << device_ << "Received faulty notification: '" << data << "'.";
                    }

                    const QByteArray status = CommandValidator::notificationStatus(doc);
                    if (status.isEmpty() == false) {
                        qCInfo(logCategoryDeviceOperations) << device_ << "Command '" << command->name() << "' retruned '" << status << "'.";
                    }
                }

                QTimer::singleShot(command->waitBeforeNextCommand(), this, [this](){ nextCommand(); });
            }
        }
    }

    if (ok == false) {
        qCWarning(logCategoryDeviceOperations) << device_ << "Received wrong or malformed response: '" << data << "'.";
    }
}

void BaseDeviceOperation::handleResponseTimeout()
{
    if (currentCommand_ == commandList_.end()) {
        return;
    }
    BaseDeviceCommand *command = currentCommand_->get();
    qCWarning(logCategoryDeviceOperations) << device_ << "Command '" << command->name() << "' timed out.";
    command->onTimeout();  // This can change command result.
    // Some commands can timeout - result is other than 'InProgress' then.
    if (command->result() == CommandResult::InProgress) {
        finishOperation(Result::Timeout);
    } else {
        // In this case we move to next command (or do retry).
        QTimer::singleShot(0, this, [this](){ nextCommand(); });
    }
}

void BaseDeviceOperation::handleDeviceError(device::Device::ErrorCode errCode, QString errStr)
{
    Q_UNUSED(errCode)
    responseTimer_.stop();
    qCCritical(logCategoryDeviceOperations) << device_ << "Error: " << errStr;
    finishOperation(Result::Error, errStr);
}

void BaseDeviceOperation::resume()
{
    if (started_) {
        emit sendCommand(QPrivateSignal());
    }
}

void BaseDeviceOperation::nextCommand()
{
    if (currentCommand_ == commandList_.end()) {
        return;
    }

    BaseDeviceCommand *command = currentCommand_->get();
    CommandResult result = command->result();
    status_ = command->status();

    if (postCommandHandler_) {
        postCommandHandler_(result, status_);  // this can modify result and status_
    }

    switch (result) {
    case CommandResult::InProgress :
        //qCDebug(logCategoryDeviceOperations) << device_ << "Waiting for valid notification to '" << command->name() << "' command.";
        break;
    case CommandResult::Done :
        ++currentCommand_;  // move to next command
        if (currentCommand_ == commandList_.end()) {  // end of command list - finish operation
            finishOperation(Result::Success);
        } else {
            emit sendCommand(QPrivateSignal());  // send next command
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

void BaseDeviceOperation::finishOperation(Result result, const QString &errorString) {
    reset();
    finished_ = true;

    disconnect(device_.get(), &Device::msgFromDevice, this, &BaseDeviceOperation::handleDeviceResponse);
    disconnect(device_.get(), &Device::deviceError, this, &BaseDeviceOperation::handleDeviceError);

    QString effectiveErrorString = errorString;
    if (result == Result::Success) {
        succeeded_ = true;
    } else if (effectiveErrorString.isEmpty()) {
        effectiveErrorString = resolveErrorString(result);
    }

    emit finished(result, status_, effectiveErrorString);
}

void BaseDeviceOperation::reset() {
    commandList_.clear();
    currentCommand_ = commandList_.end();
    device_->unlockDevice(reinterpret_cast<quintptr>(this));
}

}  // namespace
