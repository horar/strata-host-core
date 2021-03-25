#pragma once

#include <PlatformManager.h>
#include "SciDatabaseConnector.h"
#include "SciPlatformModel.h"

#include <QObject>

class SciModel : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SciModel)

    Q_PROPERTY(strata::PlatformManager* platformManager READ platformManager CONSTANT)
    Q_PROPERTY(SciDatabaseConnector* databaseConnector READ databaseConnector CONSTANT)
    Q_PROPERTY(SciPlatformModel* platformModel READ platformModel CONSTANT)

public:
    explicit SciModel(QObject *parent = nullptr);
    virtual ~SciModel();

    strata::PlatformManager* platformManager();
    SciDatabaseConnector* databaseConnector();
    SciPlatformModel* platformModel();

private:
    strata::PlatformManager platformManager_;
    SciDatabaseConnector db_;
    SciPlatformModel platformModel_;
};
