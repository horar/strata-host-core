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
     * @param flags flags defining properties for TCP device scanner
     */
    virtual void init(quint32 flags = 0) override;

    /**
     * Deinitialize scanner and stop scanning for new devices. Will close all open devices.
     */
    virtual void deinit() override;

    /**
     * Set properties for TCP device scanner.
     * @param flags flags defining properties for TCP device scanner
     */
    void setProperties(quint32 flags);

    /**
     * Unset properties for TCP device scanner.
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
