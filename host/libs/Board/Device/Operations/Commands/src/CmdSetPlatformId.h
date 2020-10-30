#pragma once

#include "BaseDeviceCommand.h"

namespace strata::device::command {

class CmdSetPlatformId: public BaseDeviceCommand
{
public:
    explicit CmdSetPlatformId(
            const device::DevicePtr &device,
            const QString &classId,
            const QString &platformId,
            int boardCount);

    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
    int dataForFinish() const override;

private:
    QString classId_;
    QString platformId_;
    int boardCount_;
    int dataForFinished_;
};

}
