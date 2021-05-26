#pragma once

#include <DeviceScanner.h>
#include <BluetoothLowEnergy/BluetoothLowEnergyDevice.h>

#include <QBluetoothDeviceDiscoveryAgent>

namespace strata::device::scanner {

struct BlootoothLowEnergyInfo {
    QString name;

     /* contains deviceUuid on macOS, address elsewhere */
    QString address;

    QVector<quint16> manufacturerIds;
};


class BluetoothLowEnergyScanner : public DeviceScanner
{
    Q_OBJECT
    Q_DISABLE_COPY(BluetoothLowEnergyScanner);

public:

    enum DiscoveryFinishStatus {
        Finished,
        Cancelled,
        DiscoveryError,
    };

    BluetoothLowEnergyScanner();

    ~BluetoothLowEnergyScanner() override;

    virtual void init() override;
    virtual void deinit() override;

    void startDiscovery();
    void stopDiscovery();
    const QList<BlootoothLowEnergyInfo> discoveredDevices();
    void tryConnectDevice(const QString &address);

signals:
    void discoveryFinished(DiscoveryFinishStatus status, QString errorString);

private slots:
    void discoveryFinishedHandler();
    void discoveryCancelledHandler();
    void discoveryErrorHandler(QBluetoothDeviceDiscoveryAgent::Error error);
    void deviceErrorHandler(Device::ErrorCode error, QString errorString);

private:
    bool isEligible(const QBluetoothDeviceInfo &info) const;
    QString getDeviceAddress(const QBluetoothDeviceInfo &info) const;

    QBluetoothDeviceDiscoveryAgent *discoveryAgent_ = nullptr;
    const std::chrono::milliseconds discoveryTimeout_ = std::chrono::milliseconds(5000);
    const QVector<quint16> eligibleIds_ = {866};
    QList<BlootoothLowEnergyInfo> discoveredDevices_;

    void createDiscoveryAgent();
};

typedef std::shared_ptr<BluetoothLowEnergyScanner> BluetoothLowEnergyScannerPtr;

}  // namespace
