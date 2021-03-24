#pragma once

#include <QVector>

#include <Operations/BasePlatformOperation.h>

namespace strata::device::command {
    class CmdStartBackupFirmware;
}

namespace strata::device::operation {

class Backup : public BaseDeviceOperation {

public:
    explicit Backup(const device::DevicePtr& device);
    ~Backup() = default;
    int totalChunks() const;
    void backupNextChunk();
    QVector<quint8> recentBackupChunk() const;
private:
    command::CmdStartBackupFirmware* cmdStartBackup_;
    void setTotalChunks(command::CommandResult& result, int& status);
    int totalChunks_;
    QVector<quint8> chunk_;
};

}  // namespace
