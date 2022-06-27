/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "BasePlatformCommand.h"

#include "PlatformCommandConstants.h"
#include <PlatformOperationsStatus.h>

#include <rapidjson/document.h>

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

namespace strata::platform::command {

BasePlatformCommand::BasePlatformCommand(const PlatformPtr& platform, const QString& commandName, CommandType cmdType)
    : cmdName_(commandName),
      cmdType_(cmdType),
      platform_(platform),
      lastMsgNumber_(0),
      ackOk_(false),
      status_(operation::DEFAULT_STATUS),
      ackTimeout_(ACK_TIMEOUT),
      notificationTimeout_(NOTIFICATION_TIMEOUT),
      deviceSignalsConnected_(false),
      platformValidation_(false)
{
    responseTimer_.setSingleShot(true);
    connect(&responseTimer_, &QTimer::timeout, this, &BasePlatformCommand::handleResponseTimeout);
}

BasePlatformCommand::~BasePlatformCommand() { }

// Do not override this method (unless you really need to).
void BasePlatformCommand::sendCommand(quintptr lockId)
{
    if (platform_->deviceConnected() == false) {
        finishCommand(CommandResult::DeviceDisconnected);
        return;
    }

    if (deviceSignalsConnected_ == false) {
        connect(platform_.get(), &Platform::messageReceived, this, &BasePlatformCommand::handleDeviceResponse);
        connect(platform_.get(), &Platform::messageSent, this, &BasePlatformCommand::handleMessageSent);
        connect(platform_.get(), &Platform::deviceError, this, &BasePlatformCommand::handleDeviceError);
        deviceSignalsConnected_ = true;
    }

    QString logMsg(QStringLiteral("Sending '") + cmdName_ + QStringLiteral("' command."));
    if (this->logSendMessage()) {
        qCInfo(lcPlatformCommand) << platform_ << logMsg;
    } else {
        qCDebug(lcPlatformCommand) << platform_ << logMsg;
    }

    ackOk_ = false;  // "ok" ACK for this command

    responseTimer_.setInterval(ackTimeout_);
    responseTimer_.start();
    lastMsgNumber_ = platform_->sendMessage(this->message(), lockId);
}

// If method 'sendCommand' is overriden, check if this method is still valid.
// If is not, override it too.
void BasePlatformCommand::cancel()
{
    responseTimer_.stop();
    finishCommand(CommandResult::Cancel);
}

const QString BasePlatformCommand::name() const {
    return cmdName_;
}

CommandType BasePlatformCommand::type() const {
    return cmdType_;
}

void BasePlatformCommand::setAckTimeout(std::chrono::milliseconds ackTimeout)
{
    ackTimeout_ = ackTimeout;
}

void BasePlatformCommand::setNotificationTimeout(std::chrono::milliseconds notificationTimeout)
{
    notificationTimeout_ = notificationTimeout;
}

void BasePlatformCommand::enablePlatformValidation(bool enable)
{
    platformValidation_ = enable;
}

CommandResult BasePlatformCommand::onTimeout() {
    // Default result is 'Timeout' - command timed out.
    // If timeout is not a problem, reimplement this method and return 'Done' or 'Retry'.
    return CommandResult::Timeout;
}

CommandResult BasePlatformCommand::onReject() {
    // Default result is 'Reject' - command was rejected.
    // If reject is not a problem, reimplement this method and return 'Done'.
    return CommandResult::Reject;
}

bool BasePlatformCommand::logSendMessage() const {
    return true;
}

void BasePlatformCommand::handleDeviceResponse(const PlatformMessage message)
{
    if (message.isJsonValidObject() == false) {
        QString warning = generateWrongResponseError(message);
        qCWarning(lcPlatformCommand) << platform_ << warning;
        emitValidationFailure(warning, ValidationFailure::Warning);
        return;
    }

    const rapidjson::Document& json = message.json();

    if (json.HasMember(JSON_ACK)) {
        if (CommandValidator::validate(CommandValidator::JsonType::ack, json)) {
            const QString ackStr = json[JSON_ACK].GetString();
            qCDebug(lcPlatformCommand) << platform_ << "Received '" << ackStr << "' ACK.";
            const rapidjson::Value& payload = json[JSON_PAYLOAD];

            ackOk_ = payload[JSON_RETURN_VALUE].GetBool();

            if (ackStr == cmdName_) {
                responseTimer_.stop();
                if (ackOk_) {
                    responseTimer_.setInterval(notificationTimeout_);
                    responseTimer_.start();
                } else {
                    QString warning = "Bad ACK for '" + cmdName_ + "': '" + payload[JSON_RETURN_STRING].GetString() + "'.";
                    qCWarning(lcPlatformCommand) << platform_ << warning;
                    emitValidationFailure(warning, ValidationFailure::CmdRejected);
                    // ACK is not 'ok' - command is rejected by device
                    finishCommand(this->onReject());
                }
            } else {
                QString warning = "Received wrong ACK. Expected '" + cmdName_ + "', got '" + ackStr + "'.";
                qCWarning(lcPlatformCommand) << platform_ << warning;
                // Here should be variable 'ackOk_' set to 'false' - received ACK is for another command.
                // It is not set because older Strata applications accepts any ACK which has 'true' in 'JSON_RETURN_VALUE'.
                // We cannot set 'ackOk_' to 'false' due to backwards compatibility - if by chance there was an old board
                // that doesn't send ACK correctly.
                // It means that if command "abc" is sent, ACK will be accepted even if it will be for command "def".
                // Setting 'ackOk_' to 'false' here causes that only right ACK ("abc" for command "abc") will be accepted.
                if (platformValidation_) {
                    ackOk_ = false;  // But we can set 'ackOk_' to 'false' for platform validation.
                    emit validationFailure(warning, ValidationFailure::Fatal);
                }
            }
        } else {
            QString warning = CommandValidator::lastValidationError();
            if (warning.isEmpty()) {
                warning = "Received invalid ACK: '" + message.rawNoNewlineEnd() + "'.";
            }
            qCWarning(lcPlatformCommand) << platform_ << warning;
            emitValidationFailure(warning, ValidationFailure::Fatal);
        }

        return;
    }

    if (json.HasMember(JSON_NOTIFICATION)) {
        if (platformValidation_) {
            emit receivedNotification(message);
        }
        CommandResult result = CommandResult::Failure;
        if (this->processNotification(json, result)) {
            responseTimer_.stop();

            qCDebug(lcPlatformCommand) << platform_ << "Processed '" << cmdName_ << "' notification.";

            if (ackOk_) {
                if (result == CommandResult::FinaliseOperation || result == CommandResult::Failure) {
                    if (result == CommandResult::Failure) {
                        QString warning = "Received faulty notification: '" + message.rawNoNewlineEnd() + '\'';
                        qCWarning(lcPlatformCommand) << platform_ << warning;
                        emitValidationFailure(warning, ValidationFailure::FaultyNotification);
                    }

                    const QByteArray status = CommandValidator::notificationStatus(json);
                    if (status.isEmpty() == false) {
                        qCInfo(lcPlatformCommand) << platform_ << "Command '" << cmdName_ << "' returned '" << status << "'.";
                    }
                }
                finishCommand(result);
            } else {
                QString warning = "Received notification without previous ACK.";
                qCWarning(lcPlatformCommand) << platform_ << warning;
                emitValidationFailure(warning, ValidationFailure::Fatal);
                finishCommand(CommandResult::MissingAck);
            }
        } else {
            // some platforms send periodic notifications, it is not an error if we receive it, ignore it
            QString warning = "Received inappropriate notification for command '" + cmdName_ + "': '" + message.rawNoNewlineEnd() + '\'';
            qCDebug(lcPlatformCommand) << platform_ << warning;
            emitValidationFailure(warning, ValidationFailure::InappropriateNotification);
        }

        return;
    }

    // received JSON is not valid response to command neither platform notification
    // log warning and wait for the correct JSON (until timeout)
    QString warning = generateWrongResponseError(message);
    qCWarning(lcPlatformCommand) << platform_ << warning;
    emitValidationFailure(warning, ValidationFailure::Warning);
}

void BasePlatformCommand::handleResponseTimeout()
{
    if (cmdType_ != CommandType::Wait) {
        QString warning = "Command '" + cmdName_ + "' timed out.";
        qCWarning(lcPlatformCommand) << platform_ << warning;
        emitValidationFailure(warning, ValidationFailure::Timeout);
    }
    finishCommand(this->onTimeout());
}

void BasePlatformCommand::handleMessageSent(QByteArray rawMessage, unsigned msgNumber, QString errStr)
{
    Q_UNUSED(rawMessage)
    if ((errStr.isEmpty() == false) && (msgNumber == lastMsgNumber_)) {
        responseTimer_.stop();
        QString warning = QStringLiteral("Cannot send '") + cmdName_ + QStringLiteral("' command. Error: '") + errStr + '\'';
        qCCritical(lcPlatformCommand) << platform_ << warning;
        emitValidationFailure(warning, ValidationFailure::Fatal);
        finishCommand(CommandResult::Unsent);
    }
}

void BasePlatformCommand::handleDeviceError(device::Device::ErrorCode errCode, QString errStr)
{
    if (errCode == device::Device::ErrorCode::NoError) {
        return;
    }

    responseTimer_.stop();
    QString warning = "Error: " + errStr;
    qCCritical(lcPlatformCommand) << platform_ << warning;
    emitValidationFailure(warning, ValidationFailure::Fatal);

    if (errCode == device::Device::ErrorCode::DeviceDisconnected) {
        finishCommand(CommandResult::DeviceDisconnected);
    } else {
        finishCommand(CommandResult::DeviceError);
    }
}

void BasePlatformCommand::finishCommand(CommandResult result)
{
    // If result is CommandResult::RepeatAndWait it means that command was successfully finished
    // (ACK and notification are processed) and it is expected to be sent again with new data,
    // so there is no need to disconnect slots (little optimization).
    if ((result != CommandResult::RepeatAndWait) && deviceSignalsConnected_) {
        disconnect(platform_.get(), &Platform::messageReceived, this, &BasePlatformCommand::handleDeviceResponse);
        disconnect(platform_.get(), &Platform::messageSent, this, &BasePlatformCommand::handleMessageSent);
        disconnect(platform_.get(), &Platform::deviceError, this, &BasePlatformCommand::handleDeviceError);
        deviceSignalsConnected_ = false;
    }
    emit finished(result, status_);
}

QString BasePlatformCommand::generateWrongResponseError(const PlatformMessage& response) const
{
    QString prefix;
    const QString& errorString = response.jsonErrorString();
    if (errorString.isEmpty()) {
        prefix = QStringLiteral("Wrong or unexpected response: '");
    } else {
        prefix = QStringLiteral("Invalid response. Error at offset ") + QString::number(response.jsonErrorOffset())
                 + QStringLiteral(": '") + errorString + QStringLiteral("' Invalid JSON: '");
    }
    return prefix + response.rawNoNewlineEnd() + QStringLiteral("'.");
}

void BasePlatformCommand::emitValidationFailure(QString warning, ValidationFailure failure)
{
    if (platformValidation_) {
        emit validationFailure(warning, failure);
    }
}

void BasePlatformCommand::setDeviceVersions(const char* bootloaderVer, const char* applicationVer) {
    platform_->setVersions(bootloaderVer, applicationVer);
}

void BasePlatformCommand::setDeviceProperties(const char* name, const char* platformId, const char* classId, Platform::ControllerType type) {
    platform_->setProperties(name, platformId, classId, type);
}

void BasePlatformCommand::setDeviceAssistedProperties(const char* platformId, const char* classId, const char* fwClassId) {
    platform_->setAssistedProperties(platformId, classId, fwClassId);
}

void BasePlatformCommand::setDeviceBootloaderMode(bool inBootloaderMode) {
    platform_->setBootloaderMode(inBootloaderMode);
}

void BasePlatformCommand::setDeviceApiVersion(Platform::ApiVersion apiVersion) {
    platform_->setApiVersion(apiVersion);
}

}  // namespace
