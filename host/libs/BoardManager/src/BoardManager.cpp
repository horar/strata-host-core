#include "BoardManager.h"
#include "BoardManagerConstants.h"
#include "logging/LoggingQtCategories.h"
#include <SerialDevice.h>

#include <QSerialPortInfo>


namespace strata {

BoardManager::BoardManager() {
    connect(&timer_, &QTimer::timeout, this, &BoardManager::checkNewSerialDevices);
}

void BoardManager::init(bool getFwInfo) {
    getFwInfo_ = getFwInfo;
    timer_.start(DEVICE_CHECK_INTERVAL);
}

void BoardManager::sendMessage(const int connectionId, const QString &message) {
    // in case of multithread usage lock access to openedSerialPorts_
    auto it = openedSerialPorts_.constFind(connectionId);
    if (it != openedSerialPorts_.constEnd()) {
        it.value()->write(message.toUtf8());
    }
    else {
        logInvalidDeviceId(QStringLiteral("Cannot send message"), connectionId);
        emit invalidOperation(connectionId);
    }
}

void BoardManager::disconnect(const int deviceId) {
    // in case of multithread usage lock access to openedSerialPorts_
    auto it = openedSerialPorts_.find(deviceId);
    if (it != openedSerialPorts_.end()) {
        it.value()->close();
        it.value().reset();
        openedSerialPorts_.erase(it);

        emit boardDisconnected(deviceId);
    }
    else {
        logInvalidDeviceId(QStringLiteral("Cannot disconnect"), deviceId);
        emit invalidOperation(deviceId);
    }
}

void BoardManager::reconnect(const int deviceId) {
    // in case of multithread usage lock access to openedSerialPorts_
    bool ok = false;
    auto it = openedSerialPorts_.find(deviceId);
    if (it != openedSerialPorts_.end()) {
        it.value()->close();
        it.value().reset();
        openedSerialPorts_.erase(it);
        ok = true;
    }
    else {
        // desired port is not opened, check if it is connected
        if (serialPortsList_.find(deviceId) != serialPortsList_.end()) {
            ok = true;
        }
    }
    if (ok) {
        addedSerialPort(deviceId);
    }
    else {
        logInvalidDeviceId(QStringLiteral("Cannot reconnect"), deviceId);
        emit invalidOperation(deviceId);
    }
}

SerialDeviceShPtr BoardManager::getDevice(const int deviceId) const {
    // in case of multithread usage lock access to openedSerialPorts_
    auto it = openedSerialPorts_.constFind(deviceId);
    if (it != openedSerialPorts_.constEnd()) {
        return it.value();
    } else {
        return nullptr;
    }
}

QVariantMap BoardManager::getConnectionInfo(const int connectionId) {
    // in case of multithread usage lock access to openedSerialPorts_
    auto it = openedSerialPorts_.constFind(connectionId);
    if (it != openedSerialPorts_.constEnd()) {
        return it.value()->getDeviceInfo();
    }
    else {
        logInvalidDeviceId(QStringLiteral("Cannot get connection info"), connectionId);
        emit invalidOperation(connectionId);
        return QVariantMap();
    }
}

QVector<int> BoardManager::readyConnectionIds() {
    // in case of multithread usage lock access to openedSerialPorts_
    return QVector<int>::fromList(openedSerialPorts_.keys());
}

QString BoardManager::getDeviceProperty(const int connectionId, const DeviceProperties property) {
    // in case of multithread usage lock access to openedSerialPorts_
    auto it = openedSerialPorts_.constFind(connectionId);
    if (it != openedSerialPorts_.constEnd()) {
        return it.value()->getProperty(property);
    }
    else {
        logInvalidDeviceId(QStringLiteral("Cannot get required device property"), connectionId);
        emit invalidOperation(connectionId);
        return QString();
    }
}

void BoardManager::checkNewSerialDevices() {
#if defined(Q_OS_MACOS)
    const QString usb_keyword("usb");
    const QString cu_keyword("cu");
#elif defined(Q_OS_LINUX)
    // TODO: this code was not tested on Linux, test it
    const QString usb_keyword("USB");
#elif defined(Q_OS_WIN)
    const QString usb_keyword("COM");
#endif

    const auto serialPortInfos = QSerialPortInfo::availablePorts();
    std::set<int> ports;
    QHash<int, QString> id_to_name;

    for (const QSerialPortInfo& serialPortInfo : serialPortInfos) {
        const QString& name = serialPortInfo.portName();

        if (serialPortInfo.isNull()) {
            continue;
        }
        if (name.contains(usb_keyword) == false) {
            continue;
        }
#ifdef Q_OS_MACOS
        if (name.startsWith(cu_keyword) == false) {
            continue;
        }
#endif
        // conection ID must be int because of integration with QML
        int device_id = static_cast<int>(qHash(name));
        auto [iter, success] = ports.emplace(device_id);
        if (success == false) {
            // Error: hash already exists!
            qCCritical(logCategoryBoardManager).nospace() << "Cannot add device (hash conflict: 0x" << hex << static_cast<uint>(device_id) << "): " << name;
            continue;
        }
        id_to_name.insert(device_id, name);

        // qCDebug(logCategoryBoardManager).nospace() << "Found serial device, ID: 0x" << hex << static_cast<uint>(connectionId) << ", name: " << name;
    }

    std::set<int> added, removed;
    std::vector<int> opened;
    opened.reserve(added.size());

    // in case of multithread usage lock this block of code (see comment in *.h file)
    {  // this block of code modifies serialPortsList_, openedSerialPorts_, serialIdToName_

        serialIdToName_ = std::move(id_to_name);

        computeListDiff(ports, added, removed);  // uses serialPortsList_ (needs old value from previous run)

        for (auto device_id : removed) {
            removedSerialPort(device_id);  // modifies openedSerialPorts_
            emit boardDisconnected(device_id);  // if this block of code is locked emit this after end of the block
        }

        for (auto device_id : added) {
            if (addedSerialPort(device_id)) {  // modifies openedSerialPorts_, uses serialIdToName_
                opened.emplace_back(device_id);
                emit boardConnected(device_id);  // if this block of code is locked emit this after end of the block
            }
        }

        serialPortsList_ = std::move(ports);
    }

    if (opened.empty() == false || removed.empty() == false) {
        // in case of multithread usage emit signals here (iterate over 'removed' and 'opened' containers)

        emit readyConnectionIdsChanged();
    }
}

// in case of multithread usage mutex must be locked before calling this function (due to accessing serialPortsList_)
void BoardManager::computeListDiff(std::set<int>& list, std::set<int>& added_ports, std::set<int>& removed_ports) {
    //create differences of the lists.. what is added / removed
    std::set_difference(list.begin(), list.end(),
                        serialPortsList_.begin(), serialPortsList_.end(),
                        std::inserter(added_ports, added_ports.begin()));

    std::set_difference(serialPortsList_.begin(), serialPortsList_.end(),
                        list.begin(), list.end(),
                        std::inserter(removed_ports, removed_ports.begin()));
}

// in case of multithread usage mutex must be locked before calling this function (due to modification openedSerialPorts_)
bool BoardManager::addedSerialPort(const int deviceId) {
    const QString name = serialIdToName_.value(deviceId);

    SerialDeviceShPtr device = std::make_shared<SerialDevice>(deviceId, name);

    if (device->open()) {
        openedSerialPorts_.insert(deviceId, device);

        qCInfo(logCategoryBoardManager).nospace() << "Added new serial device: ID: 0x" << hex << static_cast<uint>(deviceId) << ", name: " << name;

        connect(device.get(), &SerialDevice::deviceReady, this, &BoardManager::boardReady);
        connect(device.get(), &SerialDevice::serialDeviceError, this, &BoardManager::boardError);
        connect(device.get(), &SerialDevice::msgFromDevice, this, &BoardManager::newMessage);

        device->identify(getFwInfo_);

        return true;
    }
    else {
        qCWarning(logCategoryBoardManager).nospace() << "Cannot open serial device: ID: 0x" << hex << static_cast<uint>(deviceId) << ", name: " << name;
        return false;
    }
}

// in case of multithread usage mutex must be locked before calling this function (due to modification openedSerialPorts_)
void BoardManager::removedSerialPort(const int deviceId) {
    auto it = openedSerialPorts_.find(deviceId);
    if (it != openedSerialPorts_.end()) {
        it.value()->close();
        openedSerialPorts_.erase(it);
        qCInfo(logCategoryBoardManager).nospace() << "Removed serial device 0x" << hex << static_cast<uint>(deviceId);
    }
}

void BoardManager::logInvalidDeviceId(const QString& message, const int deviceId) const {
    qCWarning(logCategoryBoardManager).nospace() << message << ", invalid connection ID: 0x" << hex << static_cast<uint>(deviceId);
}

}  // namespace
