#include "PlatformManagerDerivate.h"
#include <Mock/MockDevice.h>
#include "QtTest.h"

using strata::PlatformManager;
using strata::device::Device;
using strata::device::DevicePtr;
using strata::platform::Platform;
using strata::platform::PlatformPtr;

PlatformManagerDerivate::PlatformManagerDerivate() : PlatformManager()
{
}

void PlatformManagerDerivate::init(bool requireFwInfoResponse, bool keepDevicesOpen)
{
    reqFwInfoResp_ = requireFwInfoResponse;
    keepDevicesOpen_ = keepDevicesOpen;
}

bool PlatformManagerDerivate::addNewMockDevice(const QByteArray& deviceId, const QString deviceName)
{
    qDebug().nospace().noquote() << "Adding new mock device (" << deviceId << "): '" << deviceName << "'";
    std::set<QByteArray> ports(serialPortsList_);
    QHash<QByteArray, QString> idToName(serialIdToName_);

    {
        auto [iter, success] = ports.emplace(deviceId);
        if (success == false) {
            // Error: hash already exists!
            qCritical().nospace().noquote() << "Cannot add device (hash conflict: " << deviceId << "): '" << deviceName << "'";
            QFAIL_("deviceId already exists");
            return false;
        } else {
            idToName.insert(deviceId, deviceName);
        }
    }

    std::set<QByteArray> added, removed;
    std::vector<QByteArray> opened, deleted;
    opened.reserve(added.size());

    {  // this block of code modifies serialPortsList_, openedDevices_, serialIdToName_
        QMutexLocker lock(&mutex_);

        serialIdToName_ = std::move(idToName);

        computeListDiff(ports, added, removed); // uses serialPortsList_ (needs old value from previous run)

        // Do not emit boardDisconnected and boardConnected signals in this locked block of code.
        for (auto removedDeviceId : removed) {
            if (removePlatform(removedDeviceId)) {        // modifies openedDevices_ and reconnectTimers_
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

bool PlatformManagerDerivate::removeMockDevice(const QByteArray& deviceId)
{
    bool res = true;
    // call after disconnecting
    auto serialPortsListIt = serialPortsList_.find(deviceId);
    if (serialPortsListIt != serialPortsList_.end()) {
        serialPortsList_.erase(serialPortsListIt);
    } else {
        qWarning().noquote() << "Unable to locate serialPortsList_ entry for" << deviceId;
        res = false;
    }

    auto serialIdToNameIt = serialIdToName_.find(deviceId);
    if (serialIdToNameIt != serialIdToName_.end()) {
        serialIdToName_.erase(serialIdToNameIt);
    } else {
        qWarning().noquote() << "Unable to locate serialIdToName_ entry for " << deviceId;
        res = false;
    }

    return res;
}

void PlatformManagerDerivate::checkNewSerialDevices()
{
    // empty, disable the PlatformManager functionality working with serial ports
}

// mutex_ must be locked before calling this function (due to modification openedDevices_ and using mockIdToName_)
bool PlatformManagerDerivate::addMockPort(const QByteArray& deviceId, bool startOperations)
{
    // 1. construct the mock device
    // 2. open the device
    // 3. attach PlatformOperations object

    const QString name = serialIdToName_.value(deviceId);

    DevicePtr device = std::make_shared<strata::device::MockDevice>(deviceId, name, true);
    PlatformPtr platform = std::make_shared<Platform>(device);

    if (openPlatform(platform) == false) {
        qWarning().nospace().noquote() << "Cannot open device: ID: " << deviceId << ", name: '" << name << "'";
        QFAIL_("Cannot open device");
        return false;
    }
    qInfo().nospace().noquote() << "Added new mock device: ID: " << deviceId << ", name: '" << name << "'";
    if (startOperations) {
        startPlatformOperations(platform);
    }
    return true;
}
