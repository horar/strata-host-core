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
    /**
     * SerialDeviceScanner constructor
     */
    SerialDeviceScanner();

    /**
     * SerialDeviceScanner destructor
     */
    ~SerialDeviceScanner() override;

    /**
     * Start scanning for new devices.
     * @return true if scanning was started, otherwise false
     */
    virtual void init() override;

    /**
     * Stop scanning for new devices. Will close all open devices.
     */
    virtual void deinit() override;

private slots:
    void checkNewSerialDevices();

private:
    void computeListDiff(const std::set<QByteArray>& originalList, const std::set<QByteArray>& newList,
                         std::set<QByteArray>& addedList, std::set<QByteArray>& removedList) const;
    bool addSerialDevice(const QByteArray& deviceId);

    QTimer timer_;
    std::set<QByteArray> deviceIds_;        // Ids of detected Devices for which we emited deviceDetected
    QHash<QByteArray, QString> portNames_;  // serial port names for each detected Device Id
};

}  // namespace
