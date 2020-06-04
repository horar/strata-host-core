#include "BoardManagerDerivate.h"
#include "Device/DeviceOperations.h"
#include "DeviceMock.h"
#include "QtTest.h"

using strata::BoardManager;
using strata::device::Device;
using strata::device::DeviceOperations;
using strata::device::DevicePtr;

BoardManagerDerivate::BoardManagerDerivate() : BoardManager()
{
}

void BoardManagerDerivate::init(bool requireFwInfoResponse)
{
    reqFwInfoResp_ = requireFwInfoResponse;
}

void BoardManagerDerivate::mockAddNewDevice(const int deviceId, const QString deviceName)
{
    std::set<int> ports(serialPortsList_);
    QHash<int, QString> idToName(serialIdToName_);

    {
        // device ID must be int because of integration with QML
        auto [iter, success] = ports.emplace(deviceId);
        if (success == false) {
            // Error: hash already exists!
            QFAIL("deviceId already exists");
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

        computeListDiff(ports, added,
                        removed);  // uses serialPortsList_ (needs old value from previous run)

        // Do not emit boardDisconnected and boardConnected signals in this locked block of code.
        for (auto deviceId : removed) {
            if (closeDevice(deviceId)) {  // modifies openedDevices_
                deleted.emplace_back(deviceId);
            }
        }

        for (auto deviceId : added) {
            if (addDevice(deviceId, false)) {  // modifies openedDevices_, uses serialIdToName_
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

void BoardManagerDerivate::mockRemoveDevice(const int deviceId)
{
    serialPortsList_.erase(deviceId);
    serialIdToName_.remove(deviceId);
}

void BoardManagerDerivate::checkNewSerialDevices()
{
    // empty, disable the BoardManager functionality working with serial ports
}

void BoardManagerDerivate::handleNewMessage(QString message)
{
    BoardManager::handleNewMessage(message);
}

void BoardManagerDerivate::handleOperationFinished(strata::device::DeviceOperation operation,
                                                   int data)
{
    BoardManager::handleOperationFinished(operation, data);
}

void BoardManagerDerivate::handleOperationError(QString message)
{
    BoardManager::handleOperationError(message);
}

void BoardManagerDerivate::handleDeviceError(strata::device::Device::ErrorCode errCode,
                                             QString errStr)
{
    BoardManager::handleDeviceError(errCode, errStr);
}

// mutex_ must be locked before calling this function (due to modification openedDevices_ and using
// serialIdToName_)
bool BoardManagerDerivate::addDevice(const int deviceId, bool startOperations)
{
    const QString name = serialIdToName_.value(deviceId);

    DevicePtr device = std::make_shared<DeviceMock>(deviceId, name);

    if (openDevice(deviceId, device)) {
        if (startOperations) {
            startDeviceOperations(deviceId, device);
        }
        return true;
    } else {
        QFAIL_("Cannot open device");
        return false;
    }
}