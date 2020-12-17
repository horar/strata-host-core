#include "BaseDeviceCommand.h"

#include <DeviceOperationsStatus.h>

namespace strata::device::command {

BaseDeviceCommand::BaseDeviceCommand(const DevicePtr& device, const QString& commandName) :
    cmdName_(commandName), device_(device), ackOk_(false),
    result_(CommandResult::InProgress), status_(operation::DEFAULT_STATUS) { }

BaseDeviceCommand::~BaseDeviceCommand() { }

void BaseDeviceCommand::commandAcknowledged() {
    ackOk_ = true;
}

bool BaseDeviceCommand::isCommandAcknowledged() const {
    return ackOk_;
}

void BaseDeviceCommand::commandRejected() {
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
