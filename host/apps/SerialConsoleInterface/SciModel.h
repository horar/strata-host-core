#ifndef SCIMODEL_H
#define SCIMODEL_H

#include <QObject>
#include <PlatformManager.h>
#include "BoardsController.h"

class SciModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(BoardsController* boardController READ boardController CONSTANT)

public:
    explicit SciModel(QObject *parent = nullptr);
    virtual ~SciModel();

    BoardsController* boardController();

private:
    Q_DISABLE_COPY(SciModel)

    BoardsController boardController_;
};

#endif  // SCIMODEL_H
