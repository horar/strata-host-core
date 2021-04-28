#include "CmdGetFirmwareInfo.h"
#include "PlatformCommandConstants.h"

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

#include <cstring>

namespace strata::platform::command {

CmdGetFirmwareInfo::CmdGetFirmwareInfo(const PlatformPtr& platform, bool requireResponse, uint maxRetries) :
    BasePlatformCommand(platform, QStringLiteral("get_firmware_info"), CommandType::GetFirmwareInfo),
    requireResponse_(requireResponse), maxRetries_(maxRetries), retriesCount_(0)
{ }

QByteArray CmdGetFirmwareInfo::message() {
    return QByteArray("{\"cmd\":\"get_firmware_info\",\"payload\":{}}");
}

bool CmdGetFirmwareInfo::processNotification(const rapidjson::Document& doc, CommandResult& result) {
    if (CommandValidator::validateNotification(CommandValidator::JsonType::getFirmwareInfoNotif, doc)) {
        const rapidjson::Value& payload = doc[JSON_NOTIFICATION][JSON_PAYLOAD];
        const rapidjson::Value& bootloader = payload[JSON_BOOTLOADER];
        const rapidjson::Value& application = payload[JSON_APPLICATION];

        result = CommandResult::Failure;

        if (payload.HasMember(JSON_API_VERSION) &&
            (std::strcmp(payload[JSON_API_VERSION].GetString(), CSTR_API_2_0) == 0)
           ) {
            setDeviceApiVersion(Platform::ApiVersion::v2_0);
        } else {
            setDeviceApiVersion(Platform::ApiVersion::Unknown);
        }

        if (payload.HasMember(JSON_ACTIVE) &&
            (std::strcmp(payload[JSON_ACTIVE].GetString(), CSTR_BOOTLOADER) == 0)
           ) {
            setDeviceBootloaderMode(true);
        } else {
            setDeviceBootloaderMode(false);
        }

        const char* bootloaderVer = nullptr;
        const char* applicationVer = nullptr;
        if (bootloader.MemberCount() > 0) {  // JSON_BOOTLOADER object has some members -> it is not empty
            bootloaderVer = bootloader[JSON_VERSION].GetString();
        }
        if (application.MemberCount() > 0) {  // JSON_APPLICATION object has some members -> it is not empty
            applicationVer = application[JSON_VERSION].GetString();
        }
        if (bootloaderVer || applicationVer) {
            setDeviceVersions(bootloaderVer, applicationVer);
            result = CommandResult::Done;
        }

        return true;
    } else {
        return false;
    }
}

CommandResult CmdGetFirmwareInfo::onTimeout() {
    if (retriesCount_ < maxRetries_) {
        ++retriesCount_;
        qCInfo(logCategoryPlatformCommand) << platform_ << "Going to retry to get firmware info.";
        return CommandResult::Retry;
    } else {
        if (requireResponse_) {
            return CommandResult::Timeout;
        } else {
            setDeviceVersions(nullptr, "");
            return CommandResult::Done;
        }
    }
}

CommandResult CmdGetFirmwareInfo::onReject() {
    if (requireResponse_) {
        return CommandResult::Reject;
    } else {
        setDeviceVersions(nullptr, "");
        return CommandResult::Done;
    }
}

}  // namespace
