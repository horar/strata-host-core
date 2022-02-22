/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "CmdStartFlash.h"
#include "PlatformCommandConstants.h"

#include <PlatformOperationsStatus.h>

#include <CommandValidator.h>

namespace strata::platform::command {

CmdStartFlash::CmdStartFlash(const PlatformPtr& platform, int size, int chunks, const QString& md5, bool flashFirmware) :
    BasePlatformCommand(platform,
                      (flashFirmware) ? QStringLiteral("start_flash_firmware") : QStringLiteral("start_flash_bootloader"),
                      (flashFirmware) ? CommandType::StartFlashFirmware : CommandType::StartFlashBootloader),
    size_(size), chunks_(chunks), md5_(md5.toUtf8()), flashFirmware_(flashFirmware)
{ }

QByteArray CmdStartFlash::message() {
    QByteArray cmd = (flashFirmware_) ? "start_flash_firmware" : "start_flash_bootloader";
    return QByteArray(
        "{\"cmd\":\"" + cmd + "\",\"payload\":{\"size\":" + QByteArray::number(size_) +
        ",\"chunks\":" + QByteArray::number(chunks_) + ",\"md5\":\"" + md5_ + "\"}}"
    );
}

bool CmdStartFlash::processNotification(const rapidjson::Document& doc, CommandResult& result) {
    CommandValidator::JsonType jsonType = (flashFirmware_)
                                          ? CommandValidator::JsonType::startFlashFirmwareNotif
                                          : CommandValidator::JsonType::startFlashBootloaderNotif;
    if (CommandValidator::validateNotification(jsonType, doc)) {
        const rapidjson::Value& jsonStatus = doc[JSON_NOTIFICATION][JSON_PAYLOAD][JSON_STATUS];
        if (jsonStatus == JSON_OK) {
            result = CommandResult::DoneAndWait;
            status_ = operation::FLASH_STARTED;
            if (flashFirmware_) { setDeviceVersions(nullptr, ""); }  // clear firmware version
            else { setDeviceVersions("", nullptr); }  // clear bootloader version
        } else {
            result = CommandResult::Failure;
        }
        return true;
    } else {
        return false;
    }
}

}  // namespace
