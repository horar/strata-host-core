#include "logging/LoggingQtCategories.h"

#include "CoreUpdate.h"
#include "Database.h"

#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonValue>
#include <QJsonObject>

void CoreUpdate::setDatabase(Database* db) {
    db_ = db;
}

void CoreUpdate::handleCoreUpdateResponse(const QByteArray &clientId, const QString &latest_version) {
    emit versionInfoResponseRequested(clientId, latest_version);
}

void CoreUpdate::requestVersionInfo(const QByteArray &clientId) {
    // Retrieve version info from DB, return to UI/client
    std::string latest_version_body;
    if (db_->getDocument("latest_version", latest_version_body) == false) {
        qCCritical(logCategoryHcs) << "latest_version document not found";
        handleCoreUpdateResponse(clientId, QString());
        return;
    }

    QJsonParseError parseError;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(latest_version_body.c_str(), &parseError);
    if (parseError.error != QJsonParseError::NoError ) {
        qCCritical(logCategoryHcs) << "Parse error: " << parseError.errorString();
        handleCoreUpdateResponse(clientId, QString());
        return;
    }

    QJsonObject jsonObj = jsonDoc.object();
    QString latest_version_string = jsonObj.value("latest_version").toString();

    handleCoreUpdateResponse(clientId, latest_version_string);
}