#include "SciModel.h"
#include <QDebug>

#include <PlatformConnection.h>
#include "PlatformBoard.h"


SciModel::SciModel(QObject *parent)
    : QObject(parent)
{
    boardController_.initialize();
}

SciModel::~SciModel()
{
}

BoardsController *SciModel::boardController()
{
    return &boardController_;
}
