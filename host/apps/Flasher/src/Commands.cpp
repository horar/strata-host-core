#include "Commands.h"
#include "SerialPortList.h"
#include "logging/LoggingQtCategories.h"
#include <Device/Device.h>
#include <Device/Serial/SerialDevice.h>
#include <Device/Operations/Identify.h>
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

// INFO command

constexpr std::chrono::milliseconds IDENTIFY_LAUNCH_DELAY(500);
constexpr unsigned int GET_FW_INFO_MAX_RETRIES(2);
constexpr bool REQ_FW_INFO_RESP(false);

InfoCommand::InfoCommand(int deviceNumber) :
    deviceNumber_(deviceNumber) { }

// Destructor must be defined due to unique pointer to incomplete type.
InfoCommand::~InfoCommand() { }

void InfoCommand::process() {
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

    device_ = std::make_shared<device::serial::SerialDevice>(static_cast<int>(qHash(name)), name);
    if (device_->open() == false) {
        qCCritical(logCategoryFlasherCli) << "Cannot open board (serial device)" << name;
        emit finished(EXIT_FAILURE);
        return;
    }

    identifyOperation_.reset(
        // Some boards need time for booting. If board is rebooted it also takes some time to start.
        new device::operation::Identify(device_, REQ_FW_INFO_RESP, GET_FW_INFO_MAX_RETRIES, IDENTIFY_LAUNCH_DELAY),
        [] (device::operation::BaseDeviceOperation *operation) { operation->deleteLater(); }
    );

    connect(identifyOperation_.get(), &device::operation::BaseDeviceOperation::finished,
            this, &InfoCommand::handleIdentifyOperationFinished);

    identifyOperation_->run();
}


void InfoCommand::handleIdentifyOperationFinished(device::operation::Result result, int status, QString errStr) {
    Q_UNUSED(status)

    device::operation::BaseDeviceOperation *baseOp = qobject_cast<device::operation::BaseDeviceOperation*>(QObject::sender());
    if ((baseOp == nullptr) || (baseOp != identifyOperation_.get())) {
        qCCritical(logCategoryFlasherCli) << "Received corrupt operation pointer:" << baseOp;
        emit finished(EXIT_FAILURE);
        return;
    }

    device::operation::Identify *identifyOp = dynamic_cast<device::operation::Identify*>(baseOp);
    if (identifyOp == nullptr) {
        qCCritical(logCategoryFlasherCli) << "Received invalid operation pointer:" << baseOp;
        emit finished(EXIT_FAILURE);
        return;
    }

    switch(result) {
    case device::operation::Result::Success: {
        QString message(QStringLiteral("List of available parameters for board:"));

        message.append(QStringLiteral("\nDevice Name: "));
        message.append(device_->deviceName());
        message.append(QStringLiteral("\nDevice Id: "));
        message.append(QString::number(device_->deviceId()));
        message.append(QStringLiteral("\nDevice Type: "));
        message.append(QVariant::fromValue(device_->deviceType()).toString());
        message.append(QStringLiteral("\nBoard Mode: "));
        message.append(QVariant::fromValue(identifyOp->boardMode()).toString());

        if (device_->applicationVer().isEmpty() == false) {
            message.append(QStringLiteral("\nApplication version: "));
            message.append(device_->applicationVer());
        } else if (device_->bootloaderVer().isEmpty() == false) {
            message.append(QStringLiteral("\nBootloader version: "));
            message.append(device_->bootloaderVer());
        } else {
            message.append(QStringLiteral("\nUnknown version"));
        }

        qCInfo(logCategoryFlasherCli).noquote() << message;
        emit finished(EXIT_SUCCESS);
    } break;
    case device::operation::Result::Reject: {
        qCInfo(logCategoryFlasherCli) << "Identify operation was rejected: operation is not supported by device";
        emit finished(EXIT_FAILURE);
    } break;
    case device::operation::Result::Cancel: {
        qCInfo(logCategoryFlasherCli) << "Identify operation was cancelled";
        emit finished(EXIT_SUCCESS);
    } break;
    case device::operation::Result::Timeout: {
        qCInfo(logCategoryFlasherCli) << "Identify operation resulted in timeout: no response from device";
        emit finished(EXIT_FAILURE);
    } break;
    case device::operation::Result::Failure: {
        qCInfo(logCategoryFlasherCli) << "Identify operation resulted in failure: faulty response from device";
        emit finished(EXIT_FAILURE);
    } break;
    case device::operation::Result::Error: {
        qCInfo(logCategoryFlasherCli) << "Identify operation resulted in error:" << errStr;
        emit finished(EXIT_FAILURE);
    } break;
    }
}

}  // namespace
