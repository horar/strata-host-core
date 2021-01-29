#pragma once

#include <BoardManager.h>
#include "SciDatabaseConnector.h"
#include "SciPlatformModel.h"

#include <QObject>

class SciModel : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SciModel)

    Q_PROPERTY(strata::BoardManager* boardManager READ boardManager CONSTANT)
    Q_PROPERTY(SciDatabaseConnector* databaseConnector READ databaseConnector CONSTANT)
    Q_PROPERTY(SciPlatformModel* platformModel READ platformModel CONSTANT)

public:
    explicit SciModel(QObject *parent = nullptr);
    virtual ~SciModel();

    strata::BoardManager* boardManager();
    SciDatabaseConnector* databaseConnector();
    SciPlatformModel* platformModel();

private:
    strata::BoardManager boardManager_;
    SciDatabaseConnector db_;
    SciPlatformModel platformModel_;
};
