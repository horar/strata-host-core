#pragma once

#include <PlatformManager.h>
#include "SciPlatformModel.h"
#include "SciMockDeviceModel.h"
#include "SciMockCommandModel.h"
#include "SciMockResponseModel.h"
#include "SciMockVersionModel.h"

#include <QObject>

class SciModel : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SciModel)

    Q_PROPERTY(strata::PlatformManager* platformManager READ platformManager CONSTANT)
    Q_PROPERTY(SciPlatformModel* platformModel READ platformModel CONSTANT)
    Q_PROPERTY(SciMockDeviceModel* mockDeviceModel READ mockDeviceModel CONSTANT)
    Q_PROPERTY(SciMockCommandModel* mockCommandModel READ mockCommandModel CONSTANT)
    Q_PROPERTY(SciMockResponseModel* mockResponseModel READ mockResponseModel CONSTANT)
    Q_PROPERTY(SciMockVersionModel* mockVersionModel READ mockVersionModel CONSTANT)

public:
    explicit SciModel(QObject *parent = nullptr);
    virtual ~SciModel();

    strata::PlatformManager* platformManager();
    SciPlatformModel* platformModel();
    SciMockDeviceModel* mockDeviceModel();
    SciMockCommandModel* mockCommandModel();
    SciMockResponseModel* mockResponseModel();
    SciMockVersionModel* mockVersionModel();

private:
    strata::PlatformManager platformManager_;
    SciPlatformModel platformModel_;
    SciMockDeviceModel mockDeviceModel_;
    SciMockCommandModel mockCommandModel_;
    SciMockResponseModel mockResponseModel_;
    SciMockVersionModel mockVersionModel_;
};
