#ifndef CMD_FLASH_H
#define CMD_FLASH_H

#include "BaseDeviceCommand.h"

#include <QVector>

namespace strata::device::command {

class CmdFlash : public BaseDeviceCommand {
public:
    CmdFlash(const device::DevicePtr& device, qint64 fileSize, const QString& fileMD5, bool flashFirmware);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
    bool logSendMessage() const override;
    void prepareRepeat() override;
    int dataForFinish() const override;
    void setChunk(const QVector<quint8>& chunk, int chunkNumber, int chunkCount);
private:
    const bool flashFirmware_;  // true = flash firmware, false = flash bootloader
    QVector<quint8> chunk_;
    int chunkNumber_;
    int chunkCount_;
    const quint64 fileSize_;
    const QString fileMD5_;
    const uint maxRetries_;
    uint retriesCount_;
};

}  // namespace

#endif
