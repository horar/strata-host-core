#include "BaseDeviceCommand.h"

#include <DeviceOperationsStatus.h>

namespace strata::device::command {

BaseDeviceCommand::BaseDeviceCommand(const device::DevicePtr& device, const QString& commandName) :
    cmdName_(commandName), device_(device), ackReceived_(false),
    result_(CommandResult::InProgress), status_(operation::DEFAULT_STATUS) { }

BaseDeviceCommand::~BaseDeviceCommand() { }

void BaseDeviceCommand::setAckReceived() {
    ackReceived_ = true;
}

bool BaseDeviceCommand::ackReceived() const {
    return ackReceived_;
}

void BaseDeviceCommand::setCommandRejected() {
    result_ = CommandResult::Reject;
}

void BaseDeviceCommand::onTimeout() {
    // Default result is 'InProgress' - command timed out, finish operation with failure.
    // If timeout is not a problem, reimplement this method and set result to 'Done' or 'Retry'.
    result_ = CommandResult::InProgress;
}

bool BaseDeviceCommand::logSendMessage() const {
    return true;
}

std::chrono::milliseconds BaseDeviceCommand::waitBeforeNextCommand() const {
    return std::chrono::milliseconds(0);
}

const QString BaseDeviceCommand::name() const {
    return cmdName_;
}

CommandResult BaseDeviceCommand::result() const {
    return result_;
}

int BaseDeviceCommand::status() const {
    return status_;
}

void BaseDeviceCommand::setDeviceProperties(const char* name, const char* platformId, const char* classId, const char* btldrVer, const char* applVer) {
    device_->setProperties(name, platformId, classId, btldrVer, applVer);
}

void BaseDeviceCommand::setDeviceBootloaderMode(bool inBootloaderMode) {
    device_->setBootloaderMode(inBootloaderMode);
}

void BaseDeviceCommand::setDeviceApiVersion(device::Device::ApiVersion apiVersion) {
    device_->setApiVersion(apiVersion);
}

}  // namespace
