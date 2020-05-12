#include "CmdGetFirmwareInfo.h"
#include "DeviceOperationsConstants.h"

#include <CommandValidator.h>

namespace strata {

CmdGetFirmwareInfo::CmdGetFirmwareInfo(const SerialDevicePtr& device, bool requireResponse) :
    BaseDeviceCommand(device, QStringLiteral("get_firmware_info")), requireResponse_(requireResponse) { }

QByteArray CmdGetFirmwareInfo::message() {
    return QByteArray("{\"cmd\":\"get_firmware_info\"}");
}

bool CmdGetFirmwareInfo::processNotification(rapidjson::Document& doc) {
    bool ok = false;
    if (CommandValidator::validate(CommandValidator::JsonType::getFwInfoRes, doc)) {
        const rapidjson::Value& payload = doc[JSON_NOTIFICATION][JSON_PAYLOAD];
        const rapidjson::Value& bootloader = payload[JSON_BOOTLOADER];
        const rapidjson::Value& application = payload[JSON_APPLICATION];
        if (bootloader.MemberCount() > 0) {  // JSON_BOOTLOADER object has some members -> it is not empty
            setDeviceProperties(nullptr, nullptr, nullptr, bootloader[JSON_VERSION].GetString(), nullptr);
            result_ = CommandResult::Done;
            ok = true;
        }
        if (application.MemberCount() > 0) {  // JSON_APPLICATION object has some members -> it is not empty
            setDeviceProperties(nullptr, nullptr, nullptr, nullptr, application[JSON_VERSION].GetString());
            result_ = CommandResult::Done;
            ok = true;
        }
    }
    return ok;
}

void CmdGetFirmwareInfo::onTimeout() {
    result_ = (requireResponse_) ? CommandResult::InProgress : CommandResult::Done;
}

}  // namespace
