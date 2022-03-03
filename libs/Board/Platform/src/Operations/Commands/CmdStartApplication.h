/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#ifndef CMD_START_APPLICATION_H
#define CMD_START_APPLICATION_H

#include "BasePlatformCommand.h"

namespace strata::platform::command {

class CmdStartApplication : public BasePlatformCommand {
public:
    explicit CmdStartApplication(const PlatformPtr& platform);
    QByteArray message() override;
    bool processNotification(const rapidjson::Document& doc, CommandResult& result) override;
};

}  // namespace

#endif
