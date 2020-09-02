#pragma once

#include "BoardManager.h"

class BoardManagerDerivate : public strata::BoardManager
{
    Q_OBJECT

public:
    BoardManagerDerivate();
    virtual void init(bool requireFwInfoResponse = true) override;

    void mockAddNewDevice(const int deviceId,
                          const QString deviceName);  // pretend we've found a new serial port
    void mockRemoveDevice(const int deviceId);        // pretend serial port was removed
private slots:
    virtual void checkNewSerialDevices() override;
    virtual void handleOperationFinished(strata::device::operation::Type opType, int) override;
    virtual void handleOperationError(QString message) override;
    virtual void handleDeviceError(strata::device::Device::ErrorCode errCode,
                                   QString errStr) override;

private:
    bool addDevice(const int deviceId, bool startOperations);
};
