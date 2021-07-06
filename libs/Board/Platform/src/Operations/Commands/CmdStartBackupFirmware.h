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
    uint backupSize() const;
private:
    uint chunks_;
    uint size_;
    /* this value is not used yet
    QString md5_;
    */
};

}  // namespace

#endif
