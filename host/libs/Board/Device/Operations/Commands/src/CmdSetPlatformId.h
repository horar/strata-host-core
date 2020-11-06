#pragma once

#include "BaseDeviceCommand.h"
#include "DeviceOperationsData.h"

namespace strata::device::command {

class CmdSetPlatformId: public BaseDeviceCommand
{
public:
    CmdSetPlatformId(
            const device::DevicePtr &device,
            const CmdSetPlatformIdData &data);

    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;

private:
    CmdSetPlatformIdData data_;
};

}  // namespace
