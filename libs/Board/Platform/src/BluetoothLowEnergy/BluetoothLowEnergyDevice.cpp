#include "BluetoothLowEnergy/BluetoothLowEnergyDevice.h"

#include "logging/LoggingQtCategories.h"

#include <QLowEnergyService>
#include <QLowEnergyController>
#include <QBluetoothUuid>

namespace strata::device {

BluetoothLowEnergyDevice::BluetoothLowEnergyDevice(const QBluetoothDeviceInfo &info)
    : Device(
          info.deviceUuid().toByteArray(QBluetoothUuid::WithoutBraces),
          info.name(),
          Type::BLEDevice),
      info_(info)
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

    controller_->deleteLater();
}

bool BluetoothLowEnergyDevice::open()
{
    if (controller_ == nullptr) {
        controller_ = QLowEnergyController::createCentral(info_);

        connect(controller_, &QLowEnergyController::connected,
                this, &BluetoothLowEnergyDevice::deviceConnectedHandler);

        connect(controller_, QOverload<QLowEnergyController::Error>::of(&QLowEnergyController::error),
                this, &BluetoothLowEnergyDevice::deviceErrorReceivedHandler);

        connect(controller_, &QLowEnergyController::disconnected,
                this, &BluetoothLowEnergyDevice::deviceDisconnectedHandler);

        connect(controller_, &QLowEnergyController::stateChanged,
                this, &BluetoothLowEnergyDevice::deviceStateChangeHandler);
    }

    controller_->connectToDevice();

    return true;
}

void BluetoothLowEnergyDevice::close()
{
    controller_->disconnectFromDevice();
}

bool BluetoothLowEnergyDevice::sendMessage(const QByteArray &message)
{
    qCDebug(logCategoryDeviceBLE).nospace().noquote()
        << deviceId_ << message;

    emit messageSent(message);

    return true;
}

bool BluetoothLowEnergyDevice::isConnected() const
{
    if (controller_ == nullptr) {
        return false;
    }

    return controller_->state() != QLowEnergyController::UnconnectedState;
}

void BluetoothLowEnergyDevice::deviceConnectedHandler()
{
}

void BluetoothLowEnergyDevice::deviceErrorReceivedHandler(QLowEnergyController::Error error)
{
}

void BluetoothLowEnergyDevice::deviceDisconnectedHandler()
{
}

void BluetoothLowEnergyDevice::deviceStateChangeHandler(QLowEnergyController::ControllerState state)
{
}

}  // namespace
