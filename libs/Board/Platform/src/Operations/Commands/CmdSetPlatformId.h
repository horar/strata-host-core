/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
