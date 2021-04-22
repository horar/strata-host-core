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
    if (deviceSignalsConnected_ == false) {
        connect(platform_.get(), &Platform::messageReceived, this, &BasePlatformCommand::handleDeviceResponse);
        connect(platform_.get(), &Platform::deviceError, this, &BasePlatformCommand::handleDeviceError);
        deviceSignalsConnected_ = true;
    }

    QString logMsg(QStringLiteral("Sending '") + cmdName_ + QStringLiteral("' command."));
    if (this->logSendMessage()) {
        qCInfo(logCategoryPlatformCommand) << platform_ << logMsg;
    } else {
        qCDebug(logCategoryPlatformCommand) << platform_ << logMsg;
    }

    ackOk_ = false;  // "ok" ACK for this command

    if (platform_->sendMessage(this->message(), lockId)) {
        responseTimer_.setInterval(ackTimeout_);
        responseTimer_.start();
    } else {
        qCCritical(logCategoryPlatformCommand) << platform_ << QStringLiteral("Cannot send '") + cmdName_ + QStringLiteral("' command.");
        finishCommand(CommandResult::Unsent);
    }
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

void BasePlatformCommand::handleDeviceResponse(QByteArray deviceId, const QByteArray data)
{
    Q_UNUSED(deviceId)
    rapidjson::Document doc;

    if (CommandValidator::parseJsonCommand(data, doc) == false) {
        qCWarning(logCategoryPlatformCommand) << platform_ << "Cannot parse JSON: '" << data << "'.";
        return;
    }

    if (doc.HasMember(JSON_ACK)) {
        if (CommandValidator::validate(CommandValidator::JsonType::ack, doc)) {
            const QString ackStr = doc[JSON_ACK].GetString();
            qCDebug(logCategoryPlatformCommand) << platform_ << "Received '" << ackStr << "' ACK.";
            const rapidjson::Value& payload = doc[JSON_PAYLOAD];

            ackOk_ = payload[JSON_RETURN_VALUE].GetBool();

            if (ackStr == cmdName_) {
                responseTimer_.stop();
                if (ackOk_) {
                    responseTimer_.setInterval(notificationTimeout_);
                    responseTimer_.start();
                } else {
                    qCWarning(logCategoryPlatformCommand) << platform_ << "ACK for '" << cmdName_ << "' command is not OK: '"
                                                          << payload[JSON_RETURN_STRING].GetString() << "'.";
                    // ACK is not 'ok' - command is rejected by device
                    finishCommand(this->onReject());
                }
            } else {
                qCWarning(logCategoryPlatformCommand) << platform_ << "Received wrong ACK. Expected '" << cmdName_ << "', got '" << ackStr << "'.";
                if (ackOk_ == false) {
                    qCWarning(logCategoryPlatformCommand) << platform_ << "ACK is not OK: '" << payload[JSON_RETURN_STRING].GetString() << "'.";
                }
            }
        } else {
            logWrongResponse(data);
        }

        return;
    }

    if (doc.HasMember(JSON_NOTIFICATION)) {
        CommandResult result = CommandResult::Failure;
        if (this->processNotification(doc, result)) {
            responseTimer_.stop();

            qCDebug(logCategoryPlatformCommand) << platform_ << "Processed '" << cmdName_ << "' notification.";

            if (ackOk_) {
                if (result == CommandResult::FinaliseOperation || result == CommandResult::Failure) {
                    if (result == CommandResult::Failure) {
                        qCWarning(logCategoryPlatformCommand) << platform_ << "Received faulty notification: '" << data << "'.";
                    }

                    const QByteArray status = CommandValidator::notificationStatus(doc);
                    if (status.isEmpty() == false) {
                        qCInfo(logCategoryPlatformCommand) << platform_ << "Command '" << cmdName_ << "' returned '" << status << "'.";
                    }
                }
                finishCommand(result);
            } else {
                qCWarning(logCategoryPlatformCommand) << platform_ << "Received notification without previous ACK.";
                finishCommand(CommandResult::MissingAck);
            }
        } else {
            logWrongResponse(data);
        }

        return;
    }

    logWrongResponse(data);
}

void BasePlatformCommand::handleResponseTimeout()
{
    if (cmdType_ != CommandType::Wait) {
        qCWarning(logCategoryPlatformCommand) << platform_ << "Command '" << cmdName_ << "' timed out.";
    }
    finishCommand(this->onTimeout());
}

void BasePlatformCommand::handleDeviceError(QByteArray deviceId, device::Device::ErrorCode errCode, QString errStr)
{
    Q_UNUSED(deviceId)

    responseTimer_.stop();
    qCCritical(logCategoryPlatformCommand) << platform_ << "Error: " << errStr;

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
        disconnect(platform_.get(), &Platform::deviceError, this, &BasePlatformCommand::handleDeviceError);
        deviceSignalsConnected_ = false;
    }
    emit finished(result, status_);
}

void BasePlatformCommand::logWrongResponse(const QByteArray& response)
{
    qCWarning(logCategoryPlatformCommand) << platform_ << "Received wrong, unexpected or malformed response: '" << response << "'.";
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
