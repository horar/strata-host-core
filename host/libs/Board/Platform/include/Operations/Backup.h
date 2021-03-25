#pragma once

#include <QVector>

#include <Operations/BasePlatformOperation.h>

namespace strata::platform::command {
    class CmdStartBackupFirmware;
}

namespace strata::platform::operation {

class Backup : public BasePlatformOperation {

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
