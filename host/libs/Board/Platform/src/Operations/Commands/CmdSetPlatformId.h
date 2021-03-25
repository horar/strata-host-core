#pragma once

#include "BasePlatformCommand.h"
#include "PlatformOperationsData.h"

namespace strata::platform::command {

class CmdSetPlatformId: public BasePlatformCommand
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
