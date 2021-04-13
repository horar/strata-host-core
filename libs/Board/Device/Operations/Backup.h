#pragma once

#include <QVector>

#include <Device/Operations/BaseDeviceOperation.h>

namespace strata::device::command {
    class CmdStartBackupFirmware;
    class CmdBackupFirmware;
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
    command::CmdBackupFirmware* cmdBackup_;
    void setTotalChunksForBackup(command::CommandResult& result, int& status);
    QVector<quint8> chunk_;
};

}  // namespace
