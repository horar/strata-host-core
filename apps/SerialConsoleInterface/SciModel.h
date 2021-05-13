#pragma once

#include <PlatformManager.h>
#include "SciPlatformModel.h"
#include "SciMockDevice.h"

#include <QObject>

class SciModel : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SciModel)

    Q_PROPERTY(strata::PlatformManager* platformManager READ platformManager CONSTANT)
    Q_PROPERTY(SciPlatformModel* platformModel READ platformModel CONSTANT)
    Q_PROPERTY(SciMockDevice* mockDevice READ mockDevice CONSTANT)

public:
    explicit SciModel(QObject *parent = nullptr);
    virtual ~SciModel();

    strata::PlatformManager* platformManager();
    SciPlatformModel* platformModel();
    SciMockDevice* mockDevice();

private:
    strata::PlatformManager platformManager_;
    SciPlatformModel platformModel_;
    SciMockDevice mockDevice_;
};
