#include "CmdUpdateFirmware.h"
#include "DeviceOperationsConstants.h"
#include <DeviceOperationsFinished.h>

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

namespace strata::device::command {

CmdUpdateFirmware::CmdUpdateFirmware(const device::DevicePtr& device) :
    BaseDeviceCommand(device, QStringLiteral("update_firmware")) { }

QByteArray CmdUpdateFirmware::message() {
    return QByteArray("{\"cmd\":\"update_firmware\"}");
}

bool CmdUpdateFirmware::processNotification(rapidjson::Document& doc) {
    if (CommandValidator::validate(CommandValidator::JsonType::updateFirmwareRes, doc)) {
        const rapidjson::Value& status = doc[JSON_NOTIFICATION][JSON_PAYLOAD][JSON_STATUS];
        result_ = (status == JSON_OK) ? CommandResult::Done : CommandResult::Failure;
        return true;
    } else {
        return false;
    }
}

bool CmdUpdateFirmware::skip() {
    if (device_->property(device::DeviceProperties::verboseName) == QSTR_BOOTLOADER) {
        qCInfo(logCategoryDeviceOperations) << device_ << "Platform already in bootloader mode. Ready for firmware operations.";
        result_ = CommandResult::FinaliseOperation;
        return true;
    } else {
        return false;
    }
}

std::chrono::milliseconds CmdUpdateFirmware::waitBeforeNextCommand() const {
    // Bootloader takes 5 seconds to start (known issue related to clock source).
    // Platform and bootloader uses the same setting for clock source.
    // Clock source for bootloader and application must match. Otherwise when application jumps to bootloader,
    // it will have a hardware fault which requires board to be reset.
    qCInfo(logCategoryDeviceOperations) << device_ << "Waiting 5 seconds for bootloader to start.";
    return std::chrono::milliseconds(5500);
}

int CmdUpdateFirmware::dataForFinish() const {
    // If this command was skipped, return OPERATION_ALREADY_IN_BOOTLOADER (1) instead of default value OPERATION_DEFAULT_DATA (INT_MIN).
    return (result_ == CommandResult::FinaliseOperation) ? OPERATION_ALREADY_IN_BOOTLOADER : OPERATION_DEFAULT_DATA;
}

}  // namespace
