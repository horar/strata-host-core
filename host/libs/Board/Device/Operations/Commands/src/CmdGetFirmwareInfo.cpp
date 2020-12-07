#include "CmdGetFirmwareInfo.h"
#include "DeviceOperationsConstants.h"

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

#include <cstring>

namespace strata::device::command {

CmdGetFirmwareInfo::CmdGetFirmwareInfo(const device::DevicePtr& device, bool requireResponse, uint maxRetries) :
    BaseDeviceCommand(device, QStringLiteral("get_firmware_info")),
    requireResponse_(requireResponse), maxRetries_(maxRetries), retriesCount_(0)
{ }

QByteArray CmdGetFirmwareInfo::message() {
    return QByteArray("{\"cmd\":\"get_firmware_info\",\"payload\":{}}");
}

bool CmdGetFirmwareInfo::processNotification(rapidjson::Document& doc) {
    if (CommandValidator::validateNotification(CommandValidator::JsonType::getFirmwareInfoNotif, doc)) {
        const rapidjson::Value& payload = doc[JSON_NOTIFICATION][JSON_PAYLOAD];
        const rapidjson::Value& bootloader = payload[JSON_BOOTLOADER];
        const rapidjson::Value& application = payload[JSON_APPLICATION];

        result_ = CommandResult::Failure;

        if (payload.HasMember(JSON_API_VERSION) &&
            (std::strcmp(payload[JSON_API_VERSION].GetString(), CSTR_API_2_0) == 0)
           ) {
            setDeviceApiVersion(device::Device::ApiVersion::v2_0);
        } else {
            setDeviceApiVersion(device::Device::ApiVersion::Unknown);
        }

        if (payload.HasMember(JSON_ACTIVE) &&
            (std::strcmp(payload[JSON_ACTIVE].GetString(), CSTR_BOOTLOADER) == 0)
           ) {
            setDeviceBootloaderMode(true);
        } else {
            setDeviceBootloaderMode(false);
        }

        if (bootloader.MemberCount() > 0) {  // JSON_BOOTLOADER object has some members -> it is not empty
            setDeviceVersions(bootloader[JSON_VERSION].GetString(), "");
            result_ = CommandResult::Done;
        }

        if (application.MemberCount() > 0) {  // JSON_APPLICATION object has some members -> it is not empty
            setDeviceVersions(nullptr, application[JSON_VERSION].GetString());
            result_ = CommandResult::Done;
        }

        return true;
    } else {
        return false;
    }
}

void CmdGetFirmwareInfo::commandRejected() {
    if (requireResponse_) {
        result_ = CommandResult::Reject;
    } else {
        setDeviceVersions(nullptr, "");
        result_ = CommandResult::Done;
    }
}

void CmdGetFirmwareInfo::onTimeout() {
    if (requireResponse_) {
        if (retriesCount_ < maxRetries_) {
            ++retriesCount_;
            qCInfo(logCategoryDeviceOperations) << device_ << "Going to retry to get firmware info.";
            result_ = CommandResult::Retry;
        } else {
            result_ = CommandResult::InProgress;
        }
    } else {
        setDeviceVersions(nullptr, "");
        result_ = CommandResult::Done;
    }
}

}  // namespace
