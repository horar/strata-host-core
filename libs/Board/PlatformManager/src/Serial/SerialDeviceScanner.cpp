#include <Serial/SerialDeviceScanner.h>
#include "logging/LoggingQtCategories.h"

#include <QSerialPortInfo>

namespace strata::device::scanner {

constexpr std::chrono::milliseconds SERIAL_DEVICE_SCAN_INTERVAL(1000);

SerialDeviceScanner::SerialDeviceScanner()
    : DeviceScanner(Device::Type::SerialDevice) {
    connect(&timer_, &QTimer::timeout, this, &SerialDeviceScanner::checkNewSerialDevices, Qt::QueuedConnection);
}

SerialDeviceScanner::~SerialDeviceScanner() {
    if (timer_.isActive() || (deviceIds_.size() != 0)) {
        SerialDeviceScanner::deinit();
    }
}

void SerialDeviceScanner::init(quint32 flags) {
    if ((flags & SerialDeviceScanner::DisableAutomaticScan) == 0) {
        startAutomaticScan();
    }
}

void SerialDeviceScanner::deinit() {
    stopAutomaticScan();

    for (const auto& deviceId : deviceIds_) {
        emit deviceLost(deviceId);
    }

    deviceIds_.clear();
    portNames_.clear();
}

void SerialDeviceScanner::setProperties(quint32 flags) {
    if (flags & SerialDeviceScanner::DisableAutomaticScan) {
        stopAutomaticScan();
    }
}

void SerialDeviceScanner::unsetProperties(quint32 flags) {
    if (flags & SerialDeviceScanner::DisableAutomaticScan) {
        startAutomaticScan();
    }
}

void SerialDeviceScanner::startAutomaticScan() {
    if (timer_.isActive()) {
        qCWarning(logCategoryDeviceScanner) << "Device scan is already running.";
    } else {
        qCDebug(logCategoryDeviceScanner) << "Starting device scan.";
        timer_.start(SERIAL_DEVICE_SCAN_INTERVAL);
    }
}

void SerialDeviceScanner::stopAutomaticScan() {
    if (timer_.isActive()) {
        qCDebug(logCategoryDeviceScanner) << "Stopping device scan.";
        timer_.stop();
    } else {
        qCWarning(logCategoryDeviceScanner) << "Device scan is already stopped.";
    }
}

void SerialDeviceScanner::checkNewSerialDevices() {
#if defined(Q_OS_MACOS)
    const QString usbKeyword("usb");
    const QString cuKeyword("cu");
#elif defined(Q_OS_LINUX)
    // TODO: this code was not tested on Linux, test it
    const QString usbKeyword("USB");
#elif defined(Q_OS_WIN)
    const QString usbKeyword("COM");
#endif

    const auto serialPortInfos = QSerialPortInfo::availablePorts();
    std::set<QByteArray> detectedDeviceIds;
    QHash<QByteArray, QString> detectedPortNames;

    for (const QSerialPortInfo& serialPortInfo : serialPortInfos) {
        const QString& portName = serialPortInfo.portName();

        if (serialPortInfo.isNull()) {
            continue;
        }
        if (portName.contains(usbKeyword) == false) {
            continue;
        }
#ifdef Q_OS_MACOS
        if (portName.startsWith(cuKeyword) == false) {
            continue;
        }
#endif
        // device ID must be int because of integration with QML
        const QByteArray deviceId = createDeviceId(SerialDevice::createUniqueHash(portName));
        auto [iter, success] = detectedDeviceIds.emplace(deviceId);
        if (success == false) {
            // Error: hash already exists!
            qCCritical(logCategoryDeviceScanner).nospace().noquote()
                << "Cannot add device (hash conflict: " << deviceId << "): '" << portName << "'";
            continue;
        }
        detectedPortNames.insert(deviceId, portName);

        // qCDebug(logCategoryDeviceScanner).nospace().noquote() << "Found serial device, ID: " << deviceId << ", name: '" << name << "'";
    }

    std::set<QByteArray> addedDeviceIds, removedDeviceIds;
    computeListDiff(deviceIds_, detectedDeviceIds, addedDeviceIds, removedDeviceIds);

    portNames_ = std::move(detectedPortNames); // must be called before addSerialDevice

    for (const auto& deviceId : removedDeviceIds) {
        emit deviceLost(deviceId);
    }

    for (const auto& deviceId : addedDeviceIds) {
        if (addSerialDevice(deviceId) == false) {
            // If serial port cannot be opened (for example it is hold by another application),
            // remove it from list of known ports. There will be another attempt to open it in next round.
            detectedDeviceIds.erase(deviceId);
            auto iter = portNames_.find(deviceId);
            if (iter != portNames_.end())
                portNames_.erase(iter);
        }
    }

    deviceIds_ = std::move(detectedDeviceIds); // must be called after addSerialDevice
}

void SerialDeviceScanner::computeListDiff(const std::set<QByteArray>& originalList, const std::set<QByteArray>& newList,
                                          std::set<QByteArray>& addedList, std::set<QByteArray>& removedList) const {
    // create differences of the lists.. what is added / removed
    std::set_difference(newList.begin(), newList.end(),
                        originalList.begin(), originalList.end(),
                        std::inserter(addedList, addedList.begin()));

    std::set_difference(originalList.begin(), originalList.end(),
                        newList.begin(), newList.end(),
                        std::inserter(removedList, removedList.begin()));
}

bool SerialDeviceScanner::addSerialDevice(const QByteArray& deviceId) {
    // 1. construct the serial device
    // 2. emit signal

    const QString name = portNames_.value(deviceId);

    SerialDevice::SerialPortPtr serialPort = SerialDevice::establishPort(name);

    if (serialPort == nullptr) {
        qCInfo(logCategoryDeviceScanner).nospace().noquote()
            << "Port for device: ID: " << deviceId << ", name: '" << name
            << "' cannot be open, it is probably held by another application.";
        return false;
    }

    DevicePtr device = std::make_shared<SerialDevice>(deviceId, name, std::move(serialPort));
    platform::PlatformPtr platform = std::make_shared<platform::Platform>(device);

    qCInfo(logCategoryDeviceScanner).nospace().noquote()
        << "Created new serial device: ID: " << deviceId << ", name: '" << name << "'";

    emit deviceDetected(platform);

    return true;
}

}  // namespace

