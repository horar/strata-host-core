#include "PlatformManager.h"
#include "PlatformManagerConstants.h"

#include "logging/LoggingQtCategories.h"

#include <Serial/SerialDevice.h>
#include <Operations/Identify.h>

#include <CommandValidator.h>

#include <QSerialPortInfo>
#include <QMutexLocker>

#include <rapidjson/document.h>
#include <rapidjson/schema.h>

#include <vector>

namespace strata {

using device::Device;
using device::DevicePtr;
using device::SerialDevice;
using platform::Platform;
using platform::PlatformPtr;

namespace operation = platform::operation;

PlatformManager::PlatformManager() : platformOperations_(true, true) {
    // checkNewSerialDevices() slot uses mutex_
    connect(&timer_, &QTimer::timeout, this, &PlatformManager::checkNewSerialDevices, Qt::QueuedConnection);
    // handlePlatformIdChanged() slot uses mutex_
    connect(this, &PlatformManager::platformIdChanged, this, &PlatformManager::handlePlatformIdChanged, Qt::QueuedConnection);

    connect(&platformOperations_, &operation::PlatformOperations::finished, this, &PlatformManager::handleOperationFinished);
}

PlatformManager::~PlatformManager() { }

void PlatformManager::init(bool requireFwInfoResponse, bool keepDevicesOpen) {
    reqFwInfoResp_ = requireFwInfoResponse;
    keepDevicesOpen_ = keepDevicesOpen;
    timer_.start(DEVICE_CHECK_INTERVAL);
}

bool PlatformManager::disconnectDevice(const QByteArray& deviceId, std::chrono::milliseconds disconnectDuration) {
    bool success = false;
    {
        QMutexLocker lock(&mutex_);
        auto it = openedPlatforms_.find(deviceId);
        if (it != openedPlatforms_.end()) {
            it.value()->close();
            openedPlatforms_.erase(it);

            if (disconnectDuration > std::chrono::milliseconds(0)) {
                QTimer* reconnectTimer = new QTimer(this);
                reconnectTimers_.insert(deviceId, reconnectTimer);
                reconnectTimer->setSingleShot(true);
                reconnectTimer->callOnTimeout(this, [this, deviceId, reconnectTimer](){
                    QMutexLocker lock(&mutex_);
                    reconnectTimer->deleteLater();
                    reconnectTimers_.remove(deviceId);
                    // Remove serial port from list of known ports, device will be
                    // added (reconnected) in next round of scaning serial ports.
                    serialPortsList_.erase(deviceId);
                });
                reconnectTimer->start(disconnectDuration);
            }

            success = true;
        }
    }
    if (success) {
        qCInfo(logCategoryPlatformManager).noquote() << "Disconnected platform" << deviceId;
        if (disconnectDuration > std::chrono::milliseconds(0)) {
            qCInfo(logCategoryPlatformManager) << "Device will be connected again after" << disconnectDuration.count()
                                            << "milliseconds at the earliest.";
        }
        emit boardDisconnected(deviceId);
    } else {
        logInvalidDeviceId(QStringLiteral("Cannot disconnect"), deviceId);
    }
    return success;
}

bool PlatformManager::reconnectDevice(const QByteArray& deviceId) {
    bool ok = false;
    bool disconnected = false;
    {
        QMutexLocker lock(&mutex_);
        auto it = openedPlatforms_.find(deviceId);
        if (it != openedPlatforms_.end()) {
            it.value()->close();
            openedPlatforms_.erase(it);
            ok = true;
            disconnected = true;
        } else {
            // desired port is not opened, check if it is connected
            if (serialPortsList_.find(deviceId) != serialPortsList_.end()) {
                ok = true;
            }
        }
        if (ok) {
            ok = addSerialPort(deviceId);  // modifies openedPlatforms_ - call it while mutex_ is locked
        }
    }
    if (disconnected) {
        emit boardDisconnected(deviceId);
    }
    if (ok) {
        qCInfo(logCategoryPlatformManager).noquote() << "Reconnected platform" << deviceId;
        emit boardConnected(deviceId);
    } else {
        logInvalidDeviceId(QStringLiteral("Cannot reconnect"), deviceId);
    }
    return ok;
}

PlatformPtr PlatformManager::platform(const QByteArray& deviceId) {
    QMutexLocker lock(&mutex_);
    auto it = openedPlatforms_.constFind(deviceId);
    if (it != openedPlatforms_.constEnd()) {
        return it.value();
    } else {
        return nullptr;
    }
}

QVector<QByteArray> PlatformManager::activeDeviceIds() {
    QMutexLocker lock(&mutex_);
    return QVector<QByteArray>::fromList(openedPlatforms_.keys());
}

void PlatformManager::checkNewSerialDevices() {
    // TODO refactoring, take serial port functionality out from this class
    // or make another check function for bluetooth devices when it will be needed
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
    std::set<QByteArray> ports;
    QHash<QByteArray, QString> idToName;

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
        const QByteArray deviceId = SerialDevice::createDeviceId(name);
        auto [iter, success] = ports.emplace(deviceId);
        if (success == false) {
            // Error: hash already exists!
            qCCritical(logCategoryPlatformManager).nospace().noquote()
                << "Cannot add platform (hash conflict: " << deviceId << "): '" << name << "'";
            continue;
        }
        idToName.insert(deviceId, name);

        // qCDebug(logCategoryPlatformManager).nospace().noquote() << "Found platform, ID: " << deviceId << ", name: '" << name << "'";
    }

    std::set<QByteArray> added, removed;
    std::vector<QByteArray> opened, deleted;

    {  // this block of code modifies serialPortsList_, openedPlatforms_, serialIdToName_
        QMutexLocker lock(&mutex_);

        serialIdToName_ = std::move(idToName);

        computeListDiff(ports, added, removed);  // uses serialPortsList_ (needs old value from previous run)

        // Do not emit boardDisconnected and boardConnected signals in this locked block of code.
        for (const auto& deviceId : removed) {
            if (removePlatform(deviceId)) {  // modifies openedPlatforms_ and reconnectTimers_
                deleted.emplace_back(deviceId);
            }
        }

        for (const auto& deviceId : added) {
            if (addSerialPort(deviceId)) {  // modifies openedPlatforms_, uses serialIdToName_
                opened.emplace_back(deviceId);
            } else {
                // If serial port cannot be opened (for example it is hold by another application),
                // remove it from list of known ports. There will be another attempt to open it in next round.
                ports.erase(deviceId);
            }
        }

        serialPortsList_ = std::move(ports);
    }

    for (const auto& deviceId : deleted) {
        emit boardDisconnected(deviceId);
    }
    for (const auto& deviceId : opened) {
        emit boardConnected(deviceId);
    }
}

// mutex_ must be locked before calling this function (due to accessing serialPortsList_)
void PlatformManager::computeListDiff(std::set<QByteArray>& list, std::set<QByteArray>& added_ports, std::set<QByteArray>& removed_ports) {
    //create differences of the lists.. what is added / removed
    std::set_difference(list.begin(), list.end(),
                        serialPortsList_.begin(), serialPortsList_.end(),
                        std::inserter(added_ports, added_ports.begin()));

    std::set_difference(serialPortsList_.begin(), serialPortsList_.end(),
                        list.begin(), list.end(),
                        std::inserter(removed_ports, removed_ports.begin()));
}

// mutex_ must be locked before calling this function (due to modification openedPlatforms_ and using serialIdToName_)
bool PlatformManager::addSerialPort(const QByteArray& deviceId) {
    // 1. construct the serial device
    // 2. wrap with platform
    // 3. open the device
    // 4. attach PlatformOperations object

    const QString name = serialIdToName_.value(deviceId);

    SerialDevice::SerialPortPtr serialPort = SerialDevice::establishPort(name);

    if (serialPort == nullptr) {
        qCInfo(logCategoryPlatformManager).nospace().noquote()
            << "Port for device: ID: " << deviceId << ", name: '" << name
            << "' cannot be open, it is probably hold by another application.";
        return false;
    }

    DevicePtr device = std::make_shared<SerialDevice>(deviceId, name, std::move(serialPort));
    platform::PlatformPtr platform = std::make_shared<platform::Platform>(device);

    if (openPlatform(platform) == false) {
        qCWarning(logCategoryPlatformManager).nospace().noquote()
            << "Cannot open serial device: ID: " << deviceId << ", name: '" << name << "'";
        return false;
    }

    qCInfo(logCategoryPlatformManager).nospace().noquote()
        << "Added new serial device: ID: " << deviceId << ", name: '" << name << "'";
    startPlatformOperations(platform);
    return true;
}

// mutex_ must be locked before calling this function (due to modification openedPlatforms_)
bool PlatformManager::openPlatform(const platform::PlatformPtr newPlatform) {
    if (newPlatform->open() == false) {
        return false;
    }
    openedPlatforms_.insert(newPlatform->deviceId(), newPlatform);

    connect(newPlatform.get(), &Platform::deviceError, this, &PlatformManager::handleDeviceError);

    return true;
}

void PlatformManager::startPlatformOperations(const PlatformPtr platform) {
    connect(platform.get(), &Platform::messageReceived, this, &PlatformManager::checkNotification);

    platformOperations_.Identify(platform, reqFwInfoResp_, GET_FW_INFO_MAX_RETRIES, IDENTIFY_LAUNCH_DELAY);
}

// mutex_ must be locked before calling this function (due to modification openedPlatforms_ and reconnectTimers_)
bool PlatformManager::removePlatform(const QByteArray& deviceId) {
    platformOperations_.stopOperation(deviceId);

    // If platform is physically disconnected, remove reconnect timer (if exists).
    auto timerIter = reconnectTimers_.find(deviceId);
    if (timerIter != reconnectTimers_.end()) {
        QTimer* reconnectTimer = timerIter.value();
        reconnectTimer->stop();
        delete reconnectTimer;
        reconnectTimers_.erase(timerIter);
        qCInfo(logCategoryPlatformManager).noquote() << "Removed timer for reconnecting platform" << deviceId;
    }

    auto deviceIter = openedPlatforms_.find(deviceId);
    if (deviceIter != openedPlatforms_.end()) {
        deviceIter.value()->close();
        openedPlatforms_.erase(deviceIter);
        qCInfo(logCategoryPlatformManager).noquote() << "Removed platform" << deviceId;
        return true;
    } else {
        return false;
    }
}

void PlatformManager::logInvalidDeviceId(const QString& message, const QByteArray& deviceId) const {
    qCWarning(logCategoryPlatformManager).nospace().noquote() << message << ", invalid platform ID: " << deviceId;
}

void PlatformManager::handleOperationFinished(QByteArray deviceId, operation::Type type, operation::Result result, int status, QString errStr) {
    Q_UNUSED(status)

    if (result == operation::Result::Error) {
        emit boardError(deviceId, errStr);
    }

    // If identify operation is cancelled, another identify operation will be started soon.
    // So there is no need for emitting boardInfoChanged signal. (See handlePlatformIdChanged() function.)
    if ((type == operation::Type::Identify) && (result != operation::Result::Cancel)) {
        bool boardRecognized = (result == operation::Result::Success);
        emit boardInfoChanged(deviceId, boardRecognized);
        if (boardRecognized == false && keepDevicesOpen_ == false) {
            qCInfo(logCategoryPlatformManager).noquote()
                << "Device" << deviceId << "was not recognized, going to release communication channel.";
            // Device cannot be removed in this slot (this slot is connected to signal emitted by platform).
            // Remove it (and emit 'disconnected' signal) after return to main loop (when signal handling
            // is done and other slots connected to this signal are also done) - this is why is used single shot timer.
            QTimer::singleShot(0, this, [this, deviceId](){
                disconnectDevice(deviceId);
            });
        }
    }
}

void PlatformManager::handleDeviceError(Device::ErrorCode errCode, QString errStr) {
    Q_UNUSED(errStr)
    Platform *platform = qobject_cast<Platform*>(QObject::sender());
    if (platform == nullptr) {
        return;
    }
    // if platform is unexpectedly disconnected, remove it
    if (errCode == Device::ErrorCode::DeviceDisconnected) {
        disconnect(platform, &Platform::messageReceived, this, &PlatformManager::checkNotification);
        const QByteArray deviceId = platform->deviceId();
        qCWarning(logCategoryPlatformManager).noquote() << "Interrupted connection with platform" << deviceId;

        // Device cannot be removed in this slot (this slot is connected to signal emitted by platform).
        // Remove it (and emit 'disconnected' signal) after return to main loop (when signal handling
        // is done and other slots connected to this signal are also done) - this is why is used single shot timer.
        QTimer::singleShot(0, this, [this, deviceId](){
            disconnectDevice(deviceId);
        });
    }
}

const rapidjson::SchemaDocument platformIdChangedSchema(
    CommandValidator::parseSchema(
R"(
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "type": "object",
  "properties": {
    "notification": {
      "type": "object",
      "properties": {
        "value": {"type": "string", "pattern": "^platform_id_changed$"}
      },
      "required": ["value"]
    }
  },
  "required": ["notification"]
}
)"
    )
);

void PlatformManager::checkNotification(QByteArray message) {
    Platform *platform = qobject_cast<Platform*>(QObject::sender());
    if (platform == nullptr) {
        return;
    }

    rapidjson::Document doc;
    if (CommandValidator::parseJsonCommand(message, doc, true) == false) {
        return;
    }
    if (CommandValidator::validateJsonWithSchema(platformIdChangedSchema, doc, true) == false) {
        return;
    }

    qCInfo(logCategoryPlatformManager).noquote()
        << "Received 'platform_id_changed' notification for platform" << platform->deviceId();

    emit platformIdChanged(platform->deviceId(), QPrivateSignal());
}

void PlatformManager::handlePlatformIdChanged(const QByteArray& deviceId) {
    // method platform() uses mutex_
    PlatformPtr platform = this->platform(deviceId);
    if (platform == nullptr) {
        return;
    }

    platformOperations_.Identify(platform, reqFwInfoResp_, GET_FW_INFO_MAX_RETRIES, IDENTIFY_LAUNCH_DELAY);
}

}  // namespace
