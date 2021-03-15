#include <Device/Operations/Backup.h>
#include <DeviceOperationsStatus.h>
#include "Commands/include/DeviceCommands.h"

#include "logging/LoggingQtCategories.h"

namespace strata::device::operation {

using command::CmdStartBackupFirmware;
using command::CmdBackupFirmware;
using command::CommandType;

Backup::Backup(const device::DevicePtr& device) :
    BaseDeviceOperation(device, Type::BackupFirmware), totalChunks_(0)
{
    commandList_.reserve(2);

    // BaseDeviceOperation member device_ must be used as a parameter for commands!
    std::unique_ptr<CmdStartBackupFirmware> cmdStartBackupFirmware = std::make_unique<CmdStartBackupFirmware>(device_);
    cmdStartBackup_ = cmdStartBackupFirmware.get();

    commandList_.emplace_back(std::move(cmdStartBackupFirmware));

    currentCommand_ = commandList_.end();

    postCommandHandler_ = std::bind(&Backup::setTotalChunks, this, std::placeholders::_1, std::placeholders::_2);
}

void Backup::backupNextChunk()
{
    if (BaseDeviceOperation::hasStarted() == false || currentCommand_ == commandList_.end()) {
        QString errMsg(QStringLiteral("Cannot backup chunk, backup operation is not running."));
        qCWarning(logCategoryDeviceOperations) << device_ << errMsg;
        finishOperation(Result::Error, errMsg);
        return;
    }

    // This operation has 2 commands (first is StartBackupFirmware and second is CmdBackupFirmware),
    // and this method (backupNextChunk()) can be called only if operation has started. It means that
    // we are currently on finished CmdStartBackupFirmware (first call of backupNextChunk()) or
    // on finished CmdBackupFirmware command. If we call this method (backupNextChunk()) first time,
    // we suppose that totalChunks_ was already set by totalChunks() method (which is assigned to
    // postCommandHandler_) and therefore we can add CmdBackupFirmware command.
    if ((*currentCommand_)->type() == CommandType::StartBackupFirmware) {
        commandList_.emplace_back(std::make_unique<CmdBackupFirmware>(device_, chunk_, totalChunks_));
        currentCommand_ = commandList_.end() - 1;
    }

    // currentCommand_ may not be the same as in previous if condition
    if ((*currentCommand_)->type() == CommandType::BackupFirmware) {
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

void Backup::setTotalChunks(command::CommandResult& result, int& status)
{
    Q_UNUSED(result)

    if (status == operation::BACKUP_STARTED) {
        totalChunks_ = cmdStartBackup_->totalChunks();
    }
}

}  // namespace
