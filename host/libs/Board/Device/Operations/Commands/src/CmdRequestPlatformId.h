#ifndef CMD_REQUEST_PLATFORM_ID_H
#define CMD_REQUEST_PLATFORM_ID_H

#include "BaseDeviceCommand.h"

namespace strata::device::command {

class CmdRequestPlatformId : public BaseDeviceCommand {
public:
    explicit CmdRequestPlatformId(const device::DevicePtr& device);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc, CommandResult& result) override;
};

}  // namespace

#endif
