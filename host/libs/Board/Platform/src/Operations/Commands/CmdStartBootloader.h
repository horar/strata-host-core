#ifndef CMD_START_BOOTLOADER_H
#define CMD_START_BOOTLOADER_H

#include "BasePlatformCommand.h"

namespace strata::device::command {

class CmdStartBootloader : public BaseDeviceCommand {
public:
    explicit CmdStartBootloader(const device::DevicePtr& device);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
};

}  // namespace

#endif
