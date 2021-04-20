#include "Commands.h"
#include "SerialPortList.h"
#include "logging/LoggingQtCategories.h"
#include <Platform.h>
#include <Serial/SerialDevice.h>
#include <Operations/Identify.h>
#include <Flasher.h>

#include <cstdlib>

namespace strata {

constexpr std::chrono::milliseconds DEVICE_CHECK_INTERVAL(1000);
constexpr unsigned int OPEN_MAX_RETRIES(5);

using device::SerialDevice;

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
    fileName_(fileName), deviceNumber_(deviceNumber), command_(command), openRetries_(0) { }

// Destructor must be defined due to unique pointer to incomplete type.
FlasherCommand::~FlasherCommand() { }

void FlasherCommand::process() {
    SerialPortList serialPorts;

    if (serialPorts.count() == 0) {
        qCCritical(logCategoryFlasherCli) << "No board is connected.";
        emit finished(EXIT_FAILURE);
        return;
    }

    const QString name = serialPorts.name(deviceNumber_ - 1);
    if (name.isEmpty()) {
        qCCritical(logCategoryFlasherCli) << "Board number" << deviceNumber_ << "is not available.";
        emit finished(EXIT_FAILURE);
        return;
    }

    const QByteArray deviceId = SerialDevice::createDeviceId(name);
    device::DevicePtr device = std::make_shared<SerialDevice>(deviceId, name);
    platform::PlatformPtr platform = std::make_shared<platform::Platform>(device);

    platform_ = std::make_shared<platform::Platform>(device);

    connect(platform_.get(), &platform::Platform::opened, this, &FlasherCommand::handlePlatformOpened, Qt::QueuedConnection);
    connect(platform_.get(), &platform::Platform::deviceError, this, &FlasherCommand::handleDeviceError, Qt::QueuedConnection);

    platform_->open(DEVICE_CHECK_INTERVAL);
}

void FlasherCommand::handlePlatformOpened(QByteArray deviceId) {
    Q_UNUSED(deviceId)

    flasher_ = std::make_unique<Flasher>(platform_, fileName_);

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

void FlasherCommand::handleDeviceError(QByteArray deviceId, device::Device::ErrorCode errCode, QString errStr) {
    Q_UNUSED(deviceId)
    Q_UNUSED(errStr)

    if (errCode == device::Device::ErrorCode::DeviceFailedToOpen) {
        if (++openRetries_ >= OPEN_MAX_RETRIES) {
            qCCritical(logCategoryFlasherCli).nospace() << "Cannot open board (serial device) " << platform_->deviceName()
                                                        << ", attempt " << openRetries_ << " of " << OPEN_MAX_RETRIES;
            emit finished(EXIT_FAILURE);
            return;
        } else {
            qCInfo(logCategoryFlasherCli).nospace() << "Cannot to open board (serial device) " << platform_->deviceName()
                                                    << ", attempt " << openRetries_ << " of " << OPEN_MAX_RETRIES;
        }
    }
}

// INFO command

InfoCommand::InfoCommand(int deviceNumber) :
    deviceNumber_(deviceNumber), openRetries_(0) { }

// Destructor must be defined due to unique pointer to incomplete type.
InfoCommand::~InfoCommand() { }

void InfoCommand::process() {
    SerialPortList serialPorts;

    if (serialPorts.count() == 0) {
        qCCritical(logCategoryFlasherCli) << "No board is connected.";
        emit finished(EXIT_FAILURE);
        return;
    }

    const QString name = serialPorts.name(deviceNumber_ - 1);
    if (name.isEmpty()) {
        qCCritical(logCategoryFlasherCli) << "Board number" << deviceNumber_ << "is not available.";
        emit finished(EXIT_FAILURE);
        return;
    }

    const QByteArray deviceId = SerialDevice::createDeviceId(name);
    device::DevicePtr device = std::make_shared<SerialDevice>(deviceId, name);
    platform_ = std::make_shared<platform::Platform>(device);

    connect(platform_.get(), &platform::Platform::opened, this, &InfoCommand::handlePlatformOpened, Qt::QueuedConnection);
    connect(platform_.get(), &platform::Platform::deviceError, this, &InfoCommand::handleDeviceError, Qt::QueuedConnection);

    platform_->open(DEVICE_CHECK_INTERVAL);
}

void InfoCommand::handlePlatformOpened(QByteArray deviceId) {
    Q_UNUSED(deviceId)

    identifyOperation_ = std::make_unique<platform::operation::Identify>(platform_, false);

    connect(identifyOperation_.get(), &platform::operation::BasePlatformOperation::finished,
            this, &InfoCommand::handleIdentifyOperationFinished);

    identifyOperation_->run();
}

void InfoCommand::handleDeviceError(QByteArray deviceId, device::Device::ErrorCode errCode, QString errStr) {
    Q_UNUSED(deviceId)
    Q_UNUSED(errStr)

    if (errCode == device::Device::ErrorCode::DeviceFailedToOpen) {
        if (++openRetries_ >= OPEN_MAX_RETRIES) {
            qCCritical(logCategoryFlasherCli).nospace() << "Cannot open board (serial device) " << platform_->deviceName()
                                                        << ", attempt " << openRetries_ << " of " << OPEN_MAX_RETRIES;
            emit finished(EXIT_FAILURE);
            return;
        } else {
            qCInfo(logCategoryFlasherCli).nospace() << "Cannot to open board (serial device) " << platform_->deviceName()
                                                    << ", attempt " << openRetries_ << " of " << OPEN_MAX_RETRIES;
        }
    }
}

void InfoCommand::handleIdentifyOperationFinished(platform::operation::Result result, int status, QString errStr) {
    Q_UNUSED(status)

    platform::operation::Identify *identifyOp = qobject_cast<platform::operation::Identify*>(QObject::sender());
    if ((identifyOp == nullptr) || (identifyOp != identifyOperation_.get())) {
        qCCritical(logCategoryFlasherCli) << "Received corrupt operation pointer:" << identifyOp;
        emit finished(EXIT_FAILURE);
        return;
    }

    switch(result) {
    case platform::operation::Result::Success: {
        QString message(QStringLiteral("List of available parameters for board:"));

        message.append(QStringLiteral("\nApplication Name: "));
        message.append(platform_->name());
        message.append(QStringLiteral("\nDevice Name: "));
        message.append(platform_->deviceName());
        message.append(QStringLiteral("\nDevice Id: "));
        message.append(platform_->deviceId());
        message.append(QStringLiteral("\nDevice Type: "));
        message.append(QVariant::fromValue(platform_->deviceType()).toString());
        message.append(QStringLiteral("\nController Type: "));
        message.append(QVariant::fromValue(platform_->controllerType()).toString());
        if (platform_->controllerType() == platform::Platform::ControllerType::Assisted) {
            message.append(QStringLiteral(" (Platform Connected: "));
            message.append(QVariant(platform_->isControllerConnectedToPlatform()).toString());
            message.append(QStringLiteral(")"));
        }
        message.append(QStringLiteral("\nBoard Mode: "));
        message.append(QVariant::fromValue(identifyOp->boardMode()).toString());
        message.append(QStringLiteral(" (API: "));
        message.append(QVariant::fromValue(platform_->apiVersion()).toString());
        message.append(QStringLiteral(")\nApplication version: "));
        message.append(platform_->applicationVer());
        message.append(QStringLiteral("\nBootloader version: "));
        message.append(platform_->bootloaderVer());
        message.append(QStringLiteral("\nPlatform Id: "));
        message.append(platform_->platformId());
        message.append(QStringLiteral("\nClass Id: "));
        message.append(platform_->classId());
        message.append(QStringLiteral("\nController Platform Id: "));
        message.append(platform_->controllerPlatformId());
        message.append(QStringLiteral("\nController Class Id: "));
        message.append(platform_->controllerClassId());
        message.append(QStringLiteral("\nFirmware Class Id: "));
        message.append(platform_->firmwareClassId());

        qCInfo(logCategoryFlasherCli).noquote() << message;
        emit finished(EXIT_SUCCESS);
    } break;
    default: {
        qCWarning(logCategoryFlasherCli) << "Identify operation failed:" << errStr;
        emit finished(EXIT_FAILURE);
    } break;
    }
}

}  // namespace
