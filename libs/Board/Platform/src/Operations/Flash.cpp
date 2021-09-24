/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <Operations/Flash.h>
#include "Commands/PlatformCommands.h"

#include "logging/LoggingQtCategories.h"

namespace strata::platform::operation {

using command::CmdStartFlash;
using command::CmdFlash;
using command::CommandType;

Flash::Flash(const PlatformPtr& platform, int size, int chunks, const QString &md5, bool flashFirmware) :
    BasePlatformOperation(platform, (flashFirmware) ? Type::FlashFirmware : Type::FlashBootloader),
    chunkCount_(chunks), flashFirmware_(flashFirmware)
{
    commandList_.reserve(2);

    // BasePlatformOperation member platform_ must be used as a parameter for commands!
    std::unique_ptr<CmdFlash> cmdFlash = std::make_unique<CmdFlash>(platform_, chunkCount_, flashFirmware_);
    cmdFlash_ = cmdFlash.get();

    commandList_.emplace_back(std::make_unique<CmdStartFlash>(platform_, size, chunkCount_, md5, flashFirmware_));
    commandList_.emplace_back(std::move(cmdFlash));

    initCommandList();

    flashCommand_ = commandList_.begin() + 1;
}

void Flash::flashChunk(const QVector<quint8>& chunk, int chunkNumber)
{
    if (BasePlatformOperation::hasStarted() == false
            || currentCommand_ == commandList_.end()
            || ( ((*currentCommand_)->type() != CommandType::FlashFirmware) && ((*currentCommand_)->type() != CommandType::FlashBootloader) ))
    {
        QString errMsg(QStringLiteral("Cannot flash chunk, bad state of flash operation."));
        qCWarning(logCategoryPlatformOperation) << platform_ << errMsg;
        finishOperation(Result::Error, errMsg);
        return;
    }

    cmdFlash_->setNewChunk(chunk, chunkNumber);
    BasePlatformOperation::resume();
}

}  // namespace
