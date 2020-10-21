#pragma once

#include <QString>
#include <QVector>

#include <Device/Operations/BaseDeviceOperation.h>

namespace strata::device::operation {

class Flash : public BaseDeviceOperation {

public:
    Flash(const device::DevicePtr& device, int size, int chunks, const QString &md5, bool flashFirmware);
    ~Flash() = default;
    void flashChunk(const QVector<quint8>& chunk, int chunkNumber);
private:
    QVector<quint8> chunk_;
    int chunkCount_;
    bool flashFirmware_;
};

}  // namespace
