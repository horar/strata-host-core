#include "BoardManager.h"
#include "BoardManagerConstants.h"
#include "logging/LoggingQtCategories.h"
#include <SerialDevice.h>
#include <DeviceOperations.h>

#include <QSerialPortInfo>
#include <QMutexLocker>

#include <vector>

namespace strata {

BoardManager::BoardManager() {
    connect(&timer_, &QTimer::timeout, this, &BoardManager::checkNewSerialDevices);
}

BoardManager::~BoardManager() { }

void BoardManager::init(bool requireFwInfoResponse) {
    reqFwInfoResp_ = requireFwInfoResponse;
    timer_.start(DEVICE_CHECK_INTERVAL);
}

// this method is deprecated, it will be deleted
bool BoardManager::sendMessage(const int deviceId, const QString &message) {
    bool sent = false;
    bool deviceFound = false;
    {
        QMutexLocker lock(&mutex_);
        auto it = openedSerialPorts_.constFind(deviceId);
        if (it != openedSerialPorts_.constEnd()) {
            sent = it.value()->sendMessage(message.toUtf8());
            deviceFound = true;
        }
    }
    if (deviceFound == false) {
        logInvalidDeviceId(QStringLiteral("Cannot send message"), deviceId);
    }
    return sent;
}

bool BoardManager::disconnect(const int deviceId) {
    bool success = false;
    {
        QMutexLocker lock(&mutex_);
        auto it = openedSerialPorts_.find(deviceId);
        if (it != openedSerialPorts_.end()) {
            it.value()->close();
            openedSerialPorts_.erase(it);
            success = true;
        }
    }
    if (success) {
        emit boardDisconnected(deviceId);
    } else {
        logInvalidDeviceId(QStringLiteral("Cannot disconnect"), deviceId);
    }
    return success;
}

bool BoardManager::reconnect(const int deviceId) {
    bool ok = false;
    bool disconnected = false;  
    {
        QMutexLocker lock(&mutex_);
        auto it = openedSerialPorts_.find(deviceId);
        if (it != openedSerialPorts_.end()) {
            it.value()->close();
            openedSerialPorts_.erase(it);
            ok = true;
            disconnected = true;
        } else {
            // desired port is not opened, check if it is connected
            if (serialPortsList_.find(deviceId) != serialPortsList_.end()) {
                ok = true;
            }
        }
        if (ok) {
            ok = addSerialPort(deviceId);  // modifies openedSerialPorts_ - call it while mutex_ is locked
        }
    }
    if (disconnected) {
        emit boardDisconnected(deviceId);
    }
    if (ok) {
        emit boardConnected(deviceId);
    } else {
        logInvalidDeviceId(QStringLiteral("Cannot reconnect"), deviceId);
    }
    return ok;
}

SerialDevicePtr BoardManager::device(const int deviceId) {
    QMutexLocker lock(&mutex_);
    auto it = openedSerialPorts_.constFind(deviceId);
    if (it != openedSerialPorts_.constEnd()) {
        return it.value();
    } else {
        return nullptr;
    }
}

// this method is deprecated, it will be deleted
QVariantMap BoardManager::getConnectionInfo(const int deviceId) {
    {
        QMutexLocker lock(&mutex_);
        auto it = openedSerialPorts_.constFind(deviceId);
        if (it != openedSerialPorts_.constEnd()) {
            return it.value()->getDeviceInfo();
        }
    }
    logInvalidDeviceId(QStringLiteral("Cannot get connection info"), deviceId);
    return QVariantMap();
}

QVector<int> BoardManager::readyDeviceIds() {
    QMutexLocker lock(&mutex_);
    return QVector<int>::fromList(openedSerialPorts_.keys());
}

// this method is deprecated, it will be deleted
QString BoardManager::getDeviceProperty(const int deviceId, const DeviceProperties property) {
    {
        QMutexLocker lock(&mutex_);
        auto it = openedSerialPorts_.constFind(deviceId);
        if (it != openedSerialPorts_.constEnd()) {
            return it.value()->property(property);
        }
    }
    logInvalidDeviceId(QStringLiteral("Cannot get required device property"), deviceId);
    return QString();
}

void BoardManager::checkNewSerialDevices() {
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
    std::set<int> ports;
    QHash<int, QString> idToName;

    for (const QSerialPortInfo& serialPortInfo : serialPortInfos) {
        const QString& name = serialPortInfo.portName();

        if (serialPortInfo.isNull()) {
            continue;
        }
        if (name.contains(usbKeyword) == false) {
            continue;
        }
#ifdef Q_OS_MACOS
        if (name.startsWith(cuKeyword) == false) {
            continue;
        }
#endif
        // device ID must be int because of integration with QML
        int deviceId = static_cast<int>(qHash(name));
        auto [iter, success] = ports.emplace(deviceId);
        if (success == false) {
            // Error: hash already exists!
            qCCritical(logCategoryBoardManager).nospace() << "Cannot add device (hash conflict: 0x" << hex << static_cast<uint>(deviceId) << "): " << name;
            continue;
        }
        idToName.insert(deviceId, name);

        // qCDebug(logCategoryBoardManager).nospace() << "Found serial device, ID: 0x" << hex << static_cast<uint>(deviceId) << ", name: " << name;
    }

    std::set<int> added, removed;
    std::vector<int> opened, deleted;
    opened.reserve(added.size());

    {  // this block of code modifies serialPortsList_, openedSerialPorts_, serialIdToName_
        QMutexLocker lock(&mutex_);

        serialIdToName_ = std::move(idToName);

        computeListDiff(ports, added, removed);  // uses serialPortsList_ (needs old value from previous run)

        // Do not emit boardDisconnected and boardConnected signals in this locked block of code.
        for (auto deviceId : removed) {
            if (removeSerialPort(deviceId)) {  // modifies openedSerialPorts_
                deleted.emplace_back(deviceId);
            }
        }

        for (auto deviceId : added) {
            if (addSerialPort(deviceId)) {  // modifies openedSerialPorts_, uses serialIdToName_
                opened.emplace_back(deviceId);
            }
        }

        serialPortsList_ = std::move(ports);
    }

    if (deleted.empty() == false || opened.empty() == false) {
        for (auto deviceId : deleted) {
            emit boardDisconnected(deviceId);
        }
        for (auto deviceId : opened) {
            emit boardConnected(deviceId);
        }
        emit readyDeviceIdsChanged();
    }
}

// mutex_ must be locked before calling this function (due to accessing serialPortsList_)
void BoardManager::computeListDiff(std::set<int>& list, std::set<int>& added_ports, std::set<int>& removed_ports) {
    //create differences of the lists.. what is added / removed
    std::set_difference(list.begin(), list.end(),
                        serialPortsList_.begin(), serialPortsList_.end(),
                        std::inserter(added_ports, added_ports.begin()));

    std::set_difference(serialPortsList_.begin(), serialPortsList_.end(),
                        list.begin(), list.end(),
                        std::inserter(removed_ports, removed_ports.begin()));
}

// mutex_ must be locked before calling this function (due to modification openedSerialPorts_ and using serialIdToName_)
bool BoardManager::addSerialPort(const int deviceId) {
    const QString name = serialIdToName_.value(deviceId);

    SerialDevicePtr device = std::make_shared<SerialDevice>(deviceId, name);

    if (device->open()) {
        openedSerialPorts_.insert(deviceId, device);

        qCInfo(logCategoryBoardManager).nospace() << "Added new serial device: ID: 0x" << hex << static_cast<uint>(deviceId) << ", name: " << name;

        connect(device.get(), &SerialDevice::msgFromDevice, this, &BoardManager::handleNewMessage);  // DEPRECATED
        connect(device.get(), &SerialDevice::serialDeviceError, this, &BoardManager::handleSerialDeviceError);

        // QSharedPointer because QScopedPointer does not have custom deleter.
        // We need deleteLater() because DeviceOperations object is deleted in slot connected to signal from it.
        auto operation = QSharedPointer<DeviceOperations>(new DeviceOperations(device), &QObject::deleteLater);

        connect(operation.get(), &DeviceOperations::finished, this, &BoardManager::handleOperationFinished);
        connect(operation.get(), &DeviceOperations::error, this, &BoardManager::handleOperationError);

        operation->identify(reqFwInfoResp_);

        serialDeviceOperations_.insert(deviceId, operation);

        return true;
    } else {
        qCWarning(logCategoryBoardManager).nospace() << "Cannot open serial device: ID: 0x" << hex << static_cast<uint>(deviceId) << ", name: " << name;
        return false;
    }
}

// mutex_ must be locked before calling this function (due to modification openedSerialPorts_)
bool BoardManager::removeSerialPort(const int deviceId) {
    serialDeviceOperations_.remove(deviceId);
    auto it = openedSerialPorts_.find(deviceId);
    if (it != openedSerialPorts_.end()) {
        it.value()->close();
        openedSerialPorts_.erase(it);
        qCInfo(logCategoryBoardManager).nospace() << "Removed serial device 0x" << hex << static_cast<uint>(deviceId);
        return true;
    } else {
        return false;
    }
}

void BoardManager::logInvalidDeviceId(const QString& message, const int deviceId) const {
    qCWarning(logCategoryBoardManager).nospace() << message << ", invalid device ID: 0x" << hex << static_cast<uint>(deviceId);
}

void BoardManager::handleOperationFinished(int operation, int) {
    DeviceOperations *devOp = qobject_cast<DeviceOperations*>(QObject::sender());
    if (devOp == nullptr) {
        return;
    }

    int deviceId = devOp->deviceId();
    bool boardRecognized = false;
    if (operation == static_cast<int>(DeviceOperations::Operation::Identify)) {
        boardRecognized = true;
    }

    // operation has finished, we do not need DeviceOperations object anymore
    serialDeviceOperations_.remove(deviceId);

    emit boardReady(deviceId, boardRecognized);
}

void BoardManager::handleOperationError(QString errMsg) {
    DeviceOperations *devOp = qobject_cast<DeviceOperations*>(QObject::sender());
    if (devOp == nullptr) {
        return;
    }
    int deviceId = devOp->deviceId();
    // operation has finished with error, we do not need DeviceOperations object anymore
    serialDeviceOperations_.remove(deviceId);

    emit boardError(deviceId, errMsg);
}

// this slot is deprecated, it will be deleted
void BoardManager::handleNewMessage(QString message) {
    SerialDevice *device = qobject_cast<SerialDevice*>(QObject::sender());
    if (device == nullptr) {
        return;
    }
    emit newMessage(device->deviceId(), message);
}

void BoardManager::handleSerialDeviceError(SerialDevice::ErrorCode errCode, QString errStr) {
    Q_UNUSED(errStr)
    SerialDevice *sDevice = qobject_cast<SerialDevice*>(QObject::sender());
    if (sDevice == nullptr) {
        return;
    }
    // if device is unexpectedly disconnected remove it
    if (errCode == SerialDevice::ErrorCode::SP_ResourceError) {
        int deviceId = sDevice->deviceId();
        qCWarning(logCategoryBoardManager).nospace() << "Interrupted connection with device 0x" << hex << static_cast<uint>(deviceId);
        QTimer::singleShot(0, this, [this, deviceId](){
            bool removed = false;
            {
                QMutexLocker lock(&mutex_);
                removed = removeSerialPort(deviceId);  // modifies openedSerialPorts_ - call it while mutex_ is locked
            }
            if (removed) {
                emit boardDisconnected(deviceId);
            }
        });
    }
}

}  // namespace
