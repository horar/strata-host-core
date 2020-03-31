#ifndef PRTMODEL_H
#define PRTMODEL_H

#include <BoardManager.h>

#include <QObject>

class PrtModel : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(PrtModel)

    Q_PROPERTY(strata::BoardManager* boardManager READ boardManager CONSTANT)

public:
    explicit PrtModel(QObject *parent = nullptr);
    virtual ~PrtModel();

    strata::BoardManager *boardManager();

private:
    strata::BoardManager boardManager_;
};

#endif  // PRTMODEL_H
