#ifndef SCIMODEL_H
#define SCIMODEL_H

#include <BoardManager.h>
#include "SciDatabaseConnector.h"

#include <QObject>

class SciModel : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SciModel)

    Q_PROPERTY(spyglass::BoardManager* boardManager READ boardManager CONSTANT)
    Q_PROPERTY(SciDatabaseConnector* databaseConnector READ databaseConnector CONSTANT)

public:
    explicit SciModel(QObject *parent = nullptr);
    virtual ~SciModel();

    spyglass::BoardManager* boardManager();
    SciDatabaseConnector* databaseConnector();

private:
    spyglass::BoardManager boardManager_;
    SciDatabaseConnector db_;
};

#endif  // SCIMODEL_H
