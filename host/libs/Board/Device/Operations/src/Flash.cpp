#include <Device/Operations/Flash.h>
#include "Commands/include/DeviceCommands.h"

#include "logging/LoggingQtCategories.h"

namespace strata::device::operation {

using command::CmdStartFlash;
using command::CmdFlash;

Flash::Flash(const device::DevicePtr& device, int size, int chunks, const QString &md5, bool flashFirmware) :
    BaseDeviceOperation(device, (flashFirmware) ? Type::FlashFirmware : Type::FlashBootloader),
    chunkCount_(chunks), flashFirmware_(flashFirmware)
{
    // BaseDeviceOperation member device_ must be used as a parameter for commands!
    commandList_.emplace_back(std::make_unique<CmdStartFlash>(device_, size, chunkCount_, md5, flashFirmware_));

    currentCommand_ = commandList_.end();
}

void Flash::flashChunk(const QVector<quint8>& chunk, int chunkNumber)
{
    if (run_ == false || currentCommand_ == commandList_.end()) {
        QString errMsg(QStringLiteral("Cannot flash chunk, flash operation is not running."));
        qCWarning(logCategoryDeviceOperations) << device_ << errMsg;
        emit error(errMsg);
        return;
    }

    CmdStartFlash *cmdStartFlash = dynamic_cast<CmdStartFlash*>(currentCommand_->get());
    if (cmdStartFlash != nullptr) {
        commandList_.emplace_back(std::make_unique<CmdFlash>(device_, chunkCount_, flashFirmware_));
        currentCommand_ = commandList_.end() - 1;
    }

    CmdFlash *cmdFlash = dynamic_cast<CmdFlash*>(currentCommand_->get());
    if (cmdFlash != nullptr) {
        chunk_ = chunk;
        cmdFlash->setNewChunk(chunk_, chunkNumber);
        BaseDeviceOperation::resume();
    }
}

}  // namespace
