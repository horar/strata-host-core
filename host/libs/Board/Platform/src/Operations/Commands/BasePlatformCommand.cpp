#include "BasePlatformCommand.h"

#include "PlatformCommandConstants.h"
#include <PlatformOperationsStatus.h>

#include <rapidjson/document.h>

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

namespace strata::platform::command {

BasePlatformCommand::BasePlatformCommand(const device::DevicePtr& device, const QString& commandName, CommandType cmdType)
    : cmdName_(commandName),
      cmdType_(cmdType),
      device_(device),
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
        connect(device_.get(), &device::Device::msgFromDevice, this, &BasePlatformCommand::handleDeviceResponse);
        connect(device_.get(), &device::Device::deviceError, this, &BasePlatformCommand::handleDeviceError);
        deviceSignalsConnected_ = true;
    }

    QString logMsg(QStringLiteral("Sending '") + cmdName_ + QStringLiteral("' command."));
    if (this->logSendMessage()) {
        qCInfo(logCategoryPlatformCommand) << device_ << logMsg;
    } else {
        qCDebug(logCategoryPlatformCommand) << device_ << logMsg;
    }

    ackOk_ = false;  // "ok" ACK for this command

    if (device_->sendMessage(this->message(), lockId)) {
        responseTimer_.setInterval(ackTimeout_);
        responseTimer_.start();
    } else {
        qCCritical(logCategoryPlatformCommand) << device_ << QStringLiteral("Cannot send '") + cmdName_ + QStringLiteral("' command.");
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
    // If reject is not a problem, reimplement this method and return to 'Done'.
    return CommandResult::Reject;
}

bool BasePlatformCommand::logSendMessage() const {
    return true;
}

void BasePlatformCommand::handleDeviceResponse(const QByteArray data)
{
    rapidjson::Document doc;

    if (CommandValidator::parseJsonCommand(data, doc) == false) {
        qCWarning(logCategoryPlatformCommand) << device_ << "Cannot parse JSON: '" << data << "'.";
        return;
    }

    if (doc.HasMember(JSON_ACK)) {
        if (CommandValidator::validate(CommandValidator::JsonType::ack, doc)) {
            const QString ackStr = doc[JSON_ACK].GetString();
            qCDebug(logCategoryPlatformCommand) << device_ << "Received '" << ackStr << "' ACK.";
            const rapidjson::Value& payload = doc[JSON_PAYLOAD];

            ackOk_ = payload[JSON_RETURN_VALUE].GetBool();

            if (ackStr == cmdName_) {
                responseTimer_.stop();
                if (ackOk_) {
                    responseTimer_.setInterval(notificationTimeout_);
                    responseTimer_.start();
                } else {
                    qCWarning(logCategoryPlatformCommand) << device_ << "ACK for '" << cmdName_ << "' command is not OK: '"
                                                          << payload[JSON_RETURN_STRING].GetString() << "'.";
                    // ACK is not 'ok' - command is rejected by device
                    finishCommand(this->onReject());
                }
            } else {
                qCWarning(logCategoryPlatformCommand) << device_ << "Received wrong ACK. Expected '" << cmdName_ << "', got '" << ackStr << "'.";
                if (ackOk_ == false) {
                    qCWarning(logCategoryPlatformCommand) << device_ << "ACK is not OK: '" << payload[JSON_RETURN_STRING].GetString() << "'.";
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

            qCDebug(logCategoryPlatformCommand) << device_ << "Processed '" << cmdName_ << "' notification.";

            if (ackOk_) {
                if (result == CommandResult::FinaliseOperation || result == CommandResult::Failure) {
                    if (result == CommandResult::Failure) {
                        qCWarning(logCategoryPlatformCommand) << device_ << "Received faulty notification: '" << data << "'.";
                    }

                    const QByteArray status = CommandValidator::notificationStatus(doc);
                    if (status.isEmpty() == false) {
                        qCInfo(logCategoryPlatformCommand) << device_ << "Command '" << cmdName_ << "' retruned '" << status << "'.";
                    }
                }
                finishCommand(result);
            } else {
                qCWarning(logCategoryPlatformCommand) << device_ << "Received notification without previous ACK.";
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
        qCWarning(logCategoryPlatformCommand) << device_ << "Command '" << cmdName_ << "' timed out.";
    }
    finishCommand(this->onTimeout());
}

void BasePlatformCommand::handleDeviceError(device::Device::ErrorCode errCode, QString errStr)
{
    Q_UNUSED(errCode)
    responseTimer_.stop();
    qCCritical(logCategoryPlatformCommand) << device_ << "Error: " << errStr;
    finishCommand(CommandResult::DeviceError);
}

void BasePlatformCommand::finishCommand(CommandResult result)
{
    if ((result != CommandResult::Repeat) && deviceSignalsConnected_) {
        disconnect(device_.get(), &device::Device::msgFromDevice, this, &BasePlatformCommand::handleDeviceResponse);
        disconnect(device_.get(), &device::Device::deviceError, this, &BasePlatformCommand::handleDeviceError);
    }
    emit finished(result, status_);
}

void BasePlatformCommand::logWrongResponse(const QByteArray& response)
{
    qCWarning(logCategoryPlatformCommand) << device_ << "Received wrong, unexpected or malformed response: '" << response << "'.";
}

void BasePlatformCommand::setDeviceVersions(const char* bootloaderVer, const char* applicationVer) {
    device_->setVersions(bootloaderVer, applicationVer);
}

void BasePlatformCommand::setDeviceProperties(const char* name, const char* platformId, const char* classId, device::Device::ControllerType type) {
    device_->setProperties(name, platformId, classId, type);
}

void BasePlatformCommand::setDeviceAssistedProperties(const char* platformId, const char* classId, const char* fwClassId) {
    device_->setAssistedProperties(platformId, classId, fwClassId);
}

void BasePlatformCommand::setDeviceBootloaderMode(bool inBootloaderMode) {
    device_->setBootloaderMode(inBootloaderMode);
}

void BasePlatformCommand::setDeviceApiVersion(device::Device::ApiVersion apiVersion) {
    device_->setApiVersion(apiVersion);
}

}  // namespace
