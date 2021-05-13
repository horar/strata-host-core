#include "BluetoothLowEnergy/BluetoothLowEnergyDevice.h"

#include "logging/LoggingQtCategories.h"

namespace strata::device {

BluetoothLowEnergyDevice::BluetoothLowEnergyDevice(
        const QByteArray &deviceId,
        const QString &name)
    : Device(deviceId, name, Type::BLEDevice)
{
    qCDebug(logCategoryDeviceBLE).nospace().noquote()
        << "Created new BLE device, ID: " << deviceId_
        << ", name: '" << deviceName_ << "'"
        << ", unique ID: 0x" << hex << reinterpret_cast<quintptr>(this);
}

BluetoothLowEnergyDevice::~BluetoothLowEnergyDevice()
{
    qCDebug(logCategoryDeviceBLE).nospace().noquote()
        << "Deleted BLE device, ID: " << deviceId_
        << ", unique ID: 0x" << hex << reinterpret_cast<quintptr>(this);
}

bool BluetoothLowEnergyDevice::open()
{
    connected_ = true;

    return connected_;
}

void BluetoothLowEnergyDevice::close()
{
    connected_ = false;
}

bool BluetoothLowEnergyDevice::sendMessage(const QByteArray &message)
{
    qCDebug(logCategoryDeviceBLE).nospace().noquote()
        << deviceId_ << message;

    return true;
}

bool BluetoothLowEnergyDevice::isConnected() const
{
    return connected_;
}

}  // namespace
