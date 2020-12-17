#pragma once

#include <QVector>

#include <Device/Operations/BaseDeviceOperation.h>

namespace strata::device::operation {

class Backup : public BaseDeviceOperation {

public:
    explicit Backup(const device::DevicePtr& device);
    ~Backup() = default;
    int totalChunks() const;
    void backupNextChunk();
    QVector<quint8> recentBackupChunk() const;
private:
    void setTotalChunks(command::CommandResult& result, int& status);
    int totalChunks_;
    QVector<quint8> chunk_;
};

}  // namespace
