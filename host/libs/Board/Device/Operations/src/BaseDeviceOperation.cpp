#include <Device/Operations/BaseDeviceOperation.h>

#include "Commands/include/DeviceCommands.h"
#include "DeviceOperationsConstants.h"

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

#include <rapidjson/document.h>

namespace strata::device::operation {

using command::BaseDeviceCommand;
using command::CommandResult;


BaseDeviceOperation::BaseDeviceOperation(const device::DevicePtr& device, Type type):
    type_(type), responseTimer_(this), device_(device), run_(false), finished_(false)
{
    responseTimer_.setSingleShot(true);
    responseTimer_.setInterval(RESPONSE_TIMEOUT);

    connect(this, &BaseDeviceOperation::sendCommand, this, &BaseDeviceOperation::handleSendCommand, Qt::QueuedConnection);
    connect(device_.get(), &Device::msgFromDevice, this, &BaseDeviceOperation::handleDeviceResponse);
    connect(device_.get(), &Device::deviceError, this, &BaseDeviceOperation::handleDeviceError);
    connect(&responseTimer_, &QTimer::timeout, this, &BaseDeviceOperation::handleResponseTimeout);

    //qCDebug(logCategoryDeviceOperations) << device_ << "Created new device operation (" << static_cast<int>(type_) << ")." ;
}

BaseDeviceOperation::~BaseDeviceOperation() {
    device_->unlockDevice(reinterpret_cast<quintptr>(this));
    //qCDebug(logCategoryDeviceOperations) << device_ << "Deleted device operation (" << static_cast<int>(type_) << ").";
}

void BaseDeviceOperation::run()
{
    if (run_) {
        QString errMsg(QStringLiteral("The operation has already run."));
        qCWarning(logCategoryDeviceOperations) << device_ << errMsg;
        emit error(errMsg);
        emit finished(Type::Failure);
        return;
    }

    if (device_->lockDeviceForOperation(reinterpret_cast<quintptr>(this)) == false) {
        QString errMsg(QStringLiteral("Cannot get access to device (another operation is running)."));
        qCWarning(logCategoryDeviceOperations) << device_ << errMsg;
        emit error(errMsg);
        emit finished(Type::Failure);
        return;
    }

    currentCommand_ = commandList_.begin();
    run_ = true;

    emit sendCommand(QPrivateSignal());
}

bool BaseDeviceOperation::isFinished() const {
    return finished_;
}

void BaseDeviceOperation::cancelOperation()
{
    responseTimer_.stop();
    finishOperation(Type::Cancel);
}

int BaseDeviceOperation::deviceId() const {
    return device_->deviceId();
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
        QString errMsg(QStringLiteral("Cannot send '") + command->name() + QStringLiteral("' command."));
        qCCritical(logCategoryDeviceOperations) << device_ << errMsg;
        reset();
        emit error(errMsg);
        emit finished(Type::Failure);
    }
}

void BaseDeviceOperation::handleDeviceResponse(const QByteArray& data)
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
            const QString ackStr = doc[JSON_ACK].GetString();
            qCDebug(logCategoryDeviceOperations) << device_ << "Received '" << ackStr << "' ACK.";
            const rapidjson::Value& payload = doc[JSON_PAYLOAD];
            const bool ackOk = payload[JSON_RETURN_VALUE].GetBool();

            BaseDeviceCommand *command = currentCommand_->get();
            if (ackStr == command->name()) {
                if (ackOk) {
                    command->setAckReceived();
                } else {
                    const QString ackError = payload[JSON_RETURN_STRING].GetString();
                    qCWarning(logCategoryDeviceOperations) << device_ << "ACK for '" << command->name() << "' command is not OK: '" << ackError << "'.";
                }
            } else {
                qCWarning(logCategoryDeviceOperations) << device_ << "Received wrong ACK. Expected '" << command->name() << "', got '" << ackStr << "'.";
                if (ackOk == false) {
                    qCWarning(logCategoryDeviceOperations) << device_ << "ACK is not OK: '" << payload[JSON_RETURN_STRING].GetString() << "'.";
                }
            }
            ok = true;
        }
    } else {
        if (doc.HasMember(JSON_NOTIFICATION)) {
            BaseDeviceCommand *command = currentCommand_->get();
            if (command->processNotification(doc)) {
                responseTimer_.stop();
                ok = true;
                if (command->ackReceived() == false) {
                    qCWarning(logCategoryDeviceOperations) << device_ << "Received notification without previous ACK.";
                }
                qCDebug(logCategoryDeviceOperations) << device_ << "Processed '" << command->name() << "' notification.";

                if (command->result() == CommandResult::Failure) {
                    qCWarning(logCategoryDeviceOperations) << device_ << "Received faulty notification: '" << data << "'.";
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
        finishOperation(Type::Timeout);
    } else {
        // In this case we move to next command (or do retry).
        QTimer::singleShot(0, this, [this](){ nextCommand(); });
    }
}

void BaseDeviceOperation::handleDeviceError(device::Device::ErrorCode errCode, QString msg)
{
    Q_UNUSED(errCode)
    responseTimer_.stop();
    reset();
    qCCritical(logCategoryDeviceOperations) << device_ << "Error: " << msg;
    emit error(msg);
    emit finished(Type::Failure);
}

void BaseDeviceOperation::resume()
{
    if (run_) {
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
    int data = command->dataForFinish();

    if (postCommandHandler_) {
        postCommandHandler_(result, data);  // this can modify result and data
    }

    switch (result) {
    case CommandResult::InProgress :
        //qCDebug(logCategoryDeviceOperations) << device_ << "Waiting for valid notification to '" << command->name() << "' command.";
        break;
    case CommandResult::Done :
        ++currentCommand_;  // move to next command
        if (currentCommand_ == commandList_.end()) {  // end of command list - finish operation
            finishOperation(type_, data);
        } else {
            emit sendCommand(QPrivateSignal());  // send next command
        }
        break;
    case CommandResult::Partial :
        // Operation is not finished yet, so emit only signal and do not call function finishOperation().
        // Do not increment currentCommand_, move to next command should be managed by logic in concrete operatrion.
        emit finished(type_, data);
        break;
    case CommandResult::Retry :
        emit sendCommand(QPrivateSignal());  // send same command again
        break;
    case CommandResult::Failure :
        finishOperation(Type::Failure);
        break;
    case CommandResult::FinaliseOperation :
        finishOperation(type_, data);
        break;
    }
}

void BaseDeviceOperation::finishOperation(Type operation, int data) {
    reset();
    finished_ = true;
    emit finished(operation, data);
}

void BaseDeviceOperation::reset() {
    commandList_.clear();
    currentCommand_ = commandList_.end();
    device_->unlockDevice(reinterpret_cast<quintptr>(this));
}



}  // namespace
