#pragma once

#include <QVector>

#include <Operations/BasePlatformOperation.h>

namespace strata::platform::command {
    class CmdStartBackupFirmware;
    class CmdBackupFirmware;
}

namespace strata::platform::operation {

class Backup : public BasePlatformOperation {

public:
    explicit Backup(const PlatformPtr& platform);
    ~Backup() = default;
    int totalChunks() const;
    uint backupSize() const;
    void backupNextChunk();
    QVector<quint8> recentBackupChunk() const;
private:
    command::CmdStartBackupFirmware* cmdStartBackup_;
    command::CmdBackupFirmware* cmdBackup_;
    void setTotalChunksForBackup(command::CommandResult& result, int& status);
    QVector<quint8> chunk_;
};

}  // namespace
