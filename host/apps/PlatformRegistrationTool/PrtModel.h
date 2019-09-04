#ifndef PRTMODEL_H
#define PRTMODEL_H

#include <BoardsController.h>

#include <QObject>

class PrtModel : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(PrtModel)

    Q_PROPERTY(BoardsController* boardController READ boardController CONSTANT)

public:
    explicit PrtModel(QObject *parent = nullptr);
    virtual ~PrtModel();

    BoardsController* boardController();

private:
    BoardsController boardController_;
};

#endif  // PRTMODEL_H
