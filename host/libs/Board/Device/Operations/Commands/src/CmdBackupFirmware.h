#ifndef CMD_BACKUP_FIRMWARE_H
#define CMD_BACKUP_FIRMWARE_H

#include "BaseDeviceCommand.h"

#include <QVector>

namespace strata::device::command {

class CmdBackupFirmware : public BaseDeviceCommand {
public:
    CmdBackupFirmware(const device::DevicePtr& device, QVector<quint8>& chunk, int totalChunks);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
    bool logSendMessage() const override;
private:
    QVector<quint8>& chunk_;
    const int totalChunks_;
    int chunkNumber_;
    bool firstBackupChunk_;
    const uint maxRetries_;
    uint retriesCount_;
};

}  // namespace

#endif
