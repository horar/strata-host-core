#pragma once

#include <QString>
#include <QVector>

#include <Device/Operations/BaseDeviceOperation.h>

namespace strata::device::command {
    class CmdFlash;
}

namespace strata::device::operation {

class Flash : public BaseDeviceOperation {

public:
    Flash(const device::DevicePtr& device, int size, int chunks, const QString &md5, bool flashFirmware);
    ~Flash() = default;
    void flashChunk(const QVector<quint8>& chunk, int chunkNumber);
private:
    std::vector<std::unique_ptr<command::BaseDeviceCommand>>::iterator flashCommand_;
    command::CmdFlash* cmdFlash_;
    int chunkCount_;
    bool flashFirmware_;
};

}  // namespace
