/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#ifndef CMD_GET_FIRMWARE_INFO_H
#define CMD_GET_FIRMWARE_INFO_H

#include "BasePlatformCommand.h"

namespace strata::platform::command {

class CmdGetFirmwareInfo : public BasePlatformCommand {
public:
    explicit CmdGetFirmwareInfo(const PlatformPtr& platform, bool requireResponse = true, uint maxRetries = 0);
    QByteArray message() override;
    bool processNotification(const rapidjson::Document& doc, CommandResult& result) override;
    CommandResult onTimeout() override;
    CommandResult onReject() override;
private:
    const bool requireResponse_;
    const uint maxRetries_;
    uint retriesCount_;
};

}  // namespace

#endif
