#pragma once

#include "BasePlatformCommand.h"
#include "PlatformOperationsData.h"

namespace strata::platform::command {

class CmdSetPlatformId: public BasePlatformCommand
{
public:
    CmdSetPlatformId(const PlatformPtr& platform, const CmdSetPlatformIdData& data);

    QByteArray message() override;
    bool processNotification(const rapidjson::Document& doc, CommandResult& result) override;

private:
    CmdSetPlatformIdData data_;
};

}  // namespace
