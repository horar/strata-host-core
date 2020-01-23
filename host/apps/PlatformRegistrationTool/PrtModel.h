#ifndef PRTMODEL_H
#define PRTMODEL_H

#include <BoardManager.h>

#include <QObject>

class PrtModel : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(PrtModel)

    Q_PROPERTY(spyglass::BoardManager* boardManager READ boardManager CONSTANT)

public:
    explicit PrtModel(QObject *parent = nullptr);
    virtual ~PrtModel();

    spyglass::BoardManager *boardManager();

private:
    spyglass::BoardManager boardManager_;
};

#endif  // PRTMODEL_H
