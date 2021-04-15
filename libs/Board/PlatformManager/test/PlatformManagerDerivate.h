#pragma once

#include "PlatformManager.h"

class PlatformManagerDerivate : public strata::PlatformManager
{
    Q_OBJECT

public:
    PlatformManagerDerivate();

    /**
     * Initialize PlatformManagerDerivate (start managing connected Mock devices).
     * @param requireFwInfoResponse if true require response to get_firmware_info command during device identification
     * @param keepDevicesOpen if true communication channel is not released (closed) if device is not recognized
     */
    virtual void init(bool requireFwInfoResponse, bool keepDevicesOpen) override;

    /**
     * Add new MockDevice with specific name and Id
     * @param deviceId device ID
     * @param deviceName device Name
     * @return true if device was added, otherwise false
     */
    bool addNewMockDevice(const QByteArray& deviceId, const QString deviceName);

    /**
     * Remove MockDevice
     * @param deviceId device ID
     * @return true if device was removed, otherwise false
     */
    bool removeMockDevice(const QByteArray& deviceId);

private slots:
    virtual void checkNewSerialDevices() override;

private:
    bool addMockPort(const QByteArray& deviceId, bool startOperations);
};
