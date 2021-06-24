#pragma once

#include <DeviceScanner.h>
#include <BluetoothLowEnergy/BluetoothLowEnergyDevice.h>

#include <QBluetoothDeviceDiscoveryAgent>

namespace strata::device::scanner {

struct BlootoothLowEnergyInfo {
    QByteArray deviceId;
    QString name;
    QString address; // contains deviceUuid on macOS, address elsewhere
    qint16 rssi;
    QVector<quint16> manufacturerIds;
    bool isStrata;
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
    const QList<BlootoothLowEnergyInfo> discoveredDevices() const;

    /**
     * Initiates connection to discovered BLE device.
     * Possible outcomes:
     * - immediate error -> will return non-empty string
     * - error during connecting -> will emit connectDeviceFailed
     * - success -> will emit connectDeviceFinished
     * @param deviceId device ID, returned by discoveredDevices()
     * @return empty string if connecting started (doesn't mean successful connection, only initiation of connection process).
     * Error message if there was an error.
     */
    QString connectDevice(const QByteArray& deviceId);

    /**
     * Drops connection to discovered BLE device.
     * @param deviceId device ID
     * @return empty string if disconnected.
     * Error message if there was an error.
     */
    QString disconnectDevice(const QByteArray& deviceId);

signals:
    void discoveryFinished(DiscoveryFinishStatus status, QString errorString);
    void connectDeviceFinished(const QByteArray deviceId);
    void connectDeviceFailed(const QByteArray deviceId, const QString errorString);

private slots:
    void discoveryFinishedHandler();
    void discoveryCancelledHandler();
    void discoveryErrorHandler(QBluetoothDeviceDiscoveryAgent::Error error);
    void deviceOpenedHandler();
    void deviceErrorHandler(Device::ErrorCode error, QString errorString);

private:
    bool isEligible(const QBluetoothDeviceInfo &info) const;
    QString getDeviceAddress(const QBluetoothDeviceInfo &info) const;

    QBluetoothDeviceDiscoveryAgent *discoveryAgent_ = nullptr;
    const std::chrono::milliseconds discoveryTimeout_ = std::chrono::milliseconds(5000);
    QList<BlootoothLowEnergyInfo> discoveredDevices_;
    QList<QByteArray> createdDevices_;
    QHash<QByteArray, QBluetoothDeviceInfo> discoveredDevicesMap_; // map deviceId -> QBluetoothDeviceInfo

    void createDiscoveryAgent();
};

typedef std::shared_ptr<BluetoothLowEnergyScanner> BluetoothLowEnergyScannerPtr;

}  // namespace
