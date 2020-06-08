#ifndef CMD_BACKUP_FIRMWARE_H
#define CMD_BACKUP_FIRMWARE_H

#include "BaseDeviceCommand.h"

#include <QVector>

namespace strata::device::command {

class CmdBackupFirmware : public BaseDeviceCommand {
public:
    CmdBackupFirmware(const device::DevicePtr& device, QVector<quint8>& chunk);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
    bool logSendMessage() const override;
    void prepareRepeat() override;
    int dataForFinish() const override;
    QVector<quint8> chunk() const;
private:
    QVector<quint8>& chunk_;
    int chunkNumber_;
    bool firstBackupChunk_;
    const uint maxRetries_;
    uint retriesCount_;
};

}  // namespace

#endif
