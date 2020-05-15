#ifndef CMD_REQUEST_PLATFORM_ID_H
#define CMD_REQUEST_PLATFORM_ID_H

#include "BaseDeviceCommand.h"

namespace strata {

class CmdRequestPlatformId : public BaseDeviceCommand {
public:
    CmdRequestPlatformId(const SerialDevicePtr& device);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
};

}  // namespace

#endif
