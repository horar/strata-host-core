#ifndef CMD_REQUEST_PLATFORM_ID_H
#define CMD_REQUEST_PLATFORM_ID_H

#include "BaseDeviceCommand.h"

namespace strata {

class CmdRequestPlatformId : public BaseDeviceCommand {
public:
    CmdRequestPlatformId(const device::DevicePtr& device, uint maxRetries = 0);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
    void onTimeout() override;
private:
    const uint maxRetries_;
    uint retriesCount_;
};

}  // namespace

#endif
