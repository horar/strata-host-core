#include "logging/LoggingQtCategories.h"

#include "CoreUpdate.h"

#include <iostream>

void CoreUpdate::setDatabase(Database* db) {
    db_ = db;
}

void CoreUpdate::requestVersionInfo(const QByteArray &clientId) {
    qCWarning(logCategoryHcs) << "{VICTOR} Inside CoreUpdate::requestVersionInfo";

    // retrieve version info from DB, return to UI/client
}