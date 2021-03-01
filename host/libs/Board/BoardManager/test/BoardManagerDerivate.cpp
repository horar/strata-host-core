#include "BoardManagerDerivate.h"
#include <Device/Mock/MockDevice.h>
#include "QtTest.h"

using strata::BoardManager;
using strata::device::Device;
using strata::device::DevicePtr;

BoardManagerDerivate::BoardManagerDerivate() : BoardManager()
{
}

void BoardManagerDerivate::init(bool requireFwInfoResponse, bool keepDevicesOpen)
{
    reqFwInfoResp_ = requireFwInfoResponse;
    keepDevicesOpen_ = keepDevicesOpen;
}

bool BoardManagerDerivate::addNewMockDevice(const int deviceId, const QString deviceName)
{
    qDebug().nospace() << "Adding new mock device (0x" << hex << static_cast<uint>(deviceId) << "): " << deviceName;
    std::set<int> ports(serialPortsList_);
    QHash<int, QString> idToName(serialIdToName_);

    {
        // device ID must be int because of integration with QML
        auto [iter, success] = ports.emplace(deviceId);
        if (success == false) {
            // Error: hash already exists!
            qCritical().nospace() << "Cannot add device (hash conflict: 0x" << hex << static_cast<uint>(deviceId) << "): " << deviceName;
            QFAIL_("deviceId already exists");
            return false;
        } else {
            idToName.insert(deviceId, deviceName);
        }
    }

    std::set<int> added, removed;
    std::vector<int> opened, deleted;
    opened.reserve(added.size());

    {  // this block of code modifies serialPortsList_, openedDevices_, serialIdToName_
        QMutexLocker lock(&mutex_);

        serialIdToName_ = std::move(idToName);

        computeListDiff(ports, added, removed); // uses serialPortsList_ (needs old value from previous run)

        // Do not emit boardDisconnected and boardConnected signals in this locked block of code.
        for (auto removedDeviceId : removed) {
            if (removeDevice(removedDeviceId)) {        // modifies openedDevices_ and reconnectTimers_
                deleted.emplace_back(removedDeviceId);
            }
        }

        for (auto addedDeviceId : added) {
            if (addMockPort(addedDeviceId, false)) {    // modifies openedDevices_, uses serialIdToName_
                opened.emplace_back(addedDeviceId);
            } else {
                // If mock port cannot be opened remove it from list of known ports.
                ports.erase(addedDeviceId);
            }
        }

        serialPortsList_ = std::move(ports);
    }

    for (auto deletedDeviceId : deleted) {
        emit boardDisconnected(deletedDeviceId);
    }
    for (auto openedDeviceId : opened) {
        emit boardConnected(openedDeviceId);
    }
    return true;
}

bool BoardManagerDerivate::removeMockDevice(const int deviceId)
{
    bool res = true;
    // call after disconnecting
    auto serialPortsListIt = serialPortsList_.find(deviceId);
    if (serialPortsListIt != serialPortsList_.end()) {
        serialPortsList_.erase(serialPortsListIt);
    } else {
        qWarning().nospace() << "Unable to locate serialPortsList_ entry for 0x"
                             << hex << static_cast<uint>(deviceId);
        res = false;
    }

    auto serialIdToNameIt = serialIdToName_.find(deviceId);
    if (serialIdToNameIt != serialIdToName_.end()) {
        serialIdToName_.erase(serialIdToNameIt);
    } else {
        qWarning().nospace() << "Unable to locate serialIdToName_ entry for 0x"
                             << hex << static_cast<uint>(deviceId);
        res = false;
    }

    return res;
}

void BoardManagerDerivate::checkNewSerialDevices()
{
    // empty, disable the BoardManager functionality working with serial ports
}

void BoardManagerDerivate::handleOperationFinished(strata::device::operation::Result result, int status, QString errStr)
{
    BoardManager::handleOperationFinished(result, status, errStr);
}

void BoardManagerDerivate::handleDeviceError(strata::device::Device::ErrorCode errCode, QString errStr)
{
    BoardManager::handleDeviceError(errCode, errStr);
}

// mutex_ must be locked before calling this function (due to modification openedDevices_ and using mockIdToName_)
bool BoardManagerDerivate::addMockPort(const int deviceId, bool startOperations)
{
    // 1. construct the mock device
    // 2. open the device
    // 3. attach DeviceOperations object

    const QString name = serialIdToName_.value(deviceId);

    DevicePtr device = std::make_shared<strata::device::mock::MockDevice>(deviceId, name, true);

    if (openDevice(device) == false) {
        qWarning().nospace() << "Cannot open device: ID: 0x" << hex << static_cast<uint>(deviceId) << ", name: " << name;
        QFAIL_("Cannot open device");
        return false;
    }
    qInfo().nospace() << "Added new mock device: ID: 0x" << hex << static_cast<uint>(deviceId) << ", name: " << name;
    if (startOperations) {
        startDeviceOperations(device);
    }
    return true;
}
