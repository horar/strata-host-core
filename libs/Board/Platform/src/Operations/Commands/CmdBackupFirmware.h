/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#ifndef CMD_BACKUP_FIRMWARE_H
#define CMD_BACKUP_FIRMWARE_H

#include "BasePlatformCommand.h"

#include <QVector>

namespace strata::platform::command {

class CmdBackupFirmware : public BasePlatformCommand {
public:
    CmdBackupFirmware(const PlatformPtr& platform, QVector<quint8>& chunk, int totalChunks);
    QByteArray message() override;
    bool processNotification(const rapidjson::Document& doc, CommandResult& result) override;
    bool logSendMessage() const override;
    void setTotalChunks(int totalChunks);
private:
    QVector<quint8>& chunk_;
    int totalChunks_;
    int chunkNumber_;
    bool firstBackupChunk_;
    const uint maxRetries_;
    uint retriesCount_;
};

}  // namespace

#endif
