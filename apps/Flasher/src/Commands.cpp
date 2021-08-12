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

Command::Command() { }

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

ListCommand::ListCommand() { }

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

// DEVICE command

DeviceCommand::DeviceCommand(int deviceNumber) :
    deviceNumber_(deviceNumber), openRetries_(0) { }

// Destructor must be defined due to unique pointer to incomplete type.
DeviceCommand::~DeviceCommand() { }

bool DeviceCommand::createSerialDevice() {
    SerialPortList serialPorts;

    if (serialPorts.count() == 0) {
        qCCritical(logCategoryFlasherCli) << "No board is connected.";
        return false;
    }

    const QString name = serialPorts.name(deviceNumber_ - 1);
    if (name.isEmpty()) {
        qCCritical(logCategoryFlasherCli) << "Board number" << deviceNumber_ << "is not available.";
        return false;
    }

    const QByteArray deviceId = SerialDevice::createUniqueHash(name); // no scanner prefix in deviceId, because there is no scanner
    device::DevicePtr device = std::make_shared<SerialDevice>(deviceId, name);
    platform_ = std::make_shared<platform::Platform>(device);

    connect(platform_.get(), &platform::Platform::opened, this, &DeviceCommand::handlePlatformOpened, Qt::QueuedConnection);
    connect(platform_.get(), &platform::Platform::deviceError, this, &DeviceCommand::handleDeviceError, Qt::QueuedConnection);

    return true;
}

void DeviceCommand::handleDeviceError(device::Device::ErrorCode errCode, QString errStr) {
    switch (errCode) {
    case device::Device::ErrorCode::NoError :
        break;
    case device::Device::ErrorCode::DeviceFailedToOpen :
        {
            ++openRetries_;
            QString errorMessage(QStringLiteral("Cannot open board (serial device) "));
            errorMessage.append(platform_->deviceName());
            errorMessage.append(QStringLiteral(", attempt "));
            errorMessage.append(QString::number(openRetries_));
            errorMessage.append(QStringLiteral(" of "));
            errorMessage.append(QString::number(OPEN_MAX_RETRIES));

            if (openRetries_ >= OPEN_MAX_RETRIES) {
                qCCritical(logCategoryFlasherCli).noquote() << errorMessage;
                emit finished(EXIT_FAILURE);
            } else {
                qCInfo(logCategoryFlasherCli).noquote() << errorMessage;
            }
        }
        break;
    case device::Device::ErrorCode::DeviceDisconnected :
    case device::Device::ErrorCode::DeviceError :
        qCCritical(logCategoryFlasherCli).noquote() << QStringLiteral("Device error:") << errStr;
        emit criticalDeviceError();
        break;
    }
}

// FLASHER (FLASH/BACKUP firmware/bootloader) command

FlasherCommand::FlasherCommand(const QString &fileName, int deviceNumber, CmdType command) :
    DeviceCommand(deviceNumber),
    fileName_(fileName),
    command_(command)
{
    connect(this, &DeviceCommand::criticalDeviceError, this, &FlasherCommand::handleCriticalDeviceError);
}

// Destructor must be defined due to unique pointer to incomplete type.
FlasherCommand::~FlasherCommand() { }

void FlasherCommand::process() {
    if (createSerialDevice() == false) {
        emit finished(EXIT_FAILURE);
        return;
    }

    platform_->open(DEVICE_CHECK_INTERVAL);
}

void FlasherCommand::handlePlatformOpened() {
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

void FlasherCommand::handleCriticalDeviceError() {
    // Commands in flasher reacts on Device errors, so handle them only if flasher is not created yet
    if (flasher_ == nullptr) {
        emit finished(EXIT_FAILURE);
    }
}

// INFO command

InfoCommand::InfoCommand(int deviceNumber) :
    DeviceCommand(deviceNumber)
{
    connect(this, &DeviceCommand::criticalDeviceError, this, &InfoCommand::handleCriticalDeviceError);
}

// Destructor must be defined due to unique pointer to incomplete type.
InfoCommand::~InfoCommand() { }

void InfoCommand::process() {
    if (createSerialDevice() == false) {
        emit finished(EXIT_FAILURE);
        return;
    }

    platform_->open(DEVICE_CHECK_INTERVAL);
}

void InfoCommand::handlePlatformOpened() {
    identifyOperation_ = std::make_unique<platform::operation::Identify>(platform_, false);

    connect(identifyOperation_.get(), &platform::operation::BasePlatformOperation::finished,
            this, &InfoCommand::handleIdentifyOperationFinished);

    identifyOperation_->run();
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

void InfoCommand::handleCriticalDeviceError() {
    // Commands in identify operation reacts on Device errors, so handle them only if this operation is not created yet
    if (identifyOperation_ == nullptr) {
        emit finished(EXIT_FAILURE);
    }
}

}  // namespace
