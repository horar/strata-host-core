#include <Device/Operations/Backup.h>
#include "Commands/include/DeviceCommands.h"

#include "logging/LoggingQtCategories.h"

namespace strata::device::operation {

using command::CmdStartBackupFirmware;
using command::CmdBackupFirmware;

Backup::Backup(const device::DevicePtr& device) :
    BaseDeviceOperation(device, Type::BackupFirmware)
{
    // BaseDeviceOperation member device_ must be used as a parameter for commands!
    commandList_.emplace_back(std::make_unique<CmdStartBackupFirmware>(device_));

    currentCommand_ = commandList_.end();

    postCommandHandler_ = std::bind(&Backup::setTotalChunks, this, std::placeholders::_1, std::placeholders::_2);
}

void Backup::backupNextChunk()
{
    if (run_ == false || currentCommand_ == commandList_.end()) {
        QString errMsg(QStringLiteral("Cannot backup chunk, backup operation is not running."));
        qCWarning(logCategoryDeviceOperations) << device_ << errMsg;
        emit error(errMsg);
        return;
    }

    CmdStartBackupFirmware *cmdStartBackup = dynamic_cast<CmdStartBackupFirmware*>(currentCommand_->get());
    if (cmdStartBackup != nullptr) {
        commandList_.emplace_back(std::make_unique<CmdBackupFirmware>(device_, chunk_, totalChunks_));
        currentCommand_ = commandList_.end() - 1;
    }

    CmdBackupFirmware *cmdBackup = dynamic_cast<CmdBackupFirmware*>(currentCommand_->get());
    if (cmdBackup != nullptr) {
        BaseDeviceOperation::resume();
    }
}

int Backup::totalChunks() const
{
    return totalChunks_;
}

QVector<quint8> Backup::recentBackupChunk() const
{
    return chunk_;
}

void Backup::setTotalChunks(command::CommandResult& result, int& data)
{
    Q_UNUSED(result)

    if (data == operation::BACKUP_STARTED) {
         CmdStartBackupFirmware *cmdStartBackup = dynamic_cast<CmdStartBackupFirmware*>(currentCommand_->get());
         if (cmdStartBackup != nullptr) {
             totalChunks_ = cmdStartBackup->totalChunks();
         }
    }
}

}  // namespace
