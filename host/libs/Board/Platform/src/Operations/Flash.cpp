#include <Device/Operations/Flash.h>
#include "Commands/include/DeviceCommands.h"

#include "logging/LoggingQtCategories.h"

namespace strata::device::operation {

using command::CmdStartFlash;
using command::CmdFlash;
using command::CommandType;

Flash::Flash(const device::DevicePtr& device, int size, int chunks, const QString &md5, bool flashFirmware) :
    BaseDeviceOperation(device, (flashFirmware) ? Type::FlashFirmware : Type::FlashBootloader),
    chunkCount_(chunks), flashFirmware_(flashFirmware)
{
    commandList_.reserve(2);

    // BaseDeviceOperation member device_ must be used as a parameter for commands!
    std::unique_ptr<CmdFlash> cmdFlash = std::make_unique<CmdFlash>(device_, chunkCount_, flashFirmware_);
    cmdFlash_ = cmdFlash.get();

    commandList_.emplace_back(std::make_unique<CmdStartFlash>(device_, size, chunkCount_, md5, flashFirmware_));
    commandList_.emplace_back(std::move(cmdFlash));

    currentCommand_ = commandList_.end();
    flashCommand_ = commandList_.begin() + 1;
}

void Flash::flashChunk(const QVector<quint8>& chunk, int chunkNumber)
{
    if (BaseDeviceOperation::hasStarted() == false || currentCommand_ == commandList_.end()) {
        QString errMsg(QStringLiteral("Cannot flash chunk, flash operation is not running."));
        qCWarning(logCategoryDeviceOperations) << device_ << errMsg;
        finishOperation(Result::Error, errMsg);
        return;
    }

    CommandType cmdType = (*currentCommand_)->type();

    // This operation has 2 commands (first is CmdStartFlash and second is CmdFlash),
    // and this method (flashChunk()) can be called only if operation has started. It means that we are
    // currently on finished CmdStartFlash (first call of flashChunk()) or on finished CmdFlash command.
    if ((cmdType == CommandType::StartFlashFirmware) || (cmdType == CommandType::StartFlashBootloader)) {
        currentCommand_ = flashCommand_;
        cmdType = (*currentCommand_)->type();
    }

    if ((cmdType == CommandType::FlashFirmware) || (cmdType == CommandType::FlashBootloader)) {
        cmdFlash_->setNewChunk(chunk, chunkNumber);
        BaseDeviceOperation::resume();
    }
}

}  // namespace
