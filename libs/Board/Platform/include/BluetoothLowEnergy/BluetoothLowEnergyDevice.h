#pragma once

#include <Device.h>
#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

namespace strata::device {

class BluetoothLowEnergyDevice: public Device
{
    Q_OBJECT
    Q_DISABLE_COPY(BluetoothLowEnergyDevice)

public:
    /**
     * BluetoothLowEnergyDevice constructor
     * @param deviceId device ID
     * @param name device name
     */
    BluetoothLowEnergyDevice(const QBluetoothDeviceInfo &info);

    /**
     * BluetoothLowEnergyDevice destructor
     */
    ~BluetoothLowEnergyDevice() override;

    /**
     * Open device communication channel.
     * @return true if device was opened, otherwise false
     */
    virtual bool open() override;

    /**
     * Close device communication channel.
     */
    virtual void close() override;

    /**
     * Send message to device.
     * @param message message to be written to device
     * @return true if message can be sent, otherwise false
     */
    virtual bool sendMessage(const QByteArray& message) override;

    /**
     * Check if device is connected (communication with it is possible).
     * @return true if device is connected, otherwise false
     */
    virtual bool isConnected() const override;

private slots:
    void deviceConnectedHandler();
    void deviceErrorReceivedHandler(QLowEnergyController::Error error);
    void deviceDisconnectedHandler();
    void deviceStateChangeHandler(QLowEnergyController::ControllerState state);

private:
    QByteArray deviceId_;

    QBluetoothDeviceInfo info_;
    QLowEnergyController *controller_{nullptr};
};

}  // namespace
