#ifndef CMD_START_BOOTLOADER_H
#define CMD_START_BOOTLOADER_H

#include "BaseDeviceCommand.h"

namespace strata::device::command {

class CmdStartBootloader : public BaseDeviceCommand {
public:
    explicit CmdStartBootloader(const device::DevicePtr& device);

    void setWaitTime(const std::chrono::milliseconds &waitTime);

    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
    std::chrono::milliseconds waitBeforeNextCommand() const override;

private:
    std::chrono::milliseconds waitTime_ = std::chrono::milliseconds(5500);
};

}  // namespace

#endif
