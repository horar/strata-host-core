#ifndef CMD_GET_FIRMWARE_INFO_H
#define CMD_GET_FIRMWARE_INFO_H

#include "BaseDeviceCommand.h"

namespace strata::device::command {

class CmdGetFirmwareInfo : public BaseDeviceCommand {
public:
    CmdGetFirmwareInfo(const device::DevicePtr& device, bool requireResponse);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
    void onTimeout() override;
private:
    bool requireResponse_;
};

}  // namespace

#endif
