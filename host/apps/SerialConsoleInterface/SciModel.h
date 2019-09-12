#ifndef SCIMODEL_H
#define SCIMODEL_H

#include <BoardsController.h>
#include "SciDatabaseConnector.h"

#include <QObject>

class SciModel : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SciModel)

    Q_PROPERTY(BoardsController* boardController READ boardController CONSTANT)
    Q_PROPERTY(SciDatabaseConnector* databaseConnector READ databaseConnector CONSTANT)

public:
    explicit SciModel(QObject *parent = nullptr);
    virtual ~SciModel();

    BoardsController* boardController();
    SciDatabaseConnector* databaseConnector();

private:
    BoardsController boardController_;
    SciDatabaseConnector db_;
};

#endif  // SCIMODEL_H
