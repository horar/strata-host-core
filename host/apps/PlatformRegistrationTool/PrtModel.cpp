#include "PrtModel.h"
#include "logging/LoggingQtCategories.h"

PrtModel::PrtModel(QObject *parent)
    : QObject(parent)
{
    boardManager_.init();
}

PrtModel::~PrtModel()
{
}

strata::BoardManager *PrtModel::boardManager()
{
    return &boardManager_;
}
