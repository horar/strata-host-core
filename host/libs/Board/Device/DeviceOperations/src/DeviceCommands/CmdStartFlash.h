#ifndef CMD_START_FLASH_H
#define CMD_START_FLASH_H

#include "BaseDeviceCommand.h"

namespace strata::device::command {

class CmdStartFlash : public BaseDeviceCommand {
public:
    CmdStartFlash(const device::DevicePtr& device, uint size, uint chunks, const QString& md5, bool flashFirmware);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
private:
    const uint size_;
    const uint chunks_;
    const QByteArray md5_;
    const bool flashFirmware_;  // true = flash firmware, false = flash bootloader
};

}  // namespace

#endif
