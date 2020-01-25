#include "BoardManager.h"
#include "SerialDevice.h"
#include "BoardManagerConstants.h"
#include "logging/LoggingQtCategories.h"

#include <QSerialPortInfo>


namespace spyglass {

BoardManager::BoardManager() {
    connect(&timer_, &QTimer::timeout, this, &BoardManager::checkNewSerialDevices);
}

void BoardManager::init() {
    timer_.start(DEVICE_CHECK_INTERVAL);
}

void BoardManager::sendMessage(const int connectionId, const QString &message) {
    auto it = openedSerialPorts_.constFind(connectionId);
    if (it != openedSerialPorts_.constEnd()) {
        it.value()->write(message.toUtf8());
    }
    else {
        qCWarning(logCategoryBoardManager).nospace() << "Cannot send message, invalid connection ID: 0x" << hex << static_cast<uint>(connectionId);
        emit invalidOperation(connectionId);
    }
}

void BoardManager::disconnect(const int connectionId) {
    auto it = openedSerialPorts_.find(connectionId);
    if (it != openedSerialPorts_.end()) {
        it.value()->close();
        it.value().reset();
        openedSerialPorts_.erase(it);

        emit boardDisconnected(connectionId);
    }
    else {
        qCWarning(logCategoryBoardManager).nospace() << "Cannot send disconnect, invalid connection ID: 0x" << hex << static_cast<uint>(connectionId);
        emit invalidOperation(connectionId);
    }
}

void BoardManager::reconnect(const int connectionId) {
    bool ok = false;
    auto it = openedSerialPorts_.find(connectionId);
    if (it != openedSerialPorts_.end()) {
        it.value()->close();
        it.value().reset();
        openedSerialPorts_.erase(it);
        ok = true;
    }
    else {
        // desired port is not opened, check if it is connected
        if (serialPortsList_.find(connectionId) != serialPortsList_.end()) {
            ok = true;
        }
    }
    if (ok) {
        addedSerialPort(connectionId);
    }
    else {
        qCWarning(logCategoryBoardManager).nospace() << "Cannot send reconnect, invalid connection ID: 0x" << hex << static_cast<uint>(connectionId);
        emit invalidOperation(connectionId);
    }
}

QVariantMap BoardManager::getConnectionInfo(const int connectionId) {
    auto it = openedSerialPorts_.constFind(connectionId);
    if (it != openedSerialPorts_.constEnd()) {
        return it.value()->getDeviceInfo();
    }
    else {
        qCWarning(logCategoryBoardManager).nospace() << "Cannot get connection info, invalid connection ID: 0x" << hex << static_cast<uint>(connectionId);
        emit invalidOperation(connectionId);
        return QVariantMap();
    }
}

QVector<int> BoardManager::readyConnectionIds() {
    return QVector<int>::fromList(openedSerialPorts_.keys());
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

    for (const QSerialPortInfo &serialPortInfo : serialPortInfos) {
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
        int connectionId = static_cast<int>(qHash(name));
        auto [iter, success] = ports.emplace(connectionId);
        if (success == false) {
            // Error: hash already exists!
            qCCritical(logCategoryBoardManager).nospace() << "Cannot add device (hash conflict: 0x" << hex << static_cast<uint>(connectionId) << "): " << name;
            continue;
        }
        id_to_name.insert(connectionId, name);

        // qCDebug(logCategoryBoardManager).nospace() << "Found serial device, ID: 0x" << hex << static_cast<uint>(connectionId) << ", name: " << name;
    }

    std::set<int> added, removed;
    std::vector<int> opened;
    opened.reserve(added.size());

    // in case of multithread usage lock this block of code (see comment in *.h file)
    {  // this block of code modifies serialPortsList_, openedSerialPorts_, serialIdToName_

        serialIdToName_ = std::move(id_to_name);

        computeListDiff(ports, added, removed);  // uses serialPortsList_ (needs old value from previous run)

        for (auto connectionId : removed) {
            removedSerialPort(connectionId);  // modifies openedSerialPorts_
            emit boardDisconnected(connectionId);  // if this block of code is locked emit this after end of the block
        }

        for (auto connectionId : added) {
            if (addedSerialPort(connectionId)) {  // modifies openedSerialPorts_, uses serialIdToName_
                opened.emplace_back(connectionId);
                emit boardConnected(connectionId);  // if this block of code is locked emit this after end of the block
            }
        }

        serialPortsList_ = std::move(ports);
    }

    if (opened.empty() == false || removed.empty() == false) {
        // in case of multithread usage emit signals here (iterate over 'removed' and 'opened' containers)

        emit connectionIdsChanged();
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
bool BoardManager::addedSerialPort(const int connectionId) {
    const QString name = serialIdToName_.value(connectionId);

    SerialDeviceShPtr device = std::make_shared<SerialDevice>(connectionId, name);

    if (device->open()) {
        openedSerialPorts_.insert(connectionId, device);

        qCInfo(logCategoryBoardManager).nospace() << "Added new serial device: ID: 0x" << hex << static_cast<uint>(connectionId) << ", name: " << name;

        connect(device.get(), &SerialDevice::deviceReady, this, &BoardManager::boardReady);
        connect(device.get(), &SerialDevice::serialDeviceError, this, &BoardManager::boardError);
        connect(device.get(), &SerialDevice::msgFromDevice, this, &BoardManager::newMessage);

        device->launchDevice();

        return true;
    }
    else {
        qCWarning(logCategoryBoardManager).nospace() << "Cannot open serial device: ID: 0x" << hex << static_cast<uint>(connectionId) << ", name: " << name;
        return false;
    }
}

// in case of multithread usage mutex must be locked before calling this function (due to modification openedSerialPorts_)
void BoardManager::removedSerialPort(const int connectionId) {
    auto it = openedSerialPorts_.find(connectionId);
    if (it != openedSerialPorts_.end()) {
        it.value()->close();
        it.value().reset();
        openedSerialPorts_.erase(it);

        qCInfo(logCategoryBoardManager).nospace() << "Removed serial device 0x" << hex << static_cast<uint>(connectionId);
    }
}

}  // namespace
