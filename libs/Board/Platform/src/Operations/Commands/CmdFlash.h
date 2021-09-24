/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#ifndef CMD_FLASH_H
#define CMD_FLASH_H

#include "BasePlatformCommand.h"

#include <QVector>

namespace strata::platform::command {

class CmdFlash : public BasePlatformCommand {
public:
    CmdFlash(const PlatformPtr& platform, int chunkCount, bool flashFirmware);
    QByteArray message() override;
    bool processNotification(const rapidjson::Document& doc, CommandResult& result) override;
    bool logSendMessage() const override;
    void setNewChunk(const QVector<quint8>& chunk, int chunkNumber);
private:
    const bool flashFirmware_;  // true = flash firmware, false = flash bootloader
    QVector<quint8> chunk_;
    int chunkNumber_;
    int chunkCount_;
    const uint maxRetries_;
    uint retriesCount_;
};

}  // namespace

#endif
