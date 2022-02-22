/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "BluetoothLowEnergy/BluetoothLowEnergyControllerFactory.h"

#include "logging/LoggingQtCategories.h"

namespace strata::device
{

BluetoothLowEnergyControllerFactory::BluetoothLowEnergyControllerFactory(QObject* parent)
    : QObject(parent)
{
}

BluetoothLowEnergyControllerFactory::~BluetoothLowEnergyControllerFactory()
{
    controllers_.clear();
}

BluetoothLowEnergyControllerPtr BluetoothLowEnergyControllerFactory::acquireController(const QBluetoothDeviceInfo &info)
{
    BluetoothLowEnergyControllerPtr controller(new BluetoothLowEnergyController(info, this), operationLaterDeleter);

    qCDebug(lcDeviceBLE) << "Creating controller:" << controller.get();

    connect(controller.get(), &BluetoothLowEnergyController::finished,
            this, &BluetoothLowEnergyControllerFactory::handleControllerFinished);

    controllers_.insert(reinterpret_cast<quintptr>(controller.get()), controller);

    return controller;
}

void BluetoothLowEnergyControllerFactory::operationLaterDeleter(BluetoothLowEnergyController* controller)
{
    controller->deleteLater();
}

void BluetoothLowEnergyControllerFactory::handleControllerFinished()
{
    BluetoothLowEnergyController *controller = qobject_cast<BluetoothLowEnergyController*>(QObject::sender());
    if (controller == nullptr) {
        qCCritical(lcDeviceBLE) << "Received corrupt operation pointer:" << controller;
        return;
    }

    qCDebug(lcDeviceBLE) << "Erasing controller:" << controller;

    controllers_.remove(reinterpret_cast<quintptr>(controller));
}

}  // namespace strata::device
