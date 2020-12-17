#ifndef CMD_START_BACKUP_FIRMWARE_H
#define CMD_START_BACKUP_FIRMWARE_H

#include "BaseDeviceCommand.h"

namespace strata::device::command {

class CmdStartBackupFirmware : public BaseDeviceCommand {
public:
    explicit CmdStartBackupFirmware(const device::DevicePtr& device);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
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
