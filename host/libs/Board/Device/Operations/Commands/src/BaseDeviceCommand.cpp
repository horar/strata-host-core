#include "BaseDeviceCommand.h"

#include "DeviceOperationsConstants.h"
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
      deviceSignalsConnected_(false)
{
    responseTimer_.setSingleShot(true);
    responseTimer_.setInterval(RESPONSE_TIMEOUT);
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
        responseTimer_.start();
    } else {
        qCCritical(logCategoryDeviceCommand) << device_ << QStringLiteral("Cannot send '") + cmdName_ + QStringLiteral("' command.");
        finishCommand(CommandResult::Unsent);
    }
}

// If method 'sendCommand' is overriden, probably this method should be overriden too.
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

void BaseDeviceCommand::setResponseTimeout(std::chrono::milliseconds responseInterval)
{
    responseTimer_.setInterval(responseInterval);
}

CommandResult BaseDeviceCommand::onTimeout() {
    // Default result is 'Timeout' - command timed out.
    // If timeout is not a problem, reimplement this method and return 'Done' or 'Retry'.
    return CommandResult::Timeout;
}

CommandResult BaseDeviceCommand::onReject() {
    // Default result is 'Reject' - command was rejected.
    // If reject is not a problem, reimplement this method and return to 'Done'.
    return CommandResult::Reject;
}

bool BaseDeviceCommand::logSendMessage() const {
    return true;
}

void BaseDeviceCommand::handleDeviceResponse(const QByteArray data)
{
    rapidjson::Document doc;

    if (CommandValidator::parseJsonCommand(data, doc) == false) {
        qCWarning(logCategoryDeviceOperations) << device_ << "Cannot parse JSON: '" << data << "'.";
        return;
    }

    if (doc.HasMember(JSON_ACK)) {
        if (CommandValidator::validate(CommandValidator::JsonType::ack, doc)) {
            const QString ackStr = doc[JSON_ACK].GetString();
            qCDebug(logCategoryDeviceOperations) << device_ << "Received '" << ackStr << "' ACK.";
            const rapidjson::Value& payload = doc[JSON_PAYLOAD];

            ackOk_ = payload[JSON_RETURN_VALUE].GetBool();

            if (ackStr == cmdName_) {
                if (ackOk_ == false) {
                    qCWarning(logCategoryDeviceOperations) << device_ << "ACK for '" << cmdName_ << "' command is not OK: '"
                                                           << payload[JSON_RETURN_STRING].GetString() << "'.";
                    // ACK is not 'ok' - command is rejected by device
                    finishCommand(this->onReject());
                }
            } else {
                qCWarning(logCategoryDeviceOperations) << device_ << "Received wrong ACK. Expected '" << cmdName_ << "', got '" << ackStr << "'.";
                if (ackOk_ == false) {
                    qCWarning(logCategoryDeviceOperations) << device_ << "ACK is not OK: '" << payload[JSON_RETURN_STRING].GetString() << "'.";
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

            if (ackOk_ == false) {
                qCWarning(logCategoryDeviceOperations) << device_ << "Received notification without previous ACK.";
            }
            qCDebug(logCategoryDeviceOperations) << device_ << "Processed '" << cmdName_ << "' notification.";

            if (result == CommandResult::FinaliseOperation || result == CommandResult::Failure) {
                if (result == CommandResult::Failure) {
                    qCWarning(logCategoryDeviceOperations) << device_ << "Received faulty notification: '" << data << "'.";
                }

                const QByteArray status = CommandValidator::notificationStatus(doc);
                if (status.isEmpty() == false) {
                    qCInfo(logCategoryDeviceOperations) << device_ << "Command '" << cmdName_ << "' retruned '" << status << "'.";
                }
            }

            finishCommand(result);
        } else {
            logWrongResponse(data);
        }

        return;
    }

    logWrongResponse(data);
}

void BaseDeviceCommand::handleResponseTimeout()
{
    qCWarning(logCategoryDeviceOperations) << device_ << "Command '" << cmdName_ << "' timed out.";
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
    if ((result != CommandResult::Repeat) && deviceSignalsConnected_) {
        disconnect(device_.get(), &Device::msgFromDevice, this, &BaseDeviceCommand::handleDeviceResponse);
        disconnect(device_.get(), &Device::deviceError, this, &BaseDeviceCommand::handleDeviceError);
    }
    emit finished(result, status_);
}

void BaseDeviceCommand::logWrongResponse(const QByteArray& response)
{
    qCWarning(logCategoryDeviceOperations) << device_ << "Received wrong, unexpected or malformed response: '" << response << "'.";
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
