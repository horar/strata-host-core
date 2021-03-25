#include "SciModel.h"
#include "logging/LoggingQtCategories.h"

SciModel::SciModel(QObject *parent)
    : QObject(parent),
      platformModel_(&platformManager_)
{
    platformManager_.init(true, true);

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

strata::PlatformManager *SciModel::platformManager()
{
    return &platformManager_;
}

SciDatabaseConnector *SciModel::databaseConnector()
{
    return &db_;
}

SciPlatformModel *SciModel::platformModel()
{
    return &platformModel_;
}
