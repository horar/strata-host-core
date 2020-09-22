#include "CmdStartFlash.h"
#include "DeviceOperationsConstants.h"

#include <CommandValidator.h>

namespace strata::device::command {

CmdStartFlash::CmdStartFlash(const device::DevicePtr& device, int size, int chunks, const QString& md5, bool flashFirmware) :
    BaseDeviceCommand(device, (flashFirmware) ? QStringLiteral("start_flash_firmware") : QStringLiteral("start_flash_bootloader")),
    size_(size), chunks_(chunks), md5_(md5.toUtf8()), flashFirmware_(flashFirmware) { }

QByteArray CmdStartFlash::message() {
    QByteArray cmd = (flashFirmware_) ? "start_flash_firmware" : "start_flash_bootloader";
    return QByteArray(
        "{\"cmd\":\"" + cmd + "\",\"payload\":{\"size\":" + QByteArray::number(size_) +
        ",\"chunks\":" + QByteArray::number(chunks_) + ",\"md5\":\"" + md5_ + "\"}}"
    );
}

bool CmdStartFlash::processNotification(rapidjson::Document& doc) {
    CommandValidator::JsonType jsonType = (flashFirmware_)
                                          ? CommandValidator::JsonType::startFlashFirmwareNotif
                                          : CommandValidator::JsonType::startFlashBootloaderNotif;
    if (CommandValidator::validateNotification(jsonType, doc)) {
        const rapidjson::Value& status = doc[JSON_NOTIFICATION][JSON_PAYLOAD][JSON_STATUS];
        result_ = (status == JSON_OK) ? CommandResult::Partial : CommandResult::Failure;
        return true;
    } else {
        return false;
    }
}

}  // namespace
