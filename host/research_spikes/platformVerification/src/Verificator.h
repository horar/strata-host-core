#pragma once

#include <memory>
#include <DeviceScanner.h>
#include <Device.h>
#include <QObject>
#include <QHash>

namespace strata {

typedef std::unique_ptr<device::scanner::DeviceScanner> DeviceScannerPtr;

class Verificator : public QObject {
    Q_OBJECT
public:
    Verificator();
    virtual ~Verificator();

    void start();
    void stop();

private slots:
    void deviceDetectedHandler(device::DevicePtr device);
    void deviceLostHandler(QByteArray deviceId);
    void messageFromDeviceHandler(QByteArray msg);
    void messageSentHandler(QByteArray msg);
    void deviceErrorHandler(device::Device::ErrorCode errCode, QString msg);

private:
    void addMockDevices();

    DeviceScannerPtr serialDeviceScanner;
    DeviceScannerPtr mockDeviceScanner;
    QHash<QByteArray, device::DevicePtr> openedDevices_;
};

}  // namespace
