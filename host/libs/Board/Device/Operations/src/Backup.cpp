#include <Device/Operations/Backup.h>
#include <DeviceOperationsStatus.h>
#include "Commands/include/DeviceCommands.h"

#include "logging/LoggingQtCategories.h"

namespace strata::device::operation {

using command::CmdStartBackupFirmware;
using command::CmdBackupFirmware;
using command::CommandType;

Backup::Backup(const device::DevicePtr& device) :
    BaseDeviceOperation(device, Type::BackupFirmware)
{
    commandList_.reserve(2);

    // BaseDeviceOperation member device_ must be used as a parameter for commands!

    std::unique_ptr<CmdStartBackupFirmware> cmdStartBackupFirmware = std::make_unique<CmdStartBackupFirmware>(device_);
    cmdStartBackup_ = cmdStartBackupFirmware.get();

    std::unique_ptr<CmdBackupFirmware> cmdBackupFirmware = std::make_unique<CmdBackupFirmware>(device_, chunk_, 0);
    cmdBackup_ = cmdBackupFirmware.get();

    commandList_.emplace_back(std::move(cmdStartBackupFirmware));
    commandList_.emplace_back(std::move(cmdBackupFirmware));

    initCommandList();

    postCommandHandler_ = std::bind(&Backup::setTotalChunksForBackup, this, std::placeholders::_1, std::placeholders::_2);
}

void Backup::backupNextChunk()
{
    if (BaseDeviceOperation::hasStarted() == false
            || currentCommand_ == commandList_.end()
            || (*currentCommand_)->type() != CommandType::BackupFirmware)
    {
        QString errMsg(QStringLiteral("Cannot backup chunk, bad state of backup operation."));
        qCWarning(logCategoryDeviceOperations) << device_ << errMsg;
        finishOperation(Result::Error, errMsg);
        return;
    }

    BaseDeviceOperation::resume();
}

int Backup::totalChunks() const
{
    return cmdStartBackup_->totalChunks();
}

QVector<quint8> Backup::recentBackupChunk() const
{
    return chunk_;
}

void Backup::setTotalChunksForBackup(command::CommandResult& result, int& status)
{
    Q_UNUSED(result)

    if (status == operation::BACKUP_STARTED) {
        cmdBackup_->setTotalChunks(cmdStartBackup_->totalChunks());
    }
}

}  // namespace
