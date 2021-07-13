#ifndef CMD_REQUEST_PLATFORM_ID_H
#define CMD_REQUEST_PLATFORM_ID_H

#include "BasePlatformCommand.h"

namespace strata::platform::command {

class CmdRequestPlatformId : public BasePlatformCommand {
public:
    explicit CmdRequestPlatformId(const PlatformPtr& platform);
    QByteArray message() override;
    bool processNotification(const rapidjson::Document& doc, CommandResult& result) override;
};

}  // namespace

#endif
