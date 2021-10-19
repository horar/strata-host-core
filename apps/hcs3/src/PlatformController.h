/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>
#include <QString>
#include <QHash>

#include <PlatformManager.h>
#ifdef APPS_CORESW_SDS_PLUGIN_BLE
#include <BluetoothLowEnergy/BluetoothLowEnergyScanner.h>
#endif // APPS_CORESW_SDS_PLUGIN_BLE
#include <Operations/PlatformOperations.h>

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
     * PlatformController destructor
     */
    virtual ~PlatformController();

    /**
     * Initializes the platform controller
     */
    void initialize();

    /**
     * Sends message to platform specified by device Id
     * @param deviceId
     * @param message
     */
    void sendMessage(const QByteArray& deviceId, const QByteArray& message);

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
    QJsonObject createPlatformsList();

#ifdef APPS_CORESW_SDS_PLUGIN_BLE
    /**
     * Starts scanning for BLE devices. Will send a notification upon success/failure.
     */
    void startBluetoothScan();
#endif // APPS_CORESW_SDS_PLUGIN_BLE

    /**
     * Connects a device (don't confuse with a platform)
     * Creates a communication channel. Used for BLE and in the future for other
     * device types without direct connection to local computer.
     * @param deviceId device ID, as returned from device scanner, e.g. via bluetoothScanFinished.
     * @param clientId client starting this call
     */
    void connectDevice(const QByteArray &deviceId, const QByteArray &clientId);

    /**
     * Disconnects a device (don't confuse with a platform)
     * Drops a communication channel. Used for BLE and in the future for other
     * device types without direct connection to local computer.
     * @param deviceId device ID
     * @param clientId client starting this call
     */
    void disconnectDevice(const QByteArray &deviceId, const QByteArray &clientId);

    bool platformStartApplication(const QByteArray& deviceId);

signals:
    void platformConnected(QByteArray deviceId);
    void platformDisconnected(QByteArray deviceId);
    void platformMessage(QString platformId, QJsonObject message);
#ifdef APPS_CORESW_SDS_PLUGIN_BLE
    void bluetoothScanFinished(const QJsonObject payload);
#endif // APPS_CORESW_SDS_PLUGIN_BLE
    void connectDeviceFinished(const QByteArray deviceId, const QByteArray clientId);
    void connectDeviceFailed(const QByteArray deviceId, const QByteArray clientId, const QString errorMessage);
    void disconnectDeviceFinished(const QByteArray deviceId, const QByteArray clientId);
    void disconnectDeviceFailed(const QByteArray deviceId, const QByteArray clientId, const QString errorMessage);
    void platformApplicationStarted(QByteArray deviceId);

public slots:
    void bootloaderActive(QByteArray deviceId);
    void applicationActive(QByteArray deviceId);

private slots:
    // slots for signals from PlatformManager
    void newConnection(const QByteArray& deviceId, bool recognized, bool inBootloader);
    void closeConnection(const QByteArray& deviceId);
    void messageFromPlatform(strata::platform::PlatformMessage message);
    void messageToPlatform(QByteArray rawMessage, unsigned msgNumber, QString errorString);
#ifdef APPS_CORESW_SDS_PLUGIN_BLE
    void bleDiscoveryFinishedHandler(strata::device::scanner::BluetoothLowEnergyScanner::DiscoveryFinishStatus status, QString errorString);
#endif // APPS_CORESW_SDS_PLUGIN_BLE
    void connectDeviceFinishedHandler(const QByteArray& deviceId);
    void connectDeviceFailedHandler(const QByteArray& deviceId, const QString &errorString);

    // slot for signal from PlatformOperations
    void operationFinished(QByteArray deviceId,
                           strata::platform::operation::Type type,
                           strata::platform::operation::Result result,
                           int status,
                           QString errorString);

private:
#ifdef APPS_CORESW_SDS_PLUGIN_BLE
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
#endif // APPS_CORESW_SDS_PLUGIN_BLE

    struct PlatformData {
        PlatformData(strata::platform::PlatformPtr p, bool b);

        strata::platform::PlatformPtr platform;
        bool inBootloader;
        bool startAppFailed;
        unsigned sentMessageNumber;  // number of last sent message
    };

    strata::PlatformManager platformManager_;

    // map: deviceID <-> PlatformData
    QHash<QByteArray, PlatformData> platforms_;
    // access to platforms_ should be protected by mutex in case of multithread usage

    strata::platform::operation::PlatformOperations platformOperations_;

    QMultiMap<QByteArray, QByteArray> connectDeviceRequests_; //remember clients who have sent connectDevice requests
};
