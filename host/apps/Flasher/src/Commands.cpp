#include "Commands.h"
#include "SerialPortList.h"
#include "logging/LoggingQtCategories.h"
#include <Device/Device.h>
#include <Device/Serial/SerialDevice.h>
#include <Flasher.h>

#include <cstdlib>

namespace strata {

Command::~Command() { }

// WRONG command

WrongCommand::WrongCommand(const QString& message) : message_(message) { }

void WrongCommand::process() {
    qCCritical(logCategoryFlasherCli).noquote() << message_;
    emit finished(EXIT_FAILURE);
}


// HELP command

HelpCommand::HelpCommand(const QString& helpText) : helpText_(helpText) { }

void HelpCommand::process() {
    qCInfo(logCategoryFlasherCli).noquote() << helpText_;
    emit finished(EXIT_SUCCESS);
}


// VERSION command

VersionCommand::VersionCommand(const QString &appName, const QString &appDescription, const QString &appVersion) :
    appName_(appName), appDescription_(appDescription), appVersion_(appVersion) { }

void VersionCommand::process() {
    qCInfo(logCategoryFlasherCli).noquote().nospace() << appName_ << " (" << appDescription_ << ") " << appVersion_;
    emit finished(EXIT_SUCCESS);
}


// LIST command

void ListCommand::process() {
    SerialPortList serialPorts;
    auto const portList = serialPorts.list();
    QString message(QStringLiteral("List of available boards (serial devices):"));
    if (portList.isEmpty()) {
        message.append(QStringLiteral("\nNo board is conected."));
    } else {
        for (int i = 0; i < portList.size(); ++i) {
            message.append('\n');
            message.append(QString::number(i+1));
            message.append(QStringLiteral(". "));
            message.append(portList.at(i));
        }
    }
    qCInfo(logCategoryFlasherCli).noquote() << message;
    emit finished(EXIT_SUCCESS);
}


// FLASHER (FLASH/BACKUP firmware/bootloader) command

FlasherCommand::FlasherCommand(const QString &fileName, int deviceNumber, CmdType command) :
    fileName_(fileName), deviceNumber_(deviceNumber), command_(command) { }

// Destructor must be defined due to unique pointer to incomplete type.
FlasherCommand::~FlasherCommand() { }

void FlasherCommand::process() {
    SerialPortList serialPorts;

    if (serialPorts.count() == 0) {
        qCCritical(logCategoryFlasherCli) << "No board is connected.";
        emit finished(EXIT_FAILURE);
        return;
    }

    QString name = serialPorts.name(deviceNumber_ - 1);
    if (name.isEmpty()) {
        qCCritical(logCategoryFlasherCli) << "Board number" << deviceNumber_ << "is not available.";
        emit finished(EXIT_FAILURE);
        return;
    }

    device::DevicePtr device = std::make_shared<device::serial::SerialDevice>(static_cast<int>(qHash(name)), name);
    if (device->open() == false) {
        qCCritical(logCategoryFlasherCli) << "Cannot open board (serial device)" << name;
        emit finished(EXIT_FAILURE);
        return;
    }

    flasher_ = std::make_unique<Flasher>(device, fileName_);

    connect(flasher_.get(), &Flasher::finished, this, [=](Flasher::Result result, QString){
        emit this->finished((result == Flasher::Result::Ok) ? EXIT_SUCCESS : EXIT_FAILURE);
    });

    switch (command_) {
    case CmdType::FlashFirmware :
        flasher_->flashFirmware();
        break;
    case CmdType::FlashBootloader :
        flasher_->flashBootloader();
        break;
    case CmdType::BackupFirmware :
        flasher_->backupFirmware();
        break;
    }
}

}  // namespace
