/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#ifndef CMD_START_FLASH_H
#define CMD_START_FLASH_H

#include "BasePlatformCommand.h"

namespace strata::platform::command {

class CmdStartFlash : public BasePlatformCommand {
public:
    CmdStartFlash(const PlatformPtr& platform, int size, int chunks, const QString& md5, bool flashFirmware);
    QByteArray message() override;
    bool processNotification(const rapidjson::Document& doc, CommandResult& result) override;
private:
    const int size_;
    const int chunks_;
    const QByteArray md5_;
    const bool flashFirmware_;  // true = flash firmware, false = flash bootloader
};

}  // namespace

#endif
