#include "SciModel.h"
#include "logging/LoggingQtCategories.h"

SciModel::SciModel(QObject *parent)
    : QObject(parent)
{
    boardManager_.init();

//disabled until remote db is ready
//    bool result = db_.open("sci_db");
//    if (!result) {
//        qCCritical(logCategorySci) << "Failed to open database.";
//        return;
//    }

//    result = db_.initReplicator("ws://localhost:4984/spyglass");
//    if (!result) {
//        qCCritical(logCategorySci) << "Failed to initialize replicator.";
//        return;
//    }
}

SciModel::~SciModel()
{
}

spyglass::BoardManager *SciModel::boardManager()
{
    return &boardManager_;
}

SciDatabaseConnector *SciModel::databaseConnector()
{
    return &db_;
}
