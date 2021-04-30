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
