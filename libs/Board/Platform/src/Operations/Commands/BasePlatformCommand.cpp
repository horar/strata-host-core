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
      deviceSignalsConnected_(false)
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
        logWrongResponse(message);
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
                    qCWarning(lcPlatformCommand) << platform_ << "ACK for '" << cmdName_ << "' command is not OK: '"
                                                          << payload[JSON_RETURN_STRING].GetString() << "'.";
                    // ACK is not 'ok' - command is rejected by device
                    finishCommand(this->onReject());
                }
            } else {
                qCWarning(lcPlatformCommand) << platform_ << "Received wrong ACK. Expected '" << cmdName_ << "', got '" << ackStr << "'.";
                if (ackOk_ == false) {
                    qCWarning(lcPlatformCommand) << platform_ << "ACK is not OK: '" << payload[JSON_RETURN_STRING].GetString() << "'.";
                } else {
                    ackOk_ = false;  // ACK is for another command, it is not OK.
                }
            }
        } else {
            logWrongResponse(message);
        }

        return;
    }

    if (json.HasMember(JSON_NOTIFICATION)) {
        CommandResult result = CommandResult::Failure;
        if (this->processNotification(json, result)) {
            responseTimer_.stop();

            qCDebug(lcPlatformCommand) << platform_ << "Processed '" << cmdName_ << "' notification.";

            if (ackOk_) {
                if (result == CommandResult::FinaliseOperation || result == CommandResult::Failure) {
                    if (result == CommandResult::Failure) {
                        qCWarning(lcPlatformCommand) << platform_ << "Received faulty notification: '" << message.raw() << "'.";
                    }

                    const QByteArray status = CommandValidator::notificationStatus(json);
                    if (status.isEmpty() == false) {
                        qCInfo(lcPlatformCommand) << platform_ << "Command '" << cmdName_ << "' returned '" << status << "'.";
                    }
                }
                finishCommand(result);
            } else {
                qCWarning(lcPlatformCommand) << platform_ << "Received notification without previous ACK.";
                finishCommand(CommandResult::MissingAck);
            }
        } else {
            logWrongResponse(message);
        }

        return;
    }

    logWrongResponse(message);
}

void BasePlatformCommand::handleResponseTimeout()
{
    if (cmdType_ != CommandType::Wait) {
        qCWarning(lcPlatformCommand) << platform_ << "Command '" << cmdName_ << "' timed out.";
    }
    finishCommand(this->onTimeout());
}

void BasePlatformCommand::handleMessageSent(QByteArray rawMessage, unsigned msgNumber, QString errStr)
{
    Q_UNUSED(rawMessage)
    if ((errStr.isEmpty() == false) && (msgNumber == lastMsgNumber_)) {
        responseTimer_.stop();
        qCCritical(lcPlatformCommand) << platform_ << QStringLiteral("Cannot send '")
            << cmdName_ << QStringLiteral("' command. Error: '") << errStr << '\'';
        finishCommand(CommandResult::Unsent);
    }
}

void BasePlatformCommand::handleDeviceError(device::Device::ErrorCode errCode, QString errStr)
{
    if (errCode == device::Device::ErrorCode::NoError) {
        return;
    }

    responseTimer_.stop();
    qCCritical(lcPlatformCommand) << platform_ << "Error: " << errStr;

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

void BasePlatformCommand::logWrongResponse(const PlatformMessage& message)
{
    qCWarning(lcPlatformCommand) << platform_ << "Received wrong, unexpected or malformed response: '" << message.raw() << "'.";
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
