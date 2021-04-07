#include "BaseDeviceCommand.h"

#include "DeviceCommandConstants.h"
#include <DeviceOperationsStatus.h>

#include <rapidjson/document.h>

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

namespace strata::device::command {

BaseDeviceCommand::BaseDeviceCommand(const DevicePtr& device, const QString& commandName, CommandType cmdType)
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
    connect(&responseTimer_, &QTimer::timeout, this, &BaseDeviceCommand::handleResponseTimeout);
}

BaseDeviceCommand::~BaseDeviceCommand() { }

// Do not override this method (unless you really need to).
void BaseDeviceCommand::sendCommand(quintptr lockId)
{
    if (deviceSignalsConnected_ == false) {
        connect(device_.get(), &Device::msgFromDevice, this, &BaseDeviceCommand::handleDeviceResponse);
        connect(device_.get(), &Device::deviceError, this, &BaseDeviceCommand::handleDeviceError);
        deviceSignalsConnected_ = true;
    }

    QString logMsg(QStringLiteral("Sending '") + cmdName_ + QStringLiteral("' command."));
    if (this->logSendMessage()) {
        qCInfo(logCategoryDeviceCommand) << device_ << logMsg;
    } else {
        qCDebug(logCategoryDeviceCommand) << device_ << logMsg;
    }

    ackOk_ = false;  // "ok" ACK for this command

    if (device_->sendMessage(this->message(), lockId)) {
        responseTimer_.setInterval(ackTimeout_);
        responseTimer_.start();
    } else {
        qCCritical(logCategoryDeviceCommand) << device_ << QStringLiteral("Cannot send '") + cmdName_ + QStringLiteral("' command.");
        finishCommand(CommandResult::Unsent);
    }
}

// If method 'sendCommand' is overriden, check if this method is still valid.
// If is not, override it too.
void BaseDeviceCommand::cancel()
{
    responseTimer_.stop();
    finishCommand(CommandResult::Cancel);
}

const QString BaseDeviceCommand::name() const {
    return cmdName_;
}

CommandType BaseDeviceCommand::type() const {
    return cmdType_;
}

void BaseDeviceCommand::setAckTimeout(std::chrono::milliseconds ackTimeout)
{
    ackTimeout_ = ackTimeout;
}

void BaseDeviceCommand::setNotificationTimeout(std::chrono::milliseconds notificationTimeout)
{
    notificationTimeout_ = notificationTimeout;
}

CommandResult BaseDeviceCommand::onTimeout() {
    // Default result is 'Timeout' - command timed out.
    // If timeout is not a problem, reimplement this method and return 'Done' or 'Retry'.
    return CommandResult::Timeout;
}

CommandResult BaseDeviceCommand::onReject() {
    // Default result is 'Reject' - command was rejected.
    // If reject is not a problem, reimplement this method and return 'Done'.
    return CommandResult::Reject;
}

bool BaseDeviceCommand::logSendMessage() const {
    return true;
}

void BaseDeviceCommand::handleDeviceResponse(const QByteArray data)
{
    rapidjson::Document doc;

    if (CommandValidator::parseJsonCommand(data, doc) == false) {
        qCWarning(logCategoryDeviceCommand) << device_ << "Cannot parse JSON: '" << data << "'.";
        return;
    }

    if (doc.HasMember(JSON_ACK)) {
        if (CommandValidator::validate(CommandValidator::JsonType::ack, doc)) {
            const QString ackStr = doc[JSON_ACK].GetString();
            qCDebug(logCategoryDeviceCommand) << device_ << "Received '" << ackStr << "' ACK.";
            const rapidjson::Value& payload = doc[JSON_PAYLOAD];

            ackOk_ = payload[JSON_RETURN_VALUE].GetBool();

            if (ackStr == cmdName_) {
                responseTimer_.stop();
                if (ackOk_) {
                    responseTimer_.setInterval(notificationTimeout_);
                    responseTimer_.start();
                } else {
                    qCWarning(logCategoryDeviceCommand) << device_ << "ACK for '" << cmdName_ << "' command is not OK: '"
                                                           << payload[JSON_RETURN_STRING].GetString() << "'.";
                    // ACK is not 'ok' - command is rejected by device
                    finishCommand(this->onReject());
                }
            } else {
                qCWarning(logCategoryDeviceCommand) << device_ << "Received wrong ACK. Expected '" << cmdName_ << "', got '" << ackStr << "'.";
                if (ackOk_ == false) {
                    qCWarning(logCategoryDeviceCommand) << device_ << "ACK is not OK: '" << payload[JSON_RETURN_STRING].GetString() << "'.";
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

            qCDebug(logCategoryDeviceCommand) << device_ << "Processed '" << cmdName_ << "' notification.";

            if (ackOk_) {
                if (result == CommandResult::FinaliseOperation || result == CommandResult::Failure) {
                    if (result == CommandResult::Failure) {
                        qCWarning(logCategoryDeviceCommand) << device_ << "Received faulty notification: '" << data << "'.";
                    }

                    const QByteArray status = CommandValidator::notificationStatus(doc);
                    if (status.isEmpty() == false) {
                        qCInfo(logCategoryDeviceCommand) << device_ << "Command '" << cmdName_ << "' returned '" << status << "'.";
                    }
                }
                finishCommand(result);
            } else {
                qCWarning(logCategoryDeviceCommand) << device_ << "Received notification without previous ACK.";
                finishCommand(CommandResult::MissingAck);
            }
        } else {
            logWrongResponse(data);
        }

        return;
    }

    logWrongResponse(data);
}

void BaseDeviceCommand::handleResponseTimeout()
{
    if (cmdType_ != CommandType::Wait) {
        qCWarning(logCategoryDeviceCommand) << device_ << "Command '" << cmdName_ << "' timed out.";
    }
    finishCommand(this->onTimeout());
}

void BaseDeviceCommand::handleDeviceError(device::Device::ErrorCode errCode, QString errStr)
{
    Q_UNUSED(errCode)
    responseTimer_.stop();
    qCCritical(logCategoryDeviceCommand) << device_ << "Error: " << errStr;
    finishCommand(CommandResult::DeviceError);
}

void BaseDeviceCommand::finishCommand(CommandResult result)
{
    // If result is CommandResult::RepeatAndWait it means that command was successfully finished
    // (ACK and notification are processed) and it is expected to be sent again with new data,
    // so there is no need to disconnect slots (little optimization).
    if ((result != CommandResult::RepeatAndWait) && deviceSignalsConnected_) {
        disconnect(device_.get(), &Device::msgFromDevice, this, &BaseDeviceCommand::handleDeviceResponse);
        disconnect(device_.get(), &Device::deviceError, this, &BaseDeviceCommand::handleDeviceError);
        deviceSignalsConnected_ = false;
    }
    emit finished(result, status_);
}

void BaseDeviceCommand::logWrongResponse(const QByteArray& response)
{
    qCWarning(logCategoryDeviceCommand) << device_ << "Received wrong, unexpected or malformed response: '" << response << "'.";
}

void BaseDeviceCommand::setDeviceVersions(const char* bootloaderVer, const char* applicationVer) {
    device_->setVersions(bootloaderVer, applicationVer);
}

void BaseDeviceCommand::setDeviceProperties(const char* name, const char* platformId, const char* classId, Device::ControllerType type) {
    device_->setProperties(name, platformId, classId, type);
}

void BaseDeviceCommand::setDeviceAssistedProperties(const char* platformId, const char* classId, const char* fwClassId) {
    device_->setAssistedProperties(platformId, classId, fwClassId);
}

void BaseDeviceCommand::setDeviceBootloaderMode(bool inBootloaderMode) {
    device_->setBootloaderMode(inBootloaderMode);
}

void BaseDeviceCommand::setDeviceApiVersion(Device::ApiVersion apiVersion) {
    device_->setApiVersion(apiVersion);
}

}  // namespace
