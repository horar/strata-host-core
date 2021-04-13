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

    initCommandList();

    flashCommand_ = commandList_.begin() + 1;
}

void Flash::flashChunk(const QVector<quint8>& chunk, int chunkNumber)
{
    if (BaseDeviceOperation::hasStarted() == false
            || currentCommand_ == commandList_.end()
            || ( ((*currentCommand_)->type() != CommandType::FlashFirmware) && ((*currentCommand_)->type() != CommandType::FlashBootloader) ))
    {
        QString errMsg(QStringLiteral("Cannot flash chunk, bad state of flash operation."));
        qCWarning(logCategoryDeviceOperation) << device_ << errMsg;
        finishOperation(Result::Error, errMsg);
        return;
    }

    cmdFlash_->setNewChunk(chunk, chunkNumber);
    BaseDeviceOperation::resume();
}

}  // namespace
