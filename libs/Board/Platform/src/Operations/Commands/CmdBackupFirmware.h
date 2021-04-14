#ifndef CMD_BACKUP_FIRMWARE_H
#define CMD_BACKUP_FIRMWARE_H

#include "BasePlatformCommand.h"

#include <QVector>

namespace strata::platform::command {

class CmdBackupFirmware : public BasePlatformCommand {
public:
    CmdBackupFirmware(const PlatformPtr& platform, QVector<quint8>& chunk, int totalChunks);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc, CommandResult& result) override;
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
