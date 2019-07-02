#include "PrtModel.h"
#include "logging/LoggingQtCategories.h"

PrtModel::PrtModel(QObject *parent)
    : QObject(parent)
{
    boardController_.initialize();
}

PrtModel::~PrtModel()
{
}

BoardsController *PrtModel::boardController()
{
    return &boardController_;
}
