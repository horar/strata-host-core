/*
 * Copyright (c) 2018-2021 onsemi.
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

namespace strata::device::scanner
{
class TcpDeviceScanner : public DeviceScanner
{
    Q_OBJECT;
    Q_DISABLE_COPY(TcpDeviceScanner);

public:
    /**
     * Flags defining properties for TCP device scanner.
     * By default, scanner starts with all flags unset.
     */
    enum TcpScannerFlag {
        DisableAutomaticScan = 0x0001
    };
    Q_DECLARE_FLAGS(TcpScannerProperty, TcpScannerFlag)

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
     * Set properties for TCP device scanner.
     * Calling setProperties(A | B) is equivalent to calling setProperties(A) and then setProperties(B).
     * @param flags flags defining properties for TCP device scanner
     */
    void setProperties(quint32 flags);

    /**
     * Unset properties for TCP device scanner.
     * Calling unsetProperties(A | B) is equivalent to calling unsetProperties(A) and then unsetProperties(B).
     * To unset all properties (restore default values), call unsetProperties(0xFFFFFFFF).
     * @param flags flags defining properties for TCP device scanner
     */
    void unsetProperties(quint32 flags);


private slots:
    void processPendingDatagrams();
    void deviceDisconnectedHandler();

private:
    void startAutomaticScan();
    void stopAutomaticScan();
    void addTcpDevice(QHostAddress deviceAddress, quint16 tcpPort);
    bool parseDatagram(const QByteArray &datagram, quint16 &tcpPort);

    std::unique_ptr<QUdpSocket> udpSocket_;
    QList<QByteArray> discoveredDevices_;

    bool scanRunning_;

    static constexpr qint16 UDP_LISTEN_PORT{5146};
};
}  // namespace strata::device::scanner
