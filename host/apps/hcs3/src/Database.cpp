#include "Database.h"
#include "Dispatcher.h"

#include "logging/LoggingQtCategories.h"

#include <Database/DatabaseManager.h>
#include <string>

#include <QDir>

Database::Database(QObject *parent)
    : QObject(parent){
}

Database::~Database()
{
    stop();
}

bool Database::open(std::string_view db_path, const std::string& db_name)
{
    QString name = QString::fromStdString(db_name);
    QString path_ = QString::fromStdString(std::string(db_path));

    QStringList channelAccess;

    DB_ = new strata::Database::DatabaseAccess();
    DB_->name_ = name;
    DB_->channelAccess_ = channelAccess;

    if (DB_->open(path_, channelAccess) == false) {
        qCCritical(logCategoryHcsDb) << "Failed to open database";
        return false;
    }

    return true;
}

void Database::documentListener(bool isPush, const std::vector<strata::Database::DatabaseAccess::ReplicatedDocument, std::allocator<strata::Database::DatabaseAccess::ReplicatedDocument>> documents) {
    qCCritical(logCategoryHcsDb) << "---" << documents.size() << "docs" << (isPush ? "pushed" : "pulled");
    for (unsigned i = 0; i < documents.size(); ++i) {
        emit documentUpdated(documents[i].id);
    }
}

// TODO: implement function or remove
bool Database::addReplChannel(const std::string& channel)
{
    return true;
}

// TODO: implement function or remove
bool Database::remReplChannel(const std::string& channel)
{
    return true;
}

// TODO: implement function or remove
void Database::updateChannels()
{
}

// TODO: implement
bool Database::getDocument(const std::string& doc_id, std::string& result)
{
    if (DB_ == nullptr) {
        return false;
    }

    QString myQStr = DB_->getDocumentAsStr(QString::fromStdString(doc_id), DB_->getDatabaseName());
    result = myQStr.toStdString();

    return true;
}

// TODO: implement
void Database::stop()
{

}

bool Database::initReplicator(const std::string& replUrl, const std::string& username, const std::string& password)
{
    auto documentListenerCallback = std::bind(&Database::documentListener, this, std::placeholders::_1, std::placeholders::_2);

    DB_->startBasicReplicator(QString::fromStdString(replUrl), QString::fromStdString(username), QString::fromStdString(password), strata::Database::DatabaseAccess::ReplicatorType::Pull, nullptr, documentListenerCallback, true);

    return true;
}
