/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
