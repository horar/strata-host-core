#include "CmdUpdateFirmware.h"
#include "DeviceOperationsConstants.h"

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

namespace strata {

CmdUpdateFirmware::CmdUpdateFirmware(const SerialDevicePtr& device) :
    BaseDeviceCommand(device, QStringLiteral("update_firmware")) { }

QByteArray CmdUpdateFirmware::message() {
    return QByteArray("{\"cmd\":\"update_firmware\"}");
}

bool CmdUpdateFirmware::processNotification(rapidjson::Document& doc) {
    if (CommandValidator::validate(CommandValidator::JsonType::updateFwRes, doc)) {
        const rapidjson::Value& status = doc[JSON_NOTIFICATION][JSON_PAYLOAD][JSON_STATUS];
        result_ = (status == JSON_OK) ? CommandResult::Done : CommandResult::Failure;
        return true;
    } else {
        return false;
    }
}

bool CmdUpdateFirmware::skip() {
    if (device_->property(DeviceProperties::verboseName) == QSTR_BOOTLOADER) {
        qCInfo(logCategoryDeviceOperations) << device_.get() << "Platform already in bootloader mode. Ready for firmware operations.";
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
    qCInfo(logCategoryDeviceOperations) << device_.get() << "Waiting 5 seconds for bootloader to start.";
    return std::chrono::milliseconds(5500);
}

int CmdUpdateFirmware::dataForFinish() const {
    // If this command was skipped, return 1 instead of default value INT_MIN.
    return (result_ == CommandResult::FinaliseOperation) ? 1 : INT_MIN;
}

}  // namespace
