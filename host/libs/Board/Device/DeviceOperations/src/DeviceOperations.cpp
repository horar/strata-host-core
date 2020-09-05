#include <Device/DeviceOperations.h>
#include "DeviceOperationsConstants.h"
#include "DeviceCommands/DeviceCommands.h"

#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

#include <rapidjson/document.h>

namespace strata::device {

using command::BaseDeviceCommand;
using command::CmdGetFirmwareInfo;
using command::CmdRequestPlatformId;
using command::CmdStartBootloader;
using command::CmdFlash;
using command::CmdBackupFirmware;
using command::CmdStartApplication;
using command::CommandResult;

DeviceOperations::DeviceOperations(const DevicePtr& device) :
    operation_(DeviceOperation::None), device_(device), responseTimer_(this)
{
    deviceId_ = static_cast<uint>(device_->deviceId());

    responseTimer_.setSingleShot(true);
    responseTimer_.setInterval(RESPONSE_TIMEOUT);

    currentCommand_ = commandList_.end();

    connect(this, &DeviceOperations::sendCommand, this, &DeviceOperations::handleSendCommand, Qt::QueuedConnection);
    connect(device_.get(), &Device::msgFromDevice, this, &DeviceOperations::handleDeviceResponse);
    connect(device_.get(), &Device::deviceError, this, &DeviceOperations::handleDeviceError);
    connect(&responseTimer_, &QTimer::timeout, this, &DeviceOperations::handleResponseTimeout);

    qCDebug(logCategoryDeviceOperations) << device_ << "Created object for device operations.";
}

DeviceOperations::~DeviceOperations() {
    device_->unlockDevice(reinterpret_cast<quintptr>(this));
    qCDebug(logCategoryDeviceOperations) << device_ << "Finished operations.";
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
        commandList_.emplace_back(std::make_unique<CmdStartBootloader>(device_));
        commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(device_));
        commandList_.emplace_back(std::make_unique<CmdGetFirmwareInfo>(device_, false));
        currentCommand_ = commandList_.begin();
        emit sendCommand(QPrivateSignal());
    }
}

void DeviceOperations::flashChunk(const QVector<quint8>& chunk, int chunkNumber, bool flashFirmware) {
    DeviceOperation operation = (flashFirmware) ?
                                DeviceOperation::FlashFirmwareChunk :
                                DeviceOperation::FlashBootloaderChunk;
    if (startOperation(operation)) {
        if (commandList_.empty()) {
            commandList_.emplace_back(std::make_unique<CmdFlash>(device_, flashFirmware));
            currentCommand_ = commandList_.begin();
        }
        if (currentCommand_ != commandList_.end()) {
            CmdFlash *cmdFlash = dynamic_cast<CmdFlash*>(currentCommand_->get());
            if (cmdFlash != nullptr) {
                cmdFlash->setChunk(chunk, chunkNumber);
                emit sendCommand(QPrivateSignal());
            }
        }
    }
}

void DeviceOperations::flashFirmwareChunk(const QVector<quint8>& chunk, int chunkNumber) {
    flashChunk(chunk, chunkNumber, true);
}

void DeviceOperations::flashBootloaderChunk(const QVector<quint8>& chunk, int chunkNumber) {
    flashChunk(chunk, chunkNumber, false);
}

void DeviceOperations::backupFirmwareChunk() {
    if (startOperation(DeviceOperation::BackupFirmwareChunk)) {
        if (commandList_.empty()) {
            commandList_.emplace_back(std::make_unique<CmdBackupFirmware>(device_, backupChunk_, backupChunksCount_));
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
        commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(device_, MAX_PLATFORM_ID_RETRIES));
        commandList_.emplace_back(std::make_unique<CmdGetFirmwareInfo>(device_, false));
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

int DeviceOperations::backupChunksCount() const {
    return backupChunksCount_;
}

void DeviceOperations::handleSendCommand() {
    if (currentCommand_ == commandList_.end()) {
        return;
    }
    BaseDeviceCommand *command = currentCommand_->get();
    if (command->skip()) {
        qCDebug(logCategoryDeviceOperations) << device_ << "Skipping '" << command->name() << "' command.";
        QTimer::singleShot(0, this, [this](){ nextCommand(); });
    } else {
        QString logMsg(QStringLiteral("Sending '") + command->name() + QStringLiteral("' command."));
        if (command->logSendMessage()) {
            qCInfo(logCategoryDeviceOperations) << device_ << logMsg;
        } else {
            qCDebug(logCategoryDeviceOperations) << device_ << logMsg;
        }

        if (device_->sendMessage(command->message(), reinterpret_cast<quintptr>(this))) {
            responseTimer_.start();
        } else {
            QString errMsg(QStringLiteral("Cannot send '") + command->name() + QStringLiteral("' command."));
            qCCritical(logCategoryDeviceOperations) << device_ << errMsg;
            reset();
            emit error(errMsg);
        }
    }
}

void DeviceOperations::handleDeviceResponse(const QByteArray& data) {
    if (currentCommand_ == commandList_.end()) {
        qCDebug(logCategoryDeviceOperations) << device_ << "No command is being processed, message from device is ignored.";
        return;
    }

    rapidjson::Document doc;

    if (CommandValidator::parseJsonCommand(data.toStdString(), doc) == false) {
        qCWarning(logCategoryDeviceOperations) << device_ << "Cannot parse JSON: '" << data << "'.";
        return;
    }

    bool ok = false;

    if (doc.HasMember(JSON_ACK)) {
        if (CommandValidator::validate(CommandValidator::JsonType::ack, doc)) {
            const QString ackStr = doc[JSON_ACK].GetString();
            qCDebug(logCategoryDeviceOperations) << device_ << "Received '" << ackStr << "' ACK.";
            BaseDeviceCommand *command = currentCommand_->get();
            if (ackStr == command->name()) {
                const rapidjson::Value& payload = doc[JSON_PAYLOAD];
                const bool ackOk = payload[JSON_RETURN_VALUE].GetBool();
                if (ackOk) {
                    command->setAckReceived();
                } else {
                    const QString ackError = payload[JSON_RETURN_STRING].GetString();
                    qCWarning(logCategoryDeviceOperations) << device_ << "ACK for '" << command->name() << "' command is not OK: '" << ackError << "'.";
                }
            } else {
                qCWarning(logCategoryDeviceOperations) << device_ << "Received wrong ACK. Expected '" << command->name() << "', got '" << ackStr << "'.";
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
                    qCWarning(logCategoryDeviceOperations) << device_ << "Received notification without previous ACK.";
                }
                qCDebug(logCategoryDeviceOperations) << device_ << "Processed '" << command->name() << "' notification.";

                if (command->result() == CommandResult::Failure) {
                    qCWarning(logCategoryDeviceOperations) << device_ << "Received faulty notification: '" << data << "'.";
                }

                QTimer::singleShot(command->waitBeforeNextCommand(), this, [this](){ nextCommand(); });
            }
        }
    }

    if (ok == false) {
        qCWarning(logCategoryDeviceOperations) << device_ << "Received wrong or malformed response: '" << data << "'.";
    }
}

void DeviceOperations::handleResponseTimeout() {
    if (currentCommand_ == commandList_.end()) {
        return;
    }
    BaseDeviceCommand *command = currentCommand_->get();
    qCWarning(logCategoryDeviceOperations) << device_ << "Command '" << command->name() << "' timed out.";
    command->onTimeout();  // This can change command result.
    // Some commands can timeout - result is other than 'InProgress' then.
    if (command->result() == CommandResult::InProgress) {
        finishOperation(DeviceOperation::Timeout);
    } else {
        // In this case we move to next command (or do retry).
        QTimer::singleShot(0, this, [this](){ nextCommand(); });
    }
}

void DeviceOperations::handleDeviceError(Device::ErrorCode errCode, QString msg) {
    Q_UNUSED(errCode)
    responseTimer_.stop();
    reset();
    qCCritical(logCategoryDeviceOperations) << device_ << "Error: " << msg;
    emit error(msg);
}

bool DeviceOperations::startOperation(DeviceOperation operation) {
    if (operation_ == DeviceOperation::None) {
        commandList_.clear();
    } else {  // another operation is runing
        // flash or backup firmware (or bootloader) chunk is a special case
        if (operation_ != operation ||
                (operation != DeviceOperation::FlashFirmwareChunk &&
                 operation != DeviceOperation::BackupFirmwareChunk &&
                 operation != DeviceOperation::FlashBootloaderChunk)
           )
        {
            QString errMsg(QStringLiteral("Cannot start operation, because another operation is running."));
            qCWarning(logCategoryDeviceOperations) << device_ << errMsg;
            emit error(errMsg);
            return false;
        }
    }

    if (device_->lockDeviceForOperation(reinterpret_cast<quintptr>(this)) == false) {
        QString errMsg(QStringLiteral("Cannot start operation, because cannot get access to device."));
        qCWarning(logCategoryDeviceOperations) << device_ << errMsg;
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
        //qCDebug(logCategoryDeviceOperations) << device_ << "Waiting for valid notification to '" << command->name() << "' command.";
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
