#include "CmdStartApplication.h"
#include "PlatformCommandConstants.h"

#include <cstring>

#include <PlatformOperationsStatus.h>

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

namespace strata::platform::command {

CmdStartApplication::CmdStartApplication(const PlatformPtr& platform) :
    BasePlatformCommand(platform, QStringLiteral("start_application"), CommandType::StartApplication)
{ }

QByteArray CmdStartApplication::message() {
    return QByteArray("{\"cmd\":\"start_application\",\"payload\":{}}");
}

bool CmdStartApplication::processNotification(const rapidjson::Document& doc, CommandResult& result) {
    if (CommandValidator::validateNotification(CommandValidator::JsonType::startApplicationNotif, doc)) {
        result = CommandResult::Failure;

        const char* jsonStatus = doc[JSON_NOTIFICATION][JSON_PAYLOAD][JSON_STATUS].GetString();
        if (std::strcmp(jsonStatus, JSON_OK) == 0) {
            result = CommandResult::Done;
            setDeviceApiVersion(Platform::ApiVersion::Unknown);
            setDeviceBootloaderMode(false);
        } else {
            if (std::strcmp(jsonStatus, CSTR_NO_FIRMWARE) == 0) {
                qCWarning(logCategoryPlatformCommand) << platform_ << "Nothing to start, board has no valid firmware.";
                result = CommandResult::FinaliseOperation;
                status_ = operation::NO_FIRMWARE;
            }
        }

        return true;
    } else {
        return false;
    }
}

}  // namespace
