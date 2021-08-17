#pragma once

#include <QHash>
#include <QBluetoothDeviceInfo>
#include "BluetoothLowEnergy/BluetoothLowEnergyController.h"

namespace strata::device
{

class BluetoothLowEnergyControllerWatcher final : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(BluetoothLowEnergyControllerWatcher)

public:
    explicit BluetoothLowEnergyControllerWatcher(QObject* parent = nullptr);
    virtual ~BluetoothLowEnergyControllerWatcher();

    BluetoothLowEnergyControllerPtr acquireController(const QBluetoothDeviceInfo &info);

private slots:
    void handleControllerFinished();

private:
    static void operationLaterDeleter(BluetoothLowEnergyController* controller);

    QHash<quintptr, BluetoothLowEnergyControllerPtr> controllers_;
};

typedef std::shared_ptr<BluetoothLowEnergyControllerWatcher> BluetoothLowEnergyControllerWatcherPtr;

}  // namespace strata::device
