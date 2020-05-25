#include "DeviceOperations.h"
#include "DeviceOperationsConstants.h"
#include "DeviceCommands/DeviceCommands.h"

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

#include <rapidjson/document.h>

namespace strata {

QDebug operator<<(QDebug dbg, const DeviceOperations* devOp) {
    return dbg.nospace().noquote() << "Device 0x" << hex << devOp->deviceId_ << ": ";
}

DeviceOperations::DeviceOperations(const device::DevicePtr& device) :
    device_(device), responseTimer_(this), operation_(DeviceOperation::None)
{
    deviceId_ = static_cast<uint>(device_->deviceId());

    responseTimer_.setSingleShot(true);
    responseTimer_.setInterval(RESPONSE_TIMEOUT);

    currentCommand_ = commandList_.end();

    connect(this, &DeviceOperations::sendCommand, this, &DeviceOperations::handleSendCommand, Qt::QueuedConnection);
    connect(device_.get(), &device::Device::msgFromDevice, this, &DeviceOperations::handleDeviceResponse);
    connect(device_.get(), &device::Device::deviceError, this, &DeviceOperations::handleDeviceError);
    connect(&responseTimer_, &QTimer::timeout, this, &DeviceOperations::handleResponseTimeout);

    qCDebug(logCategoryDeviceOperations) << this << "Created object for device operations.";
}

DeviceOperations::~DeviceOperations() {
    device_->unlockDevice(reinterpret_cast<quintptr>(this));
    qCDebug(logCategoryDeviceOperations) << this << "Finished operations.";
}

void DeviceOperations::identify(bool requireFwInfoResponse) {
    if (startOperation(DeviceOperation::Identify)) {
        commandList_.emplace_back(std::make_unique<CmdGetFirmwareInfo>(device_, requireFwInfoResponse));
        commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(device_));
        currentCommand_ = commandList_.begin();
        // Some boards need time for booting
        QTimer::singleShot(IDENTIFY_LAUNCH_DELAY, this, [this](){ emit sendCommand(QPrivateSignal()); });
    }
}

void DeviceOperations::switchToBootloader() {
    if (startOperation(DeviceOperation::SwitchToBootloader)) {
        // If board is already in bootloader mode, CmdUpdateFirmware is skipped
        // and whole operation ends. Finished() signal will be sent with data set to 1 then.
        commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(device_));
        commandList_.emplace_back(std::make_unique<CmdUpdateFirmware>(device_));
        commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(device_));
        currentCommand_ = commandList_.begin();
        emit sendCommand(QPrivateSignal());
    }
}

void DeviceOperations::flashFirmwareChunk(const QVector<quint8>& chunk, int chunkNumber) {
    if (startOperation(DeviceOperation::FlashFirmwareChunk)) {
        if (commandList_.empty()) {
            commandList_.emplace_back(std::make_unique<CmdFlashFirmware>(device_));
            currentCommand_ = commandList_.begin();
        }
        if (currentCommand_ != commandList_.end()) {
            CmdFlashFirmware *cmdFlash = dynamic_cast<CmdFlashFirmware*>(currentCommand_->get());
            if (cmdFlash != nullptr) {
                cmdFlash->setChunk(chunk, chunkNumber);
                emit sendCommand(QPrivateSignal());
            }
        }
    }
}

void DeviceOperations::backupFirmwareChunk() {
    if (startOperation(DeviceOperation::BackupFirmwareChunk)) {
        if (commandList_.empty()) {
            commandList_.emplace_back(std::make_unique<CmdBackupFirmware>(device_, backupChunk_));
            currentCommand_ = commandList_.begin();
        }
        if (currentCommand_ != commandList_.end()) {
            emit sendCommand(QPrivateSignal());
        }
    }
}

void DeviceOperations::startApplication() {
    if (startOperation(DeviceOperation::StartApplication)) {
        commandList_.emplace_back(std::make_unique<CmdStartApplication>(device_));
        currentCommand_ = commandList_.begin();
        emit sendCommand(QPrivateSignal());
    }
}

void DeviceOperations::refreshPlatformId() {
    if (startOperation(DeviceOperation::RefreshPlatformId)) {
        commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(device_, MAX_PLATFORM_ID_RETRIES));
        currentCommand_ = commandList_.begin();
        emit sendCommand(QPrivateSignal());
    }
}

void DeviceOperations::cancelOperation() {
    responseTimer_.stop();
    finishOperation(DeviceOperation::Cancel);
}

int DeviceOperations::deviceId() const {
    return static_cast<int>(deviceId_);
}

QVector<quint8> DeviceOperations::recentBackupChunk() const {
    return backupChunk_;
}

void DeviceOperations::handleSendCommand() {
    if (currentCommand_ == commandList_.end()) {
        return;
    }
    BaseDeviceCommand *command = currentCommand_->get();
    if (command->skip()) {
        qCDebug(logCategoryDeviceOperations) << this << "Skipping '" << command->name() << "' command.";
        QTimer::singleShot(0, this, [this](){ nextCommand(); });
    } else {
        QString logMsg(QStringLiteral("Sending '") + command->name() + QStringLiteral("' command."));
        if (command->logSendMessage()) {
            qCInfo(logCategoryDeviceOperations) << this << logMsg;
        } else {
            qCDebug(logCategoryDeviceOperations) << this << logMsg;
        }

        if (device_->sendMessage(command->message(), reinterpret_cast<quintptr>(this))) {
            responseTimer_.start();
        } else {
            QString errMsg(QStringLiteral("Cannot send '") + command->name() + QStringLiteral("' command."));
            qCCritical(logCategoryDeviceOperations) << this << errMsg;
            reset();
            emit error(errMsg);
        }
    }
}

void DeviceOperations::handleDeviceResponse(const QByteArray& data) {
    if (currentCommand_ == commandList_.end()) {
        qCDebug(logCategoryDeviceOperations) << this << "No command is being processed, message from device is ignored.";
        return;
    }

    rapidjson::Document doc;

    if (CommandValidator::parseJson(data.toStdString(), doc) == false) {
        qCWarning(logCategoryDeviceOperations).noquote() << this << "Cannot parse JSON: '" << data << "'.";
        return;
    }

    if (doc.IsObject() == false) {
        // JSON can contain only a value (e.g. "abc").
        // We require object as a JSON content (JSON starts with '{' and ends with '}')
        qCWarning(logCategoryDeviceOperations).noquote() << this << "Content of JSON response is not an object: '" << data << "'.";
        return;
    }

    bool ok = false;

    if (doc.HasMember(JSON_ACK)) {
        if (CommandValidator::validate(CommandValidator::JsonType::ack, doc)) {
            const QString ackStr = doc[JSON_ACK].GetString();
            qCDebug(logCategoryDeviceOperations) << this << "Received '" << ackStr << "' ACK.";
            BaseDeviceCommand *command = currentCommand_->get();
            if (ackStr == command->name()) {
                command->setAckReceived();
            } else {
                qCWarning(logCategoryDeviceOperations) << this << "Received wrong ACK. Expected '" << command->name() << "', got '" << ackStr << "'.";
            }
            ok = true;
        }
    } else {
        if (doc.HasMember(JSON_NOTIFICATION)) {
            BaseDeviceCommand *command = currentCommand_->get();
            if (command->processNotification(doc)) {
                responseTimer_.stop();
                ok = true;
                if (command->ackReceived() == false) {
                    qCWarning(logCategoryDeviceOperations) << this << "Received notification without previous ACK.";
                }
                qCDebug(logCategoryDeviceOperations) << this << "Processed '" << command->name() << "' notification.";

                if (command->result() == CommandResult::Failure) {
                    qCWarning(logCategoryDeviceOperations) << this << "Received faulty notification: '" << data << "'.";
                }

                QTimer::singleShot(command->waitBeforeNextCommand(), this, [this](){ nextCommand(); });
            }
        }
    }

    if (ok == false) {
        qCWarning(logCategoryDeviceOperations).noquote() << this << "Received wrong or malformed response: '" << data << "'.";
    }
}

void DeviceOperations::handleResponseTimeout() {
    if (currentCommand_ == commandList_.end()) {
        return;
    }
    BaseDeviceCommand *command = currentCommand_->get();
    qCWarning(logCategoryDeviceOperations) << this << "Command '" << command->name() << "' timed out.";
    command->onTimeout();  // This can change command result.
    // Some commands can timeout - result is other than 'InProgress' then.
    if (command->result() == CommandResult::InProgress) {
        finishOperation(DeviceOperation::Timeout);
    } else {
        // In this case we move to next command (or do retry).
        QTimer::singleShot(0, this, [this](){ nextCommand(); });
    }
}

void DeviceOperations::handleDeviceError(device::Device::ErrorCode errCode, QString msg) {
    Q_UNUSED(errCode)
    responseTimer_.stop();
    reset();
    qCCritical(logCategoryDeviceOperations) << this << "Error: " << msg;
    emit error(msg);
}

bool DeviceOperations::startOperation(DeviceOperation operation) {
    if (operation_ == DeviceOperation::None) {
        commandList_.clear();
    } else {  // another operation is runing
        // flash or backup firmware chunk is a special case
        if (operation_ != operation || (operation != DeviceOperation::FlashFirmwareChunk && operation != DeviceOperation::BackupFirmwareChunk)) {
            QString errMsg(QStringLiteral("Cannot start operation, because another operation is running."));
            qCWarning(logCategoryDeviceOperations) << this << errMsg;
            emit error(errMsg);
            return false;
        }
    }

    if (device_->lockDeviceForOperation(reinterpret_cast<quintptr>(this)) == false) {
        QString errMsg(QStringLiteral("Cannot start operation, because cannot get access to device."));
        qCWarning(logCategoryDeviceOperations) << this << errMsg;
        emit error(errMsg);
        return false;
    }

    operation_ = operation;

    return true;
}

void DeviceOperations::nextCommand() {
    if (currentCommand_ == commandList_.end()) {
        return;
    }
    BaseDeviceCommand *command = currentCommand_->get();
    CommandResult result = command->result();
    switch (result) {
    case CommandResult::InProgress :
        //qCDebug(logCategoryDeviceOperations) << this << "Waiting for valid notification to '" << command->name() << "' command.";
        break;
    case CommandResult::Done :
        ++currentCommand_;  // move to next command
        if (currentCommand_ == commandList_.end()) {  // end of command list - finish operation
            finishOperation(operation_, command->dataForFinish());
        } else {
            emit sendCommand(QPrivateSignal());  // send next command
        }
        break;
    case CommandResult::Repeat :
        // Only prepare for repeat, do not send command. Command will be
        // sent by calling function from DeviceOperations class (flash/backup FW chunk).
        command->prepareRepeat();
        // Operation is not finished yet, so emit only signal and do not call function finishOperation().
        emit finished(operation_, command->dataForFinish());
        break;
    case CommandResult::Retry :
        emit sendCommand(QPrivateSignal());  // send same command again
        break;
    case CommandResult::Failure :
        finishOperation(DeviceOperation::Failure);
        break;
    case CommandResult::FinaliseOperation :
        finishOperation(operation_, command->dataForFinish());
        break;
    }
}

void DeviceOperations::finishOperation(DeviceOperation operation, int data) {
    reset();
    emit finished(operation, data);
}

void DeviceOperations::reset() {
    commandList_.clear();
    currentCommand_ = commandList_.end();
    operation_ = DeviceOperation::None;
    device_->unlockDevice(reinterpret_cast<quintptr>(this));
}

}  // namespace
