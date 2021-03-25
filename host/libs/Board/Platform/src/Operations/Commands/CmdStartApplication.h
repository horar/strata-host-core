#ifndef CMD_START_APPLICATION_H
#define CMD_START_APPLICATION_H

#include "BasePlatformCommand.h"

namespace strata::platform::command {

class CmdStartApplication : public BasePlatformCommand {
public:
    explicit CmdStartApplication(const device::DevicePtr& device);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
};

}  // namespace

#endif
