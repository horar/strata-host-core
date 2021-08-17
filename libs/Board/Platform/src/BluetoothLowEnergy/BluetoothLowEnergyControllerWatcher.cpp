#include "BluetoothLowEnergy/BluetoothLowEnergyControllerWatcher.h"

#include "logging/LoggingQtCategories.h"

namespace strata::device
{

BluetoothLowEnergyControllerWatcher::BluetoothLowEnergyControllerWatcher(QObject* parent)
    : QObject(parent)
{
}

BluetoothLowEnergyControllerWatcher::~BluetoothLowEnergyControllerWatcher()
{
    controllers_.clear();
}

BluetoothLowEnergyControllerPtr BluetoothLowEnergyControllerWatcher::acquireController(const QBluetoothDeviceInfo &info)
{
    BluetoothLowEnergyControllerPtr controller(new BluetoothLowEnergyController(info, this), operationLaterDeleter);

    qCDebug(logCategoryDeviceBLE) << "Creating controller:" << controller.get();

    connect(controller.get(), &BluetoothLowEnergyController::finished,
            this, &BluetoothLowEnergyControllerWatcher::handleControllerFinished);

    controllers_.insert(reinterpret_cast<quintptr>(controller.get()), controller);

    return controller;
}

void BluetoothLowEnergyControllerWatcher::operationLaterDeleter(BluetoothLowEnergyController* controller)
{
    controller->deleteLater();
}

void BluetoothLowEnergyControllerWatcher::handleControllerFinished()
{
    BluetoothLowEnergyController *controller = qobject_cast<BluetoothLowEnergyController*>(QObject::sender());
    if (controller == nullptr) {
        qCCritical(logCategoryDeviceBLE) << "Received corrupt operation pointer:" << controller;
        return;
    }

    qCDebug(logCategoryDeviceBLE) << "Erasing controller:" << controller;

    controllers_.remove(reinterpret_cast<quintptr>(controller));
}

}  // namespace strata::device
