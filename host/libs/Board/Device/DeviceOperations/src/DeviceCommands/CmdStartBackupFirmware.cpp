#include "CmdStartBackupFirmware.h"
#include "DeviceOperationsConstants.h"

#include <cstring>

#include <DeviceOperationsFinished.h>

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

namespace strata::device::command {

CmdStartBackupFirmware::CmdStartBackupFirmware(const device::DevicePtr& device) :
    BaseDeviceCommand(device, QStringLiteral("start_backup_firmware")) { }

QByteArray CmdStartBackupFirmware::message() {
    return QByteArray("{\"cmd\":\"start_backup_firmware\",\"payload\":{}}");
}

bool CmdStartBackupFirmware::processNotification(rapidjson::Document& doc) {
    if (CommandValidator::validate(CommandValidator::JsonType::startBackupFirmwareRes, doc)) {
        const rapidjson::Value& payload = doc[JSON_NOTIFICATION][JSON_PAYLOAD];
        if (payload.HasMember(JSON_STATUS)) {
            const char* status = payload[JSON_STATUS].GetString();
            if (std::strcmp(status, CSTR_NO_FIRMWARE) == 0) {
                qCWarning(logCategoryDeviceOperations) << device_ << "Nothing to backup, board has no firmware.";
                result_ = CommandResult::FinaliseOperation;
            } else {
                qCWarning(logCategoryDeviceOperations) << device_ << "Bad notification status: '" << status << "'.";
                result_ = CommandResult::Failure;
            }
        } else {
            const rapidjson::Value& size = payload[JSON_SIZE];
            const rapidjson::Value& chunks = payload[JSON_CHUNKS];
            //const rapidjson::Value& md5 = payload[JSON_MD5];
            if (size.IsUint() && chunks.IsUint()) {
                chunks_ = chunks.GetUint();
                /* these values ​​are not used yet
                size_ = size.GetUint();
                md5_ = md5.GetString();
                */
                result_ = CommandResult::Done;
            } else {
                qCWarning(logCategoryDeviceOperations) << device_ << "Wrong format of notification.";
                result_ = CommandResult::Failure;
            }
        }
        return true;
    } else {
        return false;
    }
}

int CmdStartBackupFirmware::dataForFinish() const {
    // OPERATION_BACKUP_NO_FIRMWARE or number of firmware chunks is used as data for finished() signal
    return (result_ == CommandResult::FinaliseOperation) ? OPERATION_BACKUP_NO_FIRMWARE : static_cast<int>(chunks_);
}

}  // namespace
