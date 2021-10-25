/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "CmdStartBackupFirmware.h"
#include "PlatformCommandConstants.h"

#include <cstring>

#include <PlatformOperationsStatus.h>

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

namespace strata::platform::command {

CmdStartBackupFirmware::CmdStartBackupFirmware(const PlatformPtr& platform) :
    BasePlatformCommand(platform, QStringLiteral("start_backup_firmware"), CommandType::StartBackupFirmware)
{ }

QByteArray CmdStartBackupFirmware::message() {
    return QByteArray("{\"cmd\":\"start_backup_firmware\",\"payload\":{}}");
}

bool CmdStartBackupFirmware::processNotification(const rapidjson::Document& doc, CommandResult& result) {
    if (CommandValidator::validateNotification(CommandValidator::JsonType::startBackupFirmwareNotif, doc)) {
        const rapidjson::Value& payload = doc[JSON_NOTIFICATION][JSON_PAYLOAD];
        if (payload.HasMember(JSON_STATUS)) {
            const char* jsonStatus = payload[JSON_STATUS].GetString();
            if (std::strcmp(jsonStatus, CSTR_NO_FIRMWARE) == 0) {
                qCWarning(lcPlatformCommand) << platform_ << "Nothing to backup, board has no firmware.";
                result = CommandResult::FinaliseOperation;
                status_ = operation::NO_FIRMWARE;
            } else {
                qCWarning(lcPlatformCommand) << platform_ << "Bad notification status: '" << jsonStatus << "'.";
                result = CommandResult::Failure;
            }
        } else {
            const rapidjson::Value& size = payload[JSON_SIZE];
            const rapidjson::Value& chunks = payload[JSON_CHUNKS];
            //const rapidjson::Value& md5 = payload[JSON_MD5];
            if (size.IsUint() && chunks.IsUint()) {
                chunks_ = chunks.GetUint();
                size_ = size.GetUint();
                qCInfo(lcPlatformCommand) << platform_ << "Going to backup firmware with size " << size_ << " bytes.";
                /* this value is not used yet
                md5_ = md5.GetString();
                */
                result = CommandResult::DoneAndWait;
                status_ = operation::BACKUP_STARTED;
            } else {
                qCWarning(lcPlatformCommand) << platform_ << "Wrong format of notification.";
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

uint CmdStartBackupFirmware::backupSize() const {
    return size_;
}

}  // namespace
