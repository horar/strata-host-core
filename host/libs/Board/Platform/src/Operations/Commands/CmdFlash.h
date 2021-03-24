#ifndef CMD_FLASH_H
#define CMD_FLASH_H

#include "BasePlatformCommand.h"

#include <QVector>

namespace strata::device::command {

class CmdFlash : public BaseDeviceCommand {
public:
    CmdFlash(const device::DevicePtr& device, int chunkCount, bool flashFirmware);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
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
