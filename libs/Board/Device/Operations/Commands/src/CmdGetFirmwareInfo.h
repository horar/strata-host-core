#ifndef CMD_GET_FIRMWARE_INFO_H
#define CMD_GET_FIRMWARE_INFO_H

#include "BaseDeviceCommand.h"

namespace strata::device::command {

class CmdGetFirmwareInfo : public BaseDeviceCommand {
public:
    explicit CmdGetFirmwareInfo(const device::DevicePtr& device, bool requireResponse = true, uint maxRetries = 0);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc, CommandResult& result) override;
    CommandResult onTimeout() override;
    CommandResult onReject() override;
private:
    const bool requireResponse_;
    const uint maxRetries_;
    uint retriesCount_;
};

}  // namespace

#endif
