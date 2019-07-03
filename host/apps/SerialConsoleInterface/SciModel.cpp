#include "SciModel.h"
#include "logging/LoggingQtCategories.h"

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
