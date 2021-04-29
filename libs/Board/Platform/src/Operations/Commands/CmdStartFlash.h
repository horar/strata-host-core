#ifndef CMD_START_FLASH_H
#define CMD_START_FLASH_H

#include "BasePlatformCommand.h"

namespace strata::platform::command {

class CmdStartFlash : public BasePlatformCommand {
public:
    CmdStartFlash(const PlatformPtr& platform, int size, int chunks, const QString& md5, bool flashFirmware);
    QByteArray message() override;
    bool processNotification(const rapidjson::Document& doc, CommandResult& result) override;
private:
    const int size_;
    const int chunks_;
    const QByteArray md5_;
    const bool flashFirmware_;  // true = flash firmware, false = flash bootloader
};

}  // namespace

#endif
