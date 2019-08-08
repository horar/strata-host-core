#include "DatabaseImpl.h"
#include "ConfigManager.h"

#include <QDir>
#include <QJsonArray>

#include <couchbaselitecpp/SGFleece.h>
#include <couchbaselitecpp/SGCouchBaseLite.h>

using namespace fleece;
using namespace fleece::impl;
using namespace std;
using namespace Spyglass;

DatabaseImpl::DatabaseImpl(QObject *parent, const bool &mgr) : QObject (parent), cb_browser_("cb_browser")
{
    if(mgr) {
        config_mgr_ = make_unique<ConfigManager>();
        emit jsonConfigChanged();
    }
}

DatabaseImpl::~DatabaseImpl()
{
    closeDB();
}

void DatabaseImpl::openDB(QString file_path)
{
    if(file_path.isEmpty()) {
        qCCritical(cb_browser_) << "Attempted to open database but received empty file path.";
        return;
    }

    file_path.replace("file://","");
    qCInfo(cb_browser_) << "Attempting to open database with file path " << file_path;

    if(file_path.at(0) == "/" && file_path.at(0) != QDir::separator()) {
        file_path.remove(0, 1);
    }

    file_path.replace("/", QDir::separator());
    file_path_ = file_path;
    QDir dir(file_path_);
    QFileInfo info(file_path_);

    if(!info.exists()) {
        qCCritical(cb_browser_) << "Attempting to open database but file was not found: " << file_path;
    }

    if(info.fileName() != "db.sqlite3" || !dir.cdUp()) {
        qCCritical(cb_browser_) << "Problem with path to database file: " << file_path_;
        setMessage(MessageType::Error, "Problem with path to database file. The file must be located according to: \".../db/(db_name)/db.sqlite3\".");
        return;
    }

    QString dir_name = dir.dirName();

    if(!dir.cdUp() || !dir.cdUp()) {
        qCCritical(cb_browser_) << "Problem with path to database file: " << file_path_;
        setMessage(MessageType::Error, "Problem with path to database file. The file must be located according to: \".../db/(db_name)/db.sqlite3\".");
        return;
    }

    if(isDBOpen()) {
        closeDB();
    }

    setDBName(dir_name);
    setDBPath(dir.path() + QDir::separator());

    sg_db_ = make_unique<SGDatabase>(db_name_.toStdString(), db_path_.toStdString());

    setDBstatus(false);
    setRepstatus(false);
    listened_channels_.clear();

    if(!sg_db_ || sg_db_->open() != SGDatabaseReturnStatus::kNoError || !sg_db_->isOpen()) {
        qCCritical(cb_browser_) << "Problem with initialization of database.";
        setMessage(MessageType::Error,"Problem with initialization of database.");
        return;
    }

    setDBstatus(true);
    getChannelSuggestions();
    setAllChannelsStr();
    emitUpdate();

   if(config_mgr_) {
       config_mgr_->addDBToConfig(getDBName(), file_path);
       emit jsonConfigChanged();
   }

    qCInfo(cb_browser_) << "Successfully opened database '" << getDBName() << "'.";
    setMessage(MessageType::Success, "Successfully opened database '" + getDBName() + "'.");
}

void DatabaseImpl::deleteConfigEntry(const QString &db_name)
{
    if(!config_mgr_) {
        qCCritical(cb_browser_) << "Unable to delete Config database entry '" << db_name << "'.";
        setMessage(MessageType::Error, "Unable to delete Config database entry '" + db_name + "'.");
        return;
    }

    if(config_mgr_->deleteConfigEntry(db_name)) {
        setMessage(MessageType::Success, "Successfully deleted Config database entry '" + db_name + "'.");
        emit jsonConfigChanged();
        return;
    }

    qCCritical(cb_browser_) << "Unable to delete Config database entry '" << db_name << "'.";
    setMessage(MessageType::Error, "Unable to delete Config database entry '" + db_name + "'.");
}

void DatabaseImpl::clearConfig()
{
    if(!config_mgr_) {
        qCCritical(cb_browser_) << "Unable to clear Config database.";
        setMessage(MessageType::Error, "Unable to clear Config database.");
        return;
    }

    if(config_mgr_->clearConfig()) {
        qCInfo(cb_browser_) << "Successfully cleared Config database.";
        setMessage(MessageType::Success, "Successfully cleared database suggestions.");
        emit jsonConfigChanged();
        return;
    }

    qCCritical(cb_browser_) << "Unable to clear Config database.";
    setMessage(MessageType::Error, "Unable to clear Config database.");
}

QStringList DatabaseImpl::getChannelSuggestions()
{
    QStringList suggestions;

    if(!isDBOpen()) {
        qCCritical(cb_browser_) << "Attempted to get channel suggestions, but database is not running.";
        return suggestions;
    }

    // Get channels previously used with this DB
    if(config_mgr_) {
        QJsonObject outer_obj = QJsonDocument::fromJson(config_mgr_->getConfigJson().toUtf8()).object();
        QJsonObject inner_obj = outer_obj.value(getDBName()).toObject();
        QJsonValue val = inner_obj.value("channels");
        QJsonArray arr = val.toArray();

        for(const QJsonValue val : arr) {
            suggestions << val.toString();
        }
    }

    if(!setDocumentKeys()) {
        qCCritical(cb_browser_) << "Failed to reset document keys while getting channel suggestions.";
        return suggestions;
    }

    // Get channels from each document in the current DB
    for(const string &iter : document_keys_) {
        SGDocument doc(sg_db_.get(), iter);
        QJsonDocument json_doc = QJsonDocument::fromJson(QString::fromStdString(doc.getBody()).toUtf8());

        if(json_doc.isNull() || json_doc.isEmpty()) {
            qCCritical(cb_browser_) << "Received empty or invalid JSON message.";
            return suggestions;
        }

        QJsonObject obj = json_doc.object();

        if(obj.contains("channels")) {
            QJsonValue val = obj.value("channels");

            if(val.isUndefined() || val.isNull()) {
                continue;
            }

            if(val.isString()) {
                QString element = val.toString();
                element = val.toString();
                if(!element.isEmpty()) {
                    suggestions << element;
                }
            } else if(val.isArray()) {
                QJsonArray arr = val.toArray();
                for(const QJsonValue element : arr) {
                    suggestions << element.toString();
                }
            } else {
                qCCritical(cb_browser_) << "Read 'channels' key of document " << QString::fromStdString(iter) << ", but its value was not a string or array.";
            }
        }
    }

    suggestions.removeDuplicates();
    suggested_channels_ = suggestions;
    return suggestions;
}

void DatabaseImpl::createNewDB(QString folder_path, const QString &db_name)
{
    if(folder_path.isEmpty() || db_name.simplified().isEmpty()) {
        qCCritical(cb_browser_) << "Attempted to create new database, but received empty folder path or database name.";
        setMessage(MessageType::Error, "Attempted to create new database, but received empty folder path or database name.");
        return;
    }

    folder_path.replace("file://","");
    qCInfo(cb_browser_) << "Attempting to create new database '" << db_name << "' with folder path " << folder_path;

    if(folder_path.at(0) == "/" && folder_path.at(0) != QDir::separator()) {
        folder_path.remove(0, 1);
    }

    folder_path.replace("/", QDir::separator());
    QDir dir(folder_path);
    folder_path += QDir::separator();

    if(!dir.isAbsolute() || !dir.mkpath(folder_path)) {
        qCCritical(cb_browser_) << "Problem with path to database file: " + file_path_;
        setMessage(MessageType::Error, "Problem with initialization of database.");
        return;
    }

    file_path_ = folder_path + "db" + QDir::separator() + db_name + QDir::separator() + "db.sqlite3";
    QFileInfo file(file_path_);

    if(file.exists()) {
        qCCritical(cb_browser_) << "Attempted to create new database with name '" << db_name << "', but it already exists in this location.";
        setMessage(MessageType::Error, "Database '" + db_name + "' already exists in the selected location.");
        return;
    }

    if(db_name.contains('\\') || db_name.contains('/')) {
        qCCritical(cb_browser_) << "Database name cannot contain certain characters, such as slashes.";
        setMessage(MessageType::Error, "Database name cannot contain certain characters, such as slashes.");
        return;
    }

    if(getDBStatus()) {
        closeDB();
    }

    setDBName(db_name);
    setDBPath(folder_path);

    sg_db_ = make_unique<SGDatabase>(db_name_.toStdString(), db_path_.toStdString());

    setDBstatus(false);
    setRepstatus(false);

    if(sg_db_ == nullptr || sg_db_->open() != SGDatabaseReturnStatus::kNoError || !sg_db_->isOpen()) {
        qCCritical(cb_browser_) << "Problem with initialization of database.";
        setMessage(MessageType::Error, "Problem with initialization of database.");
        return;
    }

    document_keys_.clear();
    listened_channels_.clear();
    suggested_channels_.clear();
    setDBstatus(true);
    emitUpdate();
    setAllChannelsStr();

    if(config_mgr_) {
        config_mgr_->addDBToConfig(getDBName(),file_path_);
        emit jsonConfigChanged();
    }

    qCInfo(cb_browser_) << "Successfully created database '" << db_name + "'.";
    setMessage(MessageType::Success, "Successfully created database '" + db_name + "'.");
}

void DatabaseImpl::closeDB()
{
    if(!getDBStatus()) {
        setMessage(MessageType::Error, "No open database, cannot close.");
        return;
    }

    setDBstatus(false);
    stopListening();
    document_keys_.clear();
    listened_channels_.clear();
    suggested_channels_.clear();
    qCInfo(cb_browser_) << "Successfully closed database '" << getDBName() << "'.";
    setMessage(MessageType::Success,"Successfully closed database '" + getDBName() + "'.");
    setDBName("");
    JsonDBContents_ = "{}";
    emit jsonDBContentsChanged();
}

void DatabaseImpl::emitUpdate()
{
    if(setDocumentKeys()) {
        setJSONResponse(document_keys_);
    }

    emit jsonDBContentsChanged();
    qCInfo(cb_browser_) << "Emitted update to UI.";
}

bool DatabaseImpl::stopListening()
{
    if(sg_replicator_ && getListenStatus()) {
        manual_replicator_stop_ = true;
        sg_replicator_->stop();
    }

    setRepstatus(false);
    suggested_channels_ += listened_channels_;
    suggested_channels_.removeDuplicates();
    listened_channels_.clear();
    setAllChannelsStr();

    return true;
}

void DatabaseImpl::createNewDoc(const QString &id, const QString &body)
{
    if(!isDBOpen()) {
        qCCritical(cb_browser_) << "Attempted to create document " << id << " but database is not open.";
        return;
    }

    if(id.isEmpty() || body.isEmpty()) {
        setMessage(MessageType::Error, "ID and body contents of document may not be empty.");
        return;
    }

    SGMutableDocument newDoc(sg_db_.get(), id.toStdString());

    if(newDoc.exist()) {
        setMessage(MessageType::Error, "A document with ID '" + id + "' already exists. Modify the ID and try again.");
        return;
    }

    if(!newDoc.setBody(body.toStdString())) {
        setMessage(MessageType::Error, "Error setting content of created document. Body must be in JSON format.");
        return;
    }

    if(sg_db_->save(&newDoc) != SGDatabaseReturnStatus::kNoError) {
        setMessage(MessageType::Error, "Error saving document to database.");
        return;
    }

    getChannelSuggestions();
    setAllChannelsStr();
    searchDocByChannel(toggled_channels_);
    qCInfo(cb_browser_) << "Successfully created document '" << id << "'.";
    setMessage(MessageType::Success, "Successfully created document '" + id + "'.");
}

bool DatabaseImpl::startListening(QString url, QString username, QString password, QString rep_type, vector<QString> channels)
{
    if(url.isEmpty()) {
        setMessage(MessageType::Error, "URL may not be empty.");
        return false;
    }

    if(!isDBOpen()) {
        setMessage(MessageType::Error, "Database must be open and running for replication to be activated.");
        return false;
    }

    if(getListenStatus()) {
        setMessage(MessageType::Error, "Replicator is already running, cannot start again.");
        return false;
    }

    url_ = url;
    username_ = username;
    password_ = password;
    rep_type_ = rep_type;
    listened_channels_.clear();

    for(const QString &chan : channels) {
        listened_channels_ << chan;
    }

    url_endpoint_ = make_unique<SGURLEndpoint>(url_.toStdString());

    if(!url_endpoint_ || !url_endpoint_->init()) {
        setMessage(MessageType::Error, "Invalid URL endpoint.");
        return false;
    }

    sg_replicator_configuration_ = make_unique<SGReplicatorConfiguration>(sg_db_.get(), url_endpoint_.get());

    if(!sg_replicator_configuration_) {
        setMessage(MessageType::Error, "Problem with start of replicator.");
        return false;
    }

    if(rep_type_ == "pull") {
        sg_replicator_configuration_->setReplicatorType(SGReplicatorConfiguration::ReplicatorType::kPull);
    } else if(rep_type_ == "push") {
        sg_replicator_configuration_->setReplicatorType(SGReplicatorConfiguration::ReplicatorType::kPush);
    } else if(rep_type_ == "pushpull") {
        sg_replicator_configuration_->setReplicatorType(SGReplicatorConfiguration::ReplicatorType::kPushAndPull);
    } else {
        setMessage(MessageType::Error, "Unidentified replicator type selected.");
        return false;
    }

    if(!username_.isEmpty() && !password_.isEmpty()) {
        sg_basic_authenticator_ = make_unique<SGBasicAuthenticator>(username_.toStdString(),password_.toStdString());
        if(!sg_basic_authenticator_) {
            setMessage(MessageType::Error, "Problem with authentication.");
            return false;
        }
        sg_replicator_configuration_->setAuthenticator(sg_basic_authenticator_.get());
    }

    if(!sg_replicator_configuration_->isValid()) {
        setMessage(MessageType::Error, "Problem with authentication.");
        return false;
    }

    vector<string> chan_strvec{};

    for(const QString &chan : listened_channels_) {
        chan_strvec.push_back(chan.toStdString());
    }

    if(!chan_strvec.empty()) {
        sg_replicator_configuration_->setChannels(chan_strvec);
    }

    sg_replicator_ = make_unique<SGReplicator>(sg_replicator_configuration_.get());

    if(!sg_replicator_) {
        setMessage(MessageType::Error, "Problem with start of replicator.");
        return false;
    }

    sg_replicator_->addChangeListener(bind(&DatabaseImpl::repStatusChanged, this, placeholders::_1));
    manual_replicator_stop_ = false;
    replicator_first_connection_ = true;

    if(sg_replicator_->start() != SGReplicatorReturnStatus::kNoError) {
        setMessage(MessageType::Error, "Problem with start of replicator.");
        return false;
    }

    if(config_mgr_) {
        config_mgr_->addRepToConfigDB(db_name_, url_, username_, rep_type_, chan_strvec);
    }

    emit jsonConfigChanged();
    return true;
}

void DatabaseImpl::repStatusChanged(const SGReplicator::ActivityLevel &level)
{
    if(!sg_replicator_ || !isDBOpen()) {
        qCCritical(cb_browser_) << "Attempted to update status of replicator, but replicator is not running.";
        return;
    }

    switch(level) {
        case SGReplicator::ActivityLevel::kStopped:
            activity_level_ = "Stopped";

            if(!manual_replicator_stop_) {
                qCCritical(cb_browser_) << "Replicator activity level changed to 'Stopped' (Problems connecting with replication service)";
                setMessage(MessageType::Error, "Problems connecting with replication service.");
            }
            else {
                qCInfo(cb_browser_) << "Successfully stopped replicator.";
                setMessage(MessageType::Success, "Successfully stopped replicator.");
            }

            manual_replicator_stop_ = false;
            sg_replicator_->stop();
            setRepstatus(false);
            listened_channels_.clear();
            break;
        case SGReplicator::ActivityLevel::kIdle:
            activity_level_ = "Idle";
            setRepstatus(true);
            qCInfo(cb_browser_) << "Replicator activity level changed to 'Idle'";
            setMessage(MessageType::Success, "Successfully received updates.");
            getChannelSuggestions();
            setAllChannelsStr();
            break;
        case SGReplicator::ActivityLevel::kBusy:
            activity_level_ = "Busy";
            setRepstatus(true);
            qCInfo(cb_browser_) << "Replicator activity level changed to 'Busy'";
            break;
        default:
            qCCritical(cb_browser_) << "Received unknown activity level.";
    }

    if(level != SGReplicator::ActivityLevel::kStopped && replicator_first_connection_) {
        qCInfo(cb_browser_) << "Successfully started replicator.";
        setMessage(MessageType::Success, "Successfully started replicator.");
    }

    replicator_first_connection_ = false;
    emit activityLevelChanged();
    emitUpdate();
}

void DatabaseImpl::editDoc(QString oldId, QString newId, QString body)
{
    if(!isDBOpen()) {
        qCCritical(cb_browser_) << "Attempted to edit document '" << oldId << "' but database is not open.";
        setMessage(MessageType::Error, "Attempted to edit document '" + oldId + "' but database is not open.");
        return;
    }

    if(oldId.isEmpty()) {
        qCCritical(cb_browser_) << "Received empty existing document ID, cannot edit.";
        setMessage(MessageType::Error, "Received empty existing document ID, cannot edit.");
        return;
    }

    if(find(document_keys_.begin(), document_keys_.end(), oldId.toStdString()) == document_keys_.end()) {
        qCCritical(cb_browser_) << "Attempted to edit document '" << oldId << "' but it does not exist in the database.";
        setMessage(MessageType::Error, "Attempted to edit document '" + oldId + "' but it does not exist in the database.");
        return;
    }

    oldId = oldId.simplified();
    newId = newId.simplified();

    if(newId.isEmpty() && body.isEmpty()) {
        qCInfo(cb_browser_) << "Received empty new ID and body, nothing to edit.";
        setMessage(MessageType::Error, "Received empty new ID and body, nothing to edit.");
        return;
    }

    // Only need to edit body (no need to re-create document)
    if(newId.isEmpty() || newId == oldId) {
        SGMutableDocument doc(sg_db_.get(),oldId.toStdString());
        doc.setBody(body.toStdString());
        if(sg_db_->save(&doc) != SGDatabaseReturnStatus::kNoError) {
            qCCritical(cb_browser_) << "Error saving document to database.";
            setMessage(MessageType::Error, "Error saving document to database.");
            return;
        }
    }
    // Other case: need to edit ID
    else {
        // If the given body is empty, use the body of the old document
        if(body.isEmpty()) {
            SGDocument doc(sg_db_.get(),oldId.toStdString());
            body = QString::fromStdString(doc.getBody());
        }

        // Create new doc with new ID and body, then delete old doc
        createNewDoc(newId, body);
        if(!isJsonMsgSuccess(message_)) {
            qCCritical(cb_browser_) << "Error editing document " << oldId << "'.";
            setMessage(MessageType::Error, "Error editing document " + oldId + ".");
            return;
        }

        // Delete existing document with ID = OLD ID
        deleteDoc(oldId);
        if(!isJsonMsgSuccess(message_)) {
            qCCritical(cb_browser_) << "Error editing document " << oldId << "'.";
            setMessage(MessageType::Error, "Error editing document '" + oldId + "'.");
            return;
        }
    }

    getChannelSuggestions();
    setAllChannelsStr();

    searchDocByChannel(toggled_channels_);

    if(newId.isEmpty() || newId == oldId) {
        qCInfo(cb_browser_) << "Successfully edited document '" << oldId << "'.";
        setMessage(MessageType::Success, "Successfully edited document '" + oldId + "'.");
    } else {
        if(!getListenStatus()) {
            qCInfo(cb_browser_) << "Successfully edited document (" << oldId << " -> " << newId << ").";
            setMessage(MessageType::Success, "Successfully edited document (" + oldId + " -> " + newId + ").");
        } else {
            qCInfo(cb_browser_) << "Successfully edited document (" << oldId << " -> " << newId << ").";
            setMessage(MessageType::Warning, "Successfully edited document (" + oldId + " -> " + newId + "). Local changes (document edition) may not reflect on remote server.");
        }
    }
}

bool DatabaseImpl::isJsonMsgSuccess(const QString &msg)
{
    QJsonObject obj = QJsonDocument::fromJson(msg.toUtf8()).object();
    return obj.value("status").toString() == "success";
}

void DatabaseImpl::deleteDoc(QString id)
{
    if(!isDBOpen()) {
        qCCritical(cb_browser_) << "Attempted to delete document " << id << " but database is not open.";
        return;
    }

    if(id.isEmpty()) {
        qCCritical(cb_browser_) << "Received empty document ID, cannot delete.";
        setMessage(MessageType::Error, "Received empty document ID, cannot delete.");
        return;
    }

    SGDocument doc(sg_db_.get(), id.toStdString());

    if(!doc.exist()) {
        setMessage(MessageType::Error, "Document with ID = '" + id + "' does not exist. Cannot delete.");
        return;
    }

    if(sg_db_->deleteDocument(&doc) != SGDatabaseReturnStatus::kNoError) {
        qCCritical(cb_browser_) << "Error deleting document " << id << ".";
        setMessage(MessageType::Error, "Error deleting document " + id + ".");
        return;
    }

    getChannelSuggestions();
    setAllChannelsStr();
    searchDocByChannel(toggled_channels_);
    qCInfo(cb_browser_) << "Successfully deleted document '" + id + "'.";

    if(!getListenStatus()) {
        setMessage(MessageType::Success, "Successfully deleted document '" + id + "'.");
    } else {
        setMessage(MessageType::Warning, "Successfully deleted document '" + id + "'. Local changes (document deletion) may not reflect on remote server.");
    }
}

void DatabaseImpl::saveAs(QString path, QString db_name)
{
    if(path.isEmpty() || db_name.isEmpty()) {
        qCCritical(cb_browser_) << "Received empty ID or path, unable to save.";
        setMessage(MessageType::Error, "Received empty ID or path, unable to save.");
        return;
    }

    if(!isDBOpen()) {
        qCCritical(cb_browser_) << "Database must be open for it to be saved elsewhere.";
        setMessage(MessageType::Error, "Database must be open for it to be saved elsewhere.");
        return;
    }

    path.replace("file://","");
    qCInfo(cb_browser_) << "Attempting to save database '" << getDBName() << "' to path " << path << " and name '" << db_name << "'.";

    if(path.at(0) == "/" && path.at(0) != QDir::separator()) {
        path.remove(0, 1);
    }

    path.replace("/", QDir::separator());
    QDir dir(path);
    path = dir.path() + QDir::separator();

    if(!dir.exists() || !dir.isAbsolute()) {
        qCCritical(cb_browser_) << "Received invalid path, unable to save.";
        setMessage(MessageType::Error,"Received invalid path, unable to save.");
        return;
    }

    SGDatabase temp_db(db_name.toStdString(), path.toStdString());

    if(temp_db.open() != SGDatabaseReturnStatus::kNoError || !temp_db.isOpen()) {
        qCCritical(cb_browser_) << "Problem saving database.";
        setMessage(MessageType::Error, "Problem saving database.");
        return;
    }

    for(const string &iter : document_keys_) {
        SGMutableDocument temp_doc(&temp_db, iter);
        SGDocument existing_doc(sg_db_.get(), iter);
        temp_doc.setBody(existing_doc.getBody());
        temp_db.save(&temp_doc);
    }

    if(config_mgr_) {
        path += QString("db") + QDir::separator() + db_name + QDir::separator() + "db.sqlite3";
        config_mgr_->addDBToConfig(db_name, path);
        emit jsonConfigChanged();
    }

    qCInfo(cb_browser_) << "Saved database '" << db_name << "' successfully.";
    setMessage(MessageType::Success, "Saved database '" + db_name + "' successfully.");
}

bool DatabaseImpl::setDocumentKeys()
{
    document_keys_.clear();

    if(!sg_db_->getAllDocumentsKey(document_keys_)) {
        qCCritical(cb_browser_) << "Failed to run getAllDocumentsKey().";
        return false;
    }

    return true;
}

void DatabaseImpl::setJSONResponse(vector<string> &docs)
{
    QJsonDocument document_json;
    QJsonObject total_json_message;

    for(const string &iter : docs) {
        SGDocument usbPDDocument(sg_db_.get(), iter);
        document_json = QJsonDocument::fromJson(QString::fromStdString(usbPDDocument.getBody()).toUtf8());
        total_json_message.insert(QString::fromStdString(iter), document_json.object());
    }

    JsonDBContents_ = QJsonDocument(total_json_message).toJson();
}

void DatabaseImpl::setJSONResponse(const QString &response)
{
    JsonDBContents_ = response;
}

void DatabaseImpl::searchDocById(QString id)
{
    if(!isDBOpen()) {
        setMessage(MessageType::Error, "Database must be open to search.");
        return;
    }

    // ID is empty, so return all documents as usual
    if(id.isEmpty()) {
        emitUpdate();
        setMessage(MessageType::Success, "Empty document ID searched, showing all documents.");
        return;
    }

    vector <string> searchMatches{};
    id = id.simplified().toLower();

    for(const string &iter : document_keys_) {
        if(QString::fromStdString(iter).toLower().contains(id)) {
            searchMatches.push_back(iter);
        }
    }

    setJSONResponse(searchMatches);
    emit jsonDBContentsChanged();
    qCInfo(cb_browser_) << "Emitted update to UI.";

    if(searchMatches.size() == 1) {
        setMessage(MessageType::Success, "Found one document with ID containing '" + id + "'.");
        qCInfo(cb_browser_) << "Found one document with ID containing '" << id << "'.";
        return;
    } else if(searchMatches.size() > 0) {
        setMessage(MessageType::Success, "Found " + QString::number(searchMatches.size()) + " documents with ID containing '" + id + "'.");
        qCInfo(cb_browser_) << "Found " << QString::number(searchMatches.size()) << " documents with ID containing '" << id << "'.";
        return;
    }

    setMessage(MessageType::Success, "Found no documents containing ID = '" + id + "'.");
}

void DatabaseImpl::searchDocByChannel(const std::vector<QString> &channels)
{
    if(!getDBStatus()) {
        setMessage(MessageType::Error,"Database must be open to change channel display.");
        return;
    }

    // No channels specified, so return all documents as usual
    if(channels.empty()) {
        emitUpdate();
        setMessage(MessageType::Success, "Showing all documents.");
        return;
    }

    vector <string> channelMatches{};

    // Need to return a JSON response corresponding only to the channels requested
    for(const string &iter : document_keys_) {
        SGDocument doc(sg_db_.get(), iter);
        QJsonDocument json_doc = QJsonDocument::fromJson(QString::fromStdString(doc.getBody()).toUtf8());

        if(json_doc.isNull() || json_doc.isEmpty()) {
            qCCritical(cb_browser_) << "Received empty or invalid JSON message.";
            return;
        }

        QJsonObject obj = json_doc.object();

        if(obj.contains("channels")) {
            QJsonValue val = obj.value("channels");

            if(val.isUndefined() || val.isNull()) {
                continue;
            }

            if(val.isString()) {
                QString element = val.toString();
                if(!element.isEmpty()) {
                    if(find(channels.begin(), channels.end(), element) != channels.end()) {
                        channelMatches.push_back(iter);
                    }
                }
            } else if(val.isArray()) {
                QJsonArray arr = val.toArray();
                for(const QJsonValue element : arr) {
                    if(find(channels.begin(), channels.end(), element.toString()) != channels.end()) {
                        channelMatches.push_back(iter);
                    }
                }
            } else {
                qCCritical(cb_browser_) << "Read 'channels' key of document " << QString::fromStdString(iter) << ", but its value was not a string or array.";
            }
        }
    }

    toggled_channels_.clear();
    toggled_channels_ = channels;
    setJSONResponse(channelMatches);
    emit jsonDBContentsChanged();
    qCInfo(cb_browser_) << "Emitted update to UI: successfully switched channel display.";
    setMessage(MessageType::Success,"Successfully switched channel display.");
}

void DatabaseImpl::setDBstatus(const bool &status)
{
    db_status_ = status;
    emit dbStatusChanged();
}

void DatabaseImpl::setRepstatus(const bool &status)
{
    rep_status_ = status;
    emit listenStatusChanged();
}

void DatabaseImpl::setDBName(const QString &db_name)
{
    db_name_ = db_name;
    emit dbNameChanged();
}

void DatabaseImpl::setMessage(const MessageType &status, QString msg)
{
    if(msg.isEmpty()) {
        qCCritical(cb_browser_) << "The setMessage function received an empty message.";
        return;
    }

    QJsonObject json_message;

    switch(status) {
        case MessageType::Error:
            json_message.insert("status", "error");
            json_message.insert("msg", msg);
            message_ = QJsonDocument(json_message).toJson();
            qCInfo(cb_browser_) << "Emitted error message: " << msg;
            break;
        case MessageType::Success:
            json_message.insert("status", "success");
            json_message.insert("msg", msg);
            message_ = QJsonDocument(json_message).toJson();
            qCInfo(cb_browser_) << "Emitted success message: " << msg;
            break;
        case MessageType::Warning:
            json_message.insert("status", "warning");
            json_message.insert("msg", msg);
            message_ = QJsonDocument(json_message).toJson();
            qCInfo(cb_browser_) << "Emitted warning message: " << msg;
    }

    emit messageChanged();
}

void DatabaseImpl::setDBPath(const QString &db_path)
{
    db_path_ = db_path;
}

QString DatabaseImpl::getDBName() const
{
    return db_name_;
}

QString DatabaseImpl::getJsonDBContents() const
{
    return JsonDBContents_;
}

QString DatabaseImpl::getJsonConfig() const
{
    return config_mgr_ ? config_mgr_->getConfigJson() : "{}";
}

bool DatabaseImpl::getDBStatus() const
{
    return db_status_;
}

bool DatabaseImpl::getListenStatus() const
{
    return isDBOpen() && rep_status_;
}

void DatabaseImpl::setAllChannelsStr()
{
    QJsonObject json_message;
    QStringList listened_channels_copy = listened_channels_;

    if(getListenStatus() && listened_channels_copy.empty() && !suggested_channels_.empty()) {
        listened_channels_copy << suggested_channels_;
    }

    // Add channels to the active channel list (listened_channels_)
    for(const QString &iter : listened_channels_copy) {
        json_message.insert(iter, "active");
    }

    // Add channels to the suggested channel list (suggested_channels_)
    for(const QString &iter : suggested_channels_) {
        if(!listened_channels_copy.contains(iter)) {
            json_message.insert(iter, "suggested");
        }
    }

    JSONChannels_ = QJsonDocument(json_message).toJson();
    emit channelsChanged();
}

QString DatabaseImpl::getAllChannels() const
{
    return JSONChannels_;
}

QString DatabaseImpl::getMessage() const
{
    return message_;
}

QString DatabaseImpl::getActivityLevel() const
{
    return activity_level_;
}

bool DatabaseImpl::isDBOpen() const
{
    return sg_db_ && sg_db_->isOpen() && getDBStatus();
}
