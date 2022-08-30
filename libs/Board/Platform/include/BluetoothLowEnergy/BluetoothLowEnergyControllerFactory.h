/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QHash>
#include <QBluetoothDeviceInfo>
#include "BluetoothLowEnergy/BluetoothLowEnergyController.h"

namespace strata::device
{

class BluetoothLowEnergyControllerFactory final : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(BluetoothLowEnergyControllerFactory)

public:
    explicit BluetoothLowEnergyControllerFactory(QObject* parent = nullptr);
    virtual ~BluetoothLowEnergyControllerFactory();

    BluetoothLowEnergyControllerPtr acquireController(const QBluetoothDeviceInfo &info);

private slots:
    void handleControllerFinished();

private:
    static void operationLaterDeleter(BluetoothLowEnergyController* controller);

    QHash<quintptr, BluetoothLowEnergyControllerPtr> controllers_;
};

typedef std::shared_ptr<BluetoothLowEnergyControllerFactory> BluetoothLowEnergyControllerFactoryPtr;

}  // namespace strata::device
