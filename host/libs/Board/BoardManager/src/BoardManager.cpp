#include "BoardManager.h"
#include "BoardManagerConstants.h"
#include "logging/LoggingQtCategories.h"
#include <Device/Serial/SerialDevice.h>
#include <Device/Operations/Identify.h>

#include <QSerialPortInfo>
#include <QMutexLocker>

#include <vector>

namespace strata {

using device::Device;
using device::DevicePtr;

namespace operation = device::operation;

BoardManager::BoardManager() {
    connect(&timer_, &QTimer::timeout, this, &BoardManager::checkNewSerialDevices);
}

BoardManager::~BoardManager() { }

void BoardManager::init(bool requireFwInfoResponse) {
    reqFwInfoResp_ = requireFwInfoResponse;
    timer_.start(DEVICE_CHECK_INTERVAL);
}

bool BoardManager::disconnect(const int deviceId) {
    bool success = false;
    {
        QMutexLocker lock(&mutex_);
        auto it = openedDevices_.find(deviceId);
        if (it != openedDevices_.end()) {
            it.value()->close();
            openedDevices_.erase(it);
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
        auto it = openedDevices_.find(deviceId);
        if (it != openedDevices_.end()) {
            it.value()->close();
            openedDevices_.erase(it);
            ok = true;
            disconnected = true;
        } else {
            // desired port is not opened, check if it is connected
            if (serialPortsList_.find(deviceId) != serialPortsList_.end()) {
                ok = true;
            }
        }
        if (ok) {
            ok = addSerialPort(deviceId);  // modifies openedDevices_ - call it while mutex_ is locked
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

DevicePtr BoardManager::device(const int deviceId) {
    QMutexLocker lock(&mutex_);
    auto it = openedDevices_.constFind(deviceId);
    if (it != openedDevices_.constEnd()) {
        return it.value();
    } else {
        return nullptr;
    }
}

QVector<int> BoardManager::readyDeviceIds() {
    QMutexLocker lock(&mutex_);
    return QVector<int>::fromList(openedDevices_.keys());
}

void BoardManager::checkNewSerialDevices() { //TODO refactoring, take serial port functionality out from this class
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

    {  // this block of code modifies serialPortsList_, openedDevices_, serialIdToName_
        QMutexLocker lock(&mutex_);

        serialIdToName_ = std::move(idToName);

        computeListDiff(ports, added, removed);  // uses serialPortsList_ (needs old value from previous run)

        // Do not emit boardDisconnected and boardConnected signals in this locked block of code.
        for (auto deviceId : removed) {
            if (closeDevice(deviceId)) {  // modifies openedDevices_
                deleted.emplace_back(deviceId);
            }
        }

        for (auto deviceId : added) {
            if (addSerialPort(deviceId)) {  // modifies openedDevices_, uses serialIdToName_
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

// mutex_ must be locked before calling this function (due to modification openedDevices_ and using serialIdToName_)
bool BoardManager::addSerialPort(const int deviceId) {
    // 1. construct the serial device
    // 2. open the device
    // 3. attach DeviceOperations object

    const QString name = serialIdToName_.value(deviceId);

    DevicePtr device = std::make_shared<device::serial::SerialDevice>(deviceId, name);

    if (openDevice(deviceId, device) == false) {
        qCWarning(logCategoryBoardManager).nospace()
            << "Cannot open device: ID: 0x" << hex << static_cast<uint>(deviceId)
            << ", name: " << name;
        return false;
    }
    qCInfo(logCategoryBoardManager).nospace() << "Added new serial device: ID: 0x" << hex
                                              << static_cast<uint>(deviceId) << ", name: " << name;
    startDeviceOperations(deviceId, device);
    return true;
}

// mutex_ must be locked before calling this function (due to modification openedDevices_)
bool BoardManager::openDevice(const int deviceId, const DevicePtr device) {
    if (device->open() == false) {
        return false;
    }
    openedDevices_.insert(deviceId, device);

    connect(device.get(), &Device::deviceError, this, &BoardManager::handleDeviceError);

    return true;
}

// mutex_ must be locked before calling this function (due to modification deviceOperations_)
void BoardManager::startDeviceOperations(const int deviceId, const DevicePtr device) {
    // shared_ptr because QHash::insert() calls copy constructor (unique_ptr has deleted copy constructor)
    // We need deleteLater() because DeviceOperations object is deleted
    // in slot connected to signal from it (BoardManager::handleOperationFinished).
    std::shared_ptr<operation::BaseDeviceOperation> operation (
        new operation::Identify(device, reqFwInfoResp_),
        [](operation::BaseDeviceOperation* baseOp) { baseOp->deleteLater(); }
    );

    connect(operation.get(), &operation::BaseDeviceOperation::finished, this, &BoardManager::handleOperationFinished);
    connect(operation.get(), &operation::BaseDeviceOperation::error, this, &BoardManager::handleOperationError);

    device::operation::Identify *identify = dynamic_cast<device::operation::Identify*>(operation.get());
    identify->runWithDelay(IDENTIFY_LAUNCH_DELAY);  // Some boards need time for booting

    deviceOperations_.insert(deviceId, operation);
}

// mutex_ must be locked before calling this function (due to modification openedDevices_)
bool BoardManager::closeDevice(const int deviceId) {
    deviceOperations_.remove(deviceId);
    auto it = openedDevices_.find(deviceId);
    if (it != openedDevices_.end()) {
        it.value()->close();
        openedDevices_.erase(it);
        qCInfo(logCategoryBoardManager).nospace() << "Removed serial device 0x" << hex << static_cast<uint>(deviceId);
        return true;
    } else {
        return false;
    }
}

void BoardManager::logInvalidDeviceId(const QString& message, const int deviceId) const {
    qCWarning(logCategoryBoardManager).nospace() << message << ", invalid device ID: 0x" << hex << static_cast<uint>(deviceId);
}

void BoardManager::handleOperationFinished(operation::Type opType, int) {
    operation::BaseDeviceOperation *baseOp = qobject_cast<operation::BaseDeviceOperation*>(QObject::sender());
    if (baseOp == nullptr) {
        return;
    }

    int deviceId = baseOp->deviceId();
    bool boardRecognized = false;
    if (opType == operation::Type::Identify) {
        boardRecognized = true;
    }

    // operation has finished, we do not need DeviceOperations object anymore
    deviceOperations_.remove(deviceId);

    emit boardReady(deviceId, boardRecognized);
}

void BoardManager::handleOperationError(QString errMsg) {
    operation::BaseDeviceOperation *baseOp = qobject_cast<operation::BaseDeviceOperation*>(QObject::sender());
    if (baseOp == nullptr) {
        return;
    }
    int deviceId = baseOp->deviceId();
    // operation has finished with error, we do not need DeviceOperations object anymore
    deviceOperations_.remove(deviceId);

    emit boardError(deviceId, errMsg);
}

void BoardManager::handleDeviceError(Device::ErrorCode errCode, QString errStr) {
    Q_UNUSED(errStr)
    Device *device = qobject_cast<Device*>(QObject::sender());
    if (device == nullptr) {
        return;
    }
    // if serial device is unexpectedly disconnected, remove it
    if (errCode == Device::ErrorCode::SP_ResourceError) {
        int deviceId = device->deviceId();
        qCWarning(logCategoryBoardManager).nospace() << "Interrupted connection with device 0x" << hex << static_cast<uint>(deviceId);
        // Device cannot be removed in this slot (this slot is connected to signal emitted by device).
        // Remove it (and emit 'disconnected' signal) after return to main loop (when signal handling
        // is done and other slots connected to this signal are also done) - this is why is used single shot timer.
        QTimer::singleShot(0, this, [this, deviceId](){
            bool removed = false;
            {
                QMutexLocker lock(&mutex_);
                removed = closeDevice(deviceId);  // modifies openedDevices_ - call it while mutex_ is locked
            }
            if (removed) {
                emit boardDisconnected(deviceId);
            }
        });
    }
}

}  // namespace
