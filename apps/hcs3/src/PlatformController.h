#pragma once

#include <QObject>
#include <QString>
#include <QHash>

#include <PlatformManager.h>
#include <BluetoothLowEnergy/BluetoothLowEnergyScanner.h>

/*
This PlatformController class is replacement for original classes BoardsController and PlatformBoard.

Instead of two original classes is now used PlatformManager.

Functions in this PlatformController class are very similar as original ones from BoardsController class.
BoardsController managed PlatformBoard objects (one PlatformBoard object for one platform).

PlatformBoard class held information about board and also shared pointer to PlatformConnection object
which managed communication with serial device. Properties which was held by PlatformBoard class are
now in Platform.

All (serial port) devices are now managed by PlatformManager where devices are identified by device ID.
To be compatible with rest rest of current HCS implementation we need to have some information about connected
devices. This information are stored in platforms_ map.
*/
class PlatformController final : public QObject {
    Q_OBJECT
    Q_DISABLE_COPY(PlatformController)

public:
    /**
     * PlatformController constructor
     */
    PlatformController();

    /**
     * Initializes the platform controller
     */
    void initialize();

    /**
     * Sends message to platform specified by device Id
     * @param deviceId
     * @param message
     * @return true if massage can be sent
     */
    bool sendMessage(const QByteArray& deviceId, const QByteArray& message);

    /**
     * Gets platform specified by device ID
     * @param deviceId
     * @return platform or nullptr if such platform with device ID is not available
     */
    strata::platform::PlatformPtr getPlatform(const QByteArray& deviceId) const;

    /**
     * Creates JSON with list of platforms
     * @return list of platforms in JSON format
     */
    QString createPlatformsList();

    /**
     * Starts scanning for BLE devices. Will send a notification upon success/failure.
     */
    void startBluetoothScan();
signals:
    void platformConnected(QByteArray deviceId);
    void platformDisconnected(QByteArray deviceId);
    void platformMessage(QString platformId, QString message);
    void bluetoothScanFinished(const QJsonObject payload);

private slots:  // slots for signals from PlatformManager
    void newConnection(const QByteArray& deviceId, bool recognized);
    void closeConnection(const QByteArray& deviceId);
    void messageFromPlatform(strata::platform::PlatformMessage message);
    void bleDiscoveryFinishedHandler(strata::device::scanner::BluetoothLowEnergyScanner::DiscoveryFinishStatus status, QString errorString);

private:
    /**
     * Creates bluetooth_scan notification payload, with list of found BLE devices
     * @param reference to the bluetooth scanner, used as data source
     * @return bluetooth_scan notification payload
     */
    static QJsonObject createBluetoothScanPayload(const std::shared_ptr<const strata::device::scanner::BluetoothLowEnergyScanner> bleDeviceScanner);

    /**
     * Creates bluetooth_scan error notification payload
     * @return bluetooth_scan error notification payload
     */
    static  QJsonObject createBluetoothScanErrorPayload(QString errorString);


    strata::PlatformManager platformManager_;

    // map: deviceID <-> Platform
    QHash<QByteArray, strata::platform::PlatformPtr> platforms_;
    // access to platforms_ should be protected by mutex in case of multithread usage
};
