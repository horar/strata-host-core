#pragma once

#include "BaseDeviceCommand.h"
#include "DeviceOperationsData.h"

namespace strata::device::command {

class CmdSetAssistedPlatformId: public BaseDeviceCommand
{
public:
    explicit CmdSetAssistedPlatformId(
            const device::DevicePtr &device,
            const CmdSetAssistedPlatformIdData &data);

    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
    int dataForFinish() const override;

private:
    CmdSetAssistedPlatformIdData data_;
    int dataForFinished_;
};

}  // namespace
