#pragma once

#include <set>

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QHash>
#include <QTimer>

#include <DeviceScanner.h>
#include <Serial/SerialDevice.h>

namespace strata::device::scanner {

class SerialDeviceScanner : public DeviceScanner
{
    Q_OBJECT
    Q_DISABLE_COPY(SerialDeviceScanner)

public:
    enum SerialScannerFlag {
        DisableAutomaticScan = 0x0001
    };
    Q_DECLARE_FLAGS(SerialScannerProperty, SerialScannerFlag)

    /**
     * SerialDeviceScanner constructor
     */
    SerialDeviceScanner();

    /**
     * SerialDeviceScanner destructor
     */
    ~SerialDeviceScanner() override;

    /**
     * Initialize scanner.
     * @param flags flags defining properties for serial device scanner
     */
    virtual void init(quint32 flags = 0) override;

    /**
     * Deinitialize scanner and stop scanning for new devices. Will close all open devices.
     */
    virtual void deinit() override;

    /**
     * Set properties for serial device scanner.
     * @param flags flags defining properties for serial device scanner
     */
    void setProperties(quint32 flags);

    /**
     * Unset properties for serial device scanner.
     * @param flags flags defining properties for serial device scanner
     */
    void unsetProperties(quint32 flags);

private slots:
    void checkNewSerialDevices();

private:
    void startAutomaticScan();
    void stopAutomaticScan();
    void computeListDiff(const std::set<QByteArray>& originalList, const std::set<QByteArray>& newList,
                         std::set<QByteArray>& addedList, std::set<QByteArray>& removedList) const;
    bool addSerialDevice(const QByteArray& deviceId);

    QTimer timer_;
    std::set<QByteArray> deviceIds_;        // Ids of detected Devices for which we emited deviceDetected
    QHash<QByteArray, QString> portNames_;  // serial port names for each detected Device Id
};

}  // namespace
