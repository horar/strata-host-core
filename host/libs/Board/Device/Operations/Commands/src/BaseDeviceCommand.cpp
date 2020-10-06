#include "BaseDeviceCommand.h"

#include <DeviceOperationsFinished.h>

namespace strata::device::command {

BaseDeviceCommand::BaseDeviceCommand(const device::DevicePtr& device, const QString& commandName) :
    cmdName_(commandName), device_(device), ackReceived_(false), result_(CommandResult::InProgress) { }

BaseDeviceCommand::~BaseDeviceCommand() { }

void BaseDeviceCommand::setAckReceived() {
    ackReceived_ = true;
}

bool BaseDeviceCommand::ackReceived() const {
    return ackReceived_;
}

void BaseDeviceCommand::onTimeout() {
    // Default result is 'InProgress' - command timed out, finish operation with failure.
    // In some cases timeout is not a problem, result is 'Done' or 'Retry' then.
    result_ = CommandResult::InProgress;
}

bool BaseDeviceCommand::logSendMessage() const {
    return true;
}

std::chrono::milliseconds BaseDeviceCommand::waitBeforeNextCommand() const {
    return std::chrono::milliseconds(0);
}

int BaseDeviceCommand::dataForFinish() const {
    return operation::DEFAULT_DATA;  // default value for finished() signal
}

const QString BaseDeviceCommand::name() const {
    return cmdName_;
}

CommandResult BaseDeviceCommand::result() const {
    return result_;
}

void BaseDeviceCommand::setDeviceProperties(const char* name, const char* platformId, const char* classId, const char* btldrVer, const char* applVer) {
    device_->setProperties(name, platformId, classId, btldrVer, applVer);
}

}  // namespace
