#include "CmdRequestPlatformId.h"
#include "DeviceOperationsConstants.h"

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

namespace strata {

CmdRequestPlatformId::CmdRequestPlatformId(const device::DevicePtr& device, uint maxRetries) :
    BaseDeviceCommand(device, QStringLiteral("request_platform_id")), maxRetries_(maxRetries), retriesCount_(0) { }

QByteArray CmdRequestPlatformId::message() {
    return QByteArray("{\"cmd\":\"request_platform_id\"}");
}

bool CmdRequestPlatformId::processNotification(rapidjson::Document& doc) {
    if (CommandValidator::validate(CommandValidator::JsonType::reqPlatIdRes, doc)) {
        const rapidjson::Value& payload = doc[JSON_NOTIFICATION][JSON_PAYLOAD];
        const char *name = payload[JSON_NAME].GetString();
        const char *platformId = payload[JSON_PLATFORM_ID].GetString();
        const char *classId = payload[JSON_CLASS_ID].GetString();
        setDeviceProperties(name, platformId, classId, nullptr, nullptr);
        result_ = CommandResult::Done;
        return true;
    } else {
        return false;
    }
}

void CmdRequestPlatformId::onTimeout() {
    if (retriesCount_ < maxRetries_) {
        ++retriesCount_;
        qCInfo(logCategoryDeviceOperations) << device_.get() << "Going to retry to get platform ID.";
        result_ = CommandResult::Retry;
    } else {
        result_ = CommandResult::InProgress;
    }
}

}  // namespace
