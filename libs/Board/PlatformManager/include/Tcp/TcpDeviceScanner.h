/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <DeviceScanner.h>
#include <Tcp/TcpDevice.h>

#include <QHostAddress>
#include <QUdpSocket>
#include <QSet>

namespace strata::device::scanner
{

struct TcpDeviceInfo {
    QByteArray deviceId;
    QString deviceName;
    QHostAddress deviceIpAddress;
    quint16 port;
};

class TcpDeviceScanner : public DeviceScanner
{
    Q_OBJECT;
    Q_DISABLE_COPY(TcpDeviceScanner);

public:
    /**
     * TcpDeviceScanner constructor
     */
    TcpDeviceScanner();

    /**
     * TcpDeviceScanner destructor
     */
    ~TcpDeviceScanner();

    /**
     * Initialize scanner.
     * @param flags flags defining properties for TCP device scanner (by default are all flags are unset)
     */
    virtual void init(quint32 flags = 0) override;

    /**
     * Deinitialize scanner and stop scanning for new devices. Will close all open devices.
     */
    virtual void deinit() override;

    /**
     * Return list of deviceIds of all discovered devices
     * @return list of discovered devices
     */
    virtual QList<QByteArray> discoveredDevices() const override;

    /**
     * Return list of information of all discovered devices
     * @return list of TcpDeviceInfo
     */
    const QList<TcpDeviceInfo> discoveredTcpDevices() const;

    /**
     * Initiates connection to discovered device.
     * @param deviceId device ID, returned by discoveredDevices()
     * @return empty string if connecting started, error message if there was an error
     */
    virtual QString connectDevice(const QByteArray& deviceId) override;

    /**
     * Drops connection to discovered device.
     * @param deviceId device ID
     * @return empty string if disconnected, error message if there was an error.
     */
    virtual QString disconnectDevice(const QByteArray& deviceId) override;

    /**
     * Drops connection to all discovered devices.
     */
    virtual void disconnectAllDevices() override;

    /**
     * Starts searching for tcp devices
     * Note: search will last for 5 seconds.
     */
    void startDiscovery();

public slots:
    /**
     * Stops searching for tcp devices
     */
    void stopDiscovery();

signals:
    void discoveryFinished();

private slots:
    void processPendingDatagrams();

private:
    bool parseDatagram(const QByteArray &datagram, quint16 &tcpPort);

    std::unique_ptr<QUdpSocket> udpSocket_;
    QList<TcpDeviceInfo> discoveredDevices_;
    QHash<QByteArray, TcpDeviceInfo> createdDevices_;
    QTimer discoveryTimer_;
    bool scanRunning_;

    static constexpr qint16 UDP_LISTEN_PORT{5146};
    static constexpr std::chrono::milliseconds DISCOVERY_TIMEOUT{5000};
};

typedef std::shared_ptr<TcpDeviceScanner> TcpDeviceScannerPtr;

}  // namespace strata::device::scanner
