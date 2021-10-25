/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <Operations/Backup.h>
#include <PlatformOperationsStatus.h>
#include "Commands/PlatformCommands.h"

#include "logging/LoggingQtCategories.h"

namespace strata::platform::operation {

using command::CmdStartBackupFirmware;
using command::CmdBackupFirmware;
using command::CommandType;

Backup::Backup(const PlatformPtr& platform) :
    BasePlatformOperation(platform, Type::BackupFirmware)
{
    commandList_.reserve(2);

    // BasePlatformOperation member platform_ must be used as a parameter for commands!

    std::unique_ptr<CmdStartBackupFirmware> cmdStartBackupFirmware = std::make_unique<CmdStartBackupFirmware>(platform_);
    cmdStartBackup_ = cmdStartBackupFirmware.get();

    std::unique_ptr<CmdBackupFirmware> cmdBackupFirmware = std::make_unique<CmdBackupFirmware>(platform_, chunk_, 0);
    cmdBackup_ = cmdBackupFirmware.get();

    commandList_.emplace_back(std::move(cmdStartBackupFirmware));
    commandList_.emplace_back(std::move(cmdBackupFirmware));

    initCommandList();

    postCommandHandler_ = std::bind(&Backup::setTotalChunksForBackup, this, std::placeholders::_1, std::placeholders::_2);
}

void Backup::backupNextChunk()
{
    if (BasePlatformOperation::hasStarted() == false
            || currentCommand_ == commandList_.end()
            || (*currentCommand_)->type() != CommandType::BackupFirmware)
    {
        QString errMsg(QStringLiteral("Cannot backup chunk, bad state of backup operation."));
        qCWarning(lcPlatformOperation) << platform_ << errMsg;
        finishOperation(Result::Error, errMsg);
        return;
    }

    BasePlatformOperation::resume();
}

int Backup::totalChunks() const
{
    return cmdStartBackup_->totalChunks();
}

uint Backup::backupSize() const
{
    return cmdStartBackup_->backupSize();
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
