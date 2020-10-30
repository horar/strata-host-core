#pragma once

#include "BaseDeviceCommand.h"

namespace strata::device::command {

class CmdSetAssistedPlatformId: public BaseDeviceCommand
{
public:
    explicit CmdSetAssistedPlatformId(
            const device::DevicePtr &device,
            const QString &classId,
            const QString &platformId,
            int boardCount,
            const QString &controllerClassId,
            const QString &controllerPlatformId,
            int controllerBoardCount,
            const QString fwClassId);

    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
    int dataForFinish() const override;

private:
    QString classId_;
    QString platformId_;
    int boardCount_;
    QString controllerClassId_;
    QString controllerPlatformId_;
    int controllerBoardCount_;
    QString fwClassId_;
    int dataForFinished_;
};

}
