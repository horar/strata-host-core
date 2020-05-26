#ifndef CMD_FLASH_FIRMWARE_H
#define CMD_FLASH_FIRMWARE_H

#include "BaseDeviceCommand.h"

#include <QVector>

namespace strata {

class CmdFlashFirmware : public BaseDeviceCommand {
public:
    CmdFlashFirmware(const device::DevicePtr& device);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
    bool logSendMessage() const override;
    void prepareRepeat() override;
    int dataForFinish() const override;
    void setChunk(const QVector<quint8>& chunk, int chunkNumber);
private:
    QVector<quint8> chunk_;
    int chunkNumber_;
    const uint maxRetries_;
    uint retriesCount_;
};

}  // namespace

#endif
