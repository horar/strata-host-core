#ifndef CMD_UPDATE_FIRMWARE_H
#define CMD_UPDATE_FIRMWARE_H

#include "BaseDeviceCommand.h"

namespace strata::device::command {

class CmdUpdateFirmware : public BaseDeviceCommand {
public:
    explicit CmdUpdateFirmware(const device::DevicePtr& device);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
    bool skip() override;
    std::chrono::milliseconds waitBeforeNextCommand() const override;
    int dataForFinish() const override;
};

}  // namespace

#endif
