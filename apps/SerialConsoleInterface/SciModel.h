#pragma once

#include <PlatformManager.h>
#include "SciPlatformModel.h"
#include "SciMockDeviceModel.h"

#include <QObject>

class SciModel : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SciModel)

    Q_PROPERTY(strata::PlatformManager* platformManager READ platformManager CONSTANT)
    Q_PROPERTY(SciMockDeviceModel* mockDeviceModel READ mockDeviceModel CONSTANT)
    Q_PROPERTY(SciPlatformModel* platformModel READ platformModel CONSTANT)

public:
    explicit SciModel(QObject *parent = nullptr);
    virtual ~SciModel();

    strata::PlatformManager* platformManager();
    SciMockDeviceModel* mockDeviceModel();
    SciPlatformModel* platformModel();

private:
    strata::PlatformManager platformManager_;
    SciMockDeviceModel mockDeviceModel_;
    SciPlatformModel platformModel_;
};
