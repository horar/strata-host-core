#include "BasePlatformCommand.h"

#include <PlatformOperationsStatus.h>

namespace strata::platform::command {

BasePlatformCommand::BasePlatformCommand(const device::DevicePtr& device, const QString& commandName, CommandType cmdType) :
    cmdName_(commandName), cmdType_(cmdType), device_(device), ackOk_(false),
    result_(CommandResult::InProgress), status_(operation::DEFAULT_STATUS) { }

BasePlatformCommand::~BasePlatformCommand() { }

void BasePlatformCommand::commandAcknowledged() {
    ackOk_ = true;
}

bool BasePlatformCommand::isCommandAcknowledged() const {
    return ackOk_;
}

void BasePlatformCommand::commandRejected() {
    result_ = CommandResult::Reject;
}

void BasePlatformCommand::onTimeout() {
    // Default result is 'InProgress' - command timed out, finish operation with failure.
    // If timeout is not a problem, reimplement this method and set result to 'Done' or 'Retry'.
    result_ = CommandResult::InProgress;
}

bool BasePlatformCommand::logSendMessage() const {
    return true;
}

const QString BasePlatformCommand::name() const {
    return cmdName_;
}

CommandType BasePlatformCommand::type() const {
    return cmdType_;
}

CommandResult BasePlatformCommand::result() const {
    return result_;
}

int BasePlatformCommand::status() const {
    return status_;
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
