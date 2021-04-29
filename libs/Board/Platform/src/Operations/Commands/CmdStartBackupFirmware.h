#ifndef CMD_START_BACKUP_FIRMWARE_H
#define CMD_START_BACKUP_FIRMWARE_H

#include "BasePlatformCommand.h"

namespace strata::platform::command {

class CmdStartBackupFirmware : public BasePlatformCommand {
public:
    explicit CmdStartBackupFirmware(const PlatformPtr& platform);
    QByteArray message() override;
    bool processNotification(const rapidjson::Document& doc, CommandResult& result) override;
    int totalChunks() const;
private:
    uint chunks_;
    /* these values ​​are not used yet
    uint size_;
    QString md5_;
    */
};

}  // namespace

#endif
