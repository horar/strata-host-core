/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <DeviceScanner.h>
#include "logging/LoggingQtCategories.h"

namespace strata::device::scanner {

DeviceScanner::DeviceScanner(const Device::Type scannerType) :
    scannerType_(scannerType)
{ }

DeviceScanner::~DeviceScanner() { }


const QMap<Device::Type, QByteArray> DeviceScanner::allScannerTypes_ = {
    {Device::Type::SerialDevice, QByteArray("s")},
    {Device::Type::MockDevice, QByteArray("m")},
    {Device::Type::TcpDevice, QByteArray("n")},
    {Device::Type::BLEDevice, QByteArray("b")}
};

Device::Type DeviceScanner::scannerType() const
{
    return scannerType_;
}

QByteArray DeviceScanner::scannerPrefix() const
{
    return scannerPrefix(scannerType_);
}

QByteArray DeviceScanner::createDeviceId(const QByteArray &uniqueHash) const
{
    return QByteArray(scannerPrefix() + uniqueHash);
}

Device::Type DeviceScanner::scannerType(const QByteArray& deviceId)
{
    for (auto it = allScannerTypes_.keyValueBegin(); it != allScannerTypes_.keyValueEnd(); it++) {
        if (deviceId.startsWith((*it).second)) {
            return (*it).first;
        }
    }
    qCCritical(lcDeviceScanner) << "Unknown device scanner type for deviceId:" << deviceId;
    return Device::Type::MockDevice;
}

const QByteArray DeviceScanner::scannerPrefix(const Device::Type type)
{
    QByteArray retVal = allScannerTypes_.value(type);
    if (retVal.isEmpty()) {
        qCCritical(lcDeviceScanner) << "Unknown device scanner type:" << type;
    }
    return retVal;
}

}  // namespace
