#ifndef CMD_START_FLASH_H
#define CMD_START_FLASH_H

#include "BasePlatformCommand.h"

namespace strata::device::command {

class CmdStartFlash : public BaseDeviceCommand {
public:
    CmdStartFlash(const device::DevicePtr& device, int size, int chunks, const QString& md5, bool flashFirmware);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
private:
    const int size_;
    const int chunks_;
    const QByteArray md5_;
    const bool flashFirmware_;  // true = flash firmware, false = flash bootloader
};

}  // namespace

#endif
