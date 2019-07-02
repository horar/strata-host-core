#ifndef SCIMODEL_H
#define SCIMODEL_H

#include <BoardsController.h>

#include <QObject>

class SciModel : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SciModel)

    Q_PROPERTY(BoardsController* boardController READ boardController CONSTANT)
public:
    explicit SciModel(QObject *parent = nullptr);
    virtual ~SciModel();

    BoardsController* boardController();

private:
    BoardsController boardController_;
};

#endif  // SCIMODEL_H
