#pragma once

#include "BoardManager.h"

class BoardManagerDerivate : public strata::BoardManager
{
    Q_OBJECT

public:
    BoardManagerDerivate();

    /**
     * Initialize BoardManagerDerivate (start managing connected Mock devices).
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
    virtual void handleOperationFinished(strata::device::operation::Result result, int status, QString errStr) override;
    virtual void handleDeviceError(strata::device::Device::ErrorCode errCode, QString errStr) override;

private:
    bool addMockPort(const QByteArray& deviceId, bool startOperations);
};
