#ifndef CMD_START_BOOTLOADER_H
#define CMD_START_BOOTLOADER_H

#include "BasePlatformCommand.h"

namespace strata::platform::command {

class CmdStartBootloader : public BasePlatformCommand {
public:
    explicit CmdStartBootloader(const PlatformPtr& platform);
    QByteArray message() override;
    bool processNotification(const rapidjson::Document& doc, CommandResult& result) override;
};

}  // namespace

#endif
