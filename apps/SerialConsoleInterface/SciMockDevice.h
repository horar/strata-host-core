#pragma once

#include <PlatformManager.h>
#include "SciMockDeviceModel.h"
#include "SciMockCommandModel.h"
#include "SciMockResponseModel.h"
#include "SciMockVersionModel.h"

#include <QObject>

class SciMockDevice : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SciMockDevice)

    Q_PROPERTY(SciMockDeviceModel* mockDeviceModel READ mockDeviceModel CONSTANT)
    Q_PROPERTY(SciMockCommandModel* mockCommandModel READ mockCommandModel CONSTANT)
    Q_PROPERTY(SciMockResponseModel* mockResponseModel READ mockResponseModel CONSTANT)
    Q_PROPERTY(SciMockVersionModel* mockVersionModel READ mockVersionModel CONSTANT)

public:
    explicit SciMockDevice(strata::PlatformManager *platformManager);
    virtual ~SciMockDevice();
    void init();

    SciMockDeviceModel* mockDeviceModel();
    SciMockCommandModel* mockCommandModel();
    SciMockResponseModel* mockResponseModel();
    SciMockVersionModel* mockVersionModel();

private:
    SciMockDeviceModel mockDeviceModel_;
    SciMockCommandModel mockCommandModel_;
    SciMockResponseModel mockResponseModel_;
    SciMockVersionModel mockVersionModel_;
};
