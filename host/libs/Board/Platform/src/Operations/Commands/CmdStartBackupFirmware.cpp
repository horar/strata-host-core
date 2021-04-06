#include "CmdStartBackupFirmware.h"
#include "PlatformCommandConstants.h"

#include <cstring>

#include <PlatformOperationsStatus.h>

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

namespace strata::platform::command {

CmdStartBackupFirmware::CmdStartBackupFirmware(const device::DevicePtr& device) :
    BasePlatformCommand(device, QStringLiteral("start_backup_firmware"), CommandType::StartBackupFirmware)
{ }

QByteArray CmdStartBackupFirmware::message() {
    return QByteArray("{\"cmd\":\"start_backup_firmware\",\"payload\":{}}");
}

bool CmdStartBackupFirmware::processNotification(rapidjson::Document& doc, CommandResult& result) {
    if (CommandValidator::validateNotification(CommandValidator::JsonType::startBackupFirmwareNotif, doc)) {
        const rapidjson::Value& payload = doc[JSON_NOTIFICATION][JSON_PAYLOAD];
        if (payload.HasMember(JSON_STATUS)) {
            const char* jsonStatus = payload[JSON_STATUS].GetString();
            if (std::strcmp(jsonStatus, CSTR_NO_FIRMWARE) == 0) {
                qCWarning(logCategoryPlatformCommand) << device_ << "Nothing to backup, board has no firmware.";
                result = CommandResult::FinaliseOperation;
                status_ = operation::NO_FIRMWARE;
            } else {
                qCWarning(logCategoryPlatformCommand) << device_ << "Bad notification status: '" << jsonStatus << "'.";
                result = CommandResult::Failure;
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
                result = CommandResult::DoneAndWait;
                status_ = operation::BACKUP_STARTED;
            } else {
                qCWarning(logCategoryPlatformCommand) << device_ << "Wrong format of notification.";
                result = CommandResult::Failure;
            }
        }
        return true;
    } else {
        return false;
    }
}

int CmdStartBackupFirmware::totalChunks() const {
    return static_cast<int>(chunks_);
}

}  // namespace
