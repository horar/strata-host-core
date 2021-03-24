#ifndef CMD_START_APPLICATION_H
#define CMD_START_APPLICATION_H

#include "BaseDeviceCommand.h"

namespace strata::device::command {

class CmdStartApplication : public BaseDeviceCommand {
public:
    explicit CmdStartApplication(const device::DevicePtr& device);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
};

}  // namespace

#endif
