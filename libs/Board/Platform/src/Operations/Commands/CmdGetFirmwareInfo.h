#ifndef CMD_GET_FIRMWARE_INFO_H
#define CMD_GET_FIRMWARE_INFO_H

#include "BasePlatformCommand.h"

namespace strata::platform::command {

class CmdGetFirmwareInfo : public BasePlatformCommand {
public:
    explicit CmdGetFirmwareInfo(const PlatformPtr& platform, bool requireResponse = true, uint maxRetries = 0);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc, CommandResult& result) override;
    CommandResult onTimeout() override;
    CommandResult onReject() override;
private:
    const bool requireResponse_;
    const uint maxRetries_;
    uint retriesCount_;
};

}  // namespace

#endif
