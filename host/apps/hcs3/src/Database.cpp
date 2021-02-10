#include "Database.h"
#include "Dispatcher.h"

#include "logging/LoggingQtCategories.h"

#include <DatabaseManager.h>
#include <string>

#include <QDir>

Database::Database(QObject *parent)
    : QObject(parent){
}

Database::~Database()
{
    stop();
}

bool Database::open(std::string_view db_path, const std::string& db_name, const std::string& replUrl, const std::string& username, const std::string& password)
{
    if (databaseManager_ != nullptr) {
        return false;
    }

    // TODO: use replUrl, username, password. Hardcoded for development only
    const QString endpointURL_ = "ws://10.0.0.157:4984/platform-list";

    auto documentListenerCallback = std::bind(&Database::documentListener, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);

    databaseManager_ = std::make_unique<DatabaseManager>(QString::fromStdString(std::string(db_path)), endpointURL_, nullptr, documentListenerCallback);
    DB_ = databaseManager_->login("user_public", "channel_public", nullptr, documentListenerCallback);

    if (DB_ == nullptr) {
        qCCritical(logCategoryHcsDb) << "Failed to open database";
        return false;
    }

    return true;
}

void Database::documentListener(cbl::Replicator, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents) {
    qCCritical(logCategoryHcsDb) << "---" << documents.size() << "docs" << (isPush ? "pushed" : "pulled");
    for (unsigned i = 0; i < documents.size(); ++i) {
        emit documentUpdated(QString::fromStdString(documents[i].ID));
    }
}

// TODO: refactor function or remove
bool Database::addReplChannel(const std::string& channel)
{
    return true;
}

// TODO: refactor function or remove
bool Database::remReplChannel(const std::string& channel)
{
    return true;
}

// TODO: refactor function or remove
void Database::updateChannels()
{
}

bool Database::getDocument(const std::string& doc_id, std::string& result)
{
    if (DB_ == nullptr) {
        return false;
    }

    QString myQStr = DB_->getDocumentAsStr(QString::fromStdString(doc_id), "channel_public");
    result = myQStr.toStdString();

    return true;
}

// TODO: implement
void Database::stop()
{

}

void Database::onDocumentEnd(bool /*pushing*/, std::string doc_id, std::string /*error_message*/, bool /*is_error*/, bool /*error_is_transient*/)
{
    emit documentUpdated(QString::fromStdString(doc_id));
}
