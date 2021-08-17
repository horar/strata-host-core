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
