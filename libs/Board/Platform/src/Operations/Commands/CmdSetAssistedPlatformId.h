#pragma once

#include "BasePlatformCommand.h"
#include "PlatformOperationsData.h"

#include <optional>

namespace strata::platform::command {

class CmdSetAssistedPlatformId: public BasePlatformCommand
{
public:
    explicit CmdSetAssistedPlatformId(const PlatformPtr& platform);

    void setBaseData(const CmdSetPlatformIdData& data);
    void setControllerData(const CmdSetPlatformIdData& controllerData);
    void setFwClassId(const QString &fwClassId);

    QByteArray message() override;
    bool processNotification(const rapidjson::Document& doc, CommandResult& result) override;

private:
    std::optional<CmdSetPlatformIdData> data_;
    std::optional<CmdSetPlatformIdData> controllerData_;
    std::optional<QString> fwClassId_;
};

}  // namespace
