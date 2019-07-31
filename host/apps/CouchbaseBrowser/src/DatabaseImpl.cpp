#include "DatabaseImpl.h"
#include "ConfigManager.h"

#include <QCoreApplication>
#include <QDir>
#include <QJsonArray>

#include "SGFleece.h"
#include "SGCouchBaseLite.h"

using namespace fleece;
using namespace fleece::impl;

using namespace std;

using namespace placeholders;
using namespace Spyglass;

DatabaseImpl::DatabaseImpl(QObject *parent, bool mgr) : QObject (parent), cb_browser("cb_browser")
{
    if(mgr) {
        config_mgr = new ConfigManager;
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
        qCCritical(cb_browser) << "Attempted to open database but received empty file path.";
        return;
    }

    if(isDBOpen()) {
        closeDB();
    }

    file_path.replace(" ", "\ ");
    file_path.replace("file://","");
    qCInfo(cb_browser) << "Attempting to open database with file path " << file_path;

    if(file_path.at(0) == "/" && file_path.at(0) != QDir::separator()) {
        file_path.remove(0, 1);
    }

    file_path.replace("/", QDir::separator());
    file_path_ = file_path;
    QDir dir(file_path_);
    QFileInfo info(file_path_);

    if(!info.exists()) {
        qCCritical(cb_browser) << "Attempting to open database but file was not found: " << file_path;
    }

    if(info.fileName() != "db.sqlite3" || !dir.cdUp()) {
        qCCritical(cb_browser) << "Problem with path to database file: " << file_path_;
        setMessage(0, "Problem with path to database file. The file must be located according to: \".../db/(db_name)/db.sqlite3\".");
        return;
    }

    setDBName(dir.dirName());

    if(!dir.cdUp() || !dir.cdUp()) {
        qCCritical(cb_browser) << "Problem with path to database file: " << file_path_;
        setMessage(0, "Problem with path to database file. The file must be located according to: \".../db/(db_name)/db.sqlite3\".");
        return;
    }

    setDBPath(dir.path() + QDir::separator());
    sg_db_ = new SGDatabase(db_name_.toStdString(), db_path_.toStdString());
    setDBstatus(false);
    setRepstatus(false);
    listened_channels_.clear();

    if (sg_db_ == nullptr || sg_db_->open() != SGDatabaseReturnStatus::kNoError || !sg_db_->isOpen()) {
        qCCritical(cb_browser) << "Problem with initialization of database.";
        setMessage(0,"Problem with initialization of database.");
        return;
    }

    setDBstatus(true);
    getChannelSuggestions();
    setAllChannelsStr();
    emitUpdate();

   if(config_mgr) {
       config_mgr->addDBToConfig(getDBName(),file_path);
       emit jsonConfigChanged();
   }

    qCInfo(cb_browser) << "Successfully opened database '" << getDBName() << "'.";
    setMessage(1, "Successfully opened database '" + getDBName() + "'.");
}

void DatabaseImpl::deleteConfigEntry(QString db_name)
{
    if(!config_mgr) {
        setMessage(0, "Unable to delete Config database entry '" + db_name + "'.");
        return;
    }

    if(config_mgr->deleteConfigEntry(db_name)) {
        setMessage(1, "Successfully deleted Config database entry '" + db_name + "'.");
        emit jsonConfigChanged();
        return;
    }

    setMessage(0, "Unable to delete Config database entry '" + db_name + "'.");
}

void DatabaseImpl::clearConfig()
{
    if(!config_mgr) {
        qCCritical(cb_browser) << "Unable to clear Config database.";
        setMessage(0, "Unable to clear database suggestions.");
        return;
    }

    if(config_mgr->clearConfig()) {
        qCInfo(cb_browser) << "Successfully cleared Config database.";
        setMessage(1, "Successfully cleared database suggestions.");
        emit jsonConfigChanged();
        return;
    }

    setMessage(0, "Unable to clear Config database.");
}

QStringList DatabaseImpl::getChannelSuggestions()
{
    QStringList suggestions;

    if(!isDBOpen()) {
        qCCritical(cb_browser) << "Attempted to get channel suggestions, but database is not running.";
        return suggestions;
    }

    // Get channels previously used with this DB
    if(config_mgr) {
        QJsonObject outer_obj = QJsonDocument::fromJson(config_mgr->getConfigJson().toUtf8()).object();
        QJsonObject inner_obj = outer_obj.value(getDBName()).toObject();
        QJsonValue val = inner_obj.value("channels");
        QJsonArray arr = val.toArray();

        for(QJsonValue val : arr) {
            suggestions << val.toString();
        }
    }

    setDocumentKeys();

    // Get channels from each document in the current DB
    for(string iter : document_keys_) {
        SGDocument doc(sg_db_, iter);
        QJsonObject obj = QJsonDocument::fromJson(QString::fromStdString(doc.getBody()).toUtf8()).object();

        if(obj.contains("channels")) {
            QJsonValue val = obj.value("channels");
            QString element = val.toString();

            if(!element.isEmpty()) {
                suggestions << element;
            } else {
                QJsonArray arr = val.toArray();
                for(QJsonValue element : arr) {
                    suggestions << element.toString();
                }
            }
        }
    }

    suggestions.removeDuplicates();
    suggested_channels_ = suggestions;
    return suggestions;
}

void DatabaseImpl::createNewDB(QString folder_path, QString db_name)
{
    if(folder_path.isEmpty() || db_name.isEmpty() || db_name.simplified().isEmpty()) {
        qCCritical(cb_browser) << "Attempted to create new database, but received empty folder path or database name.";
        setMessage(0, "Attempted to create new database, but received empty folder path or database name.");
        return;
    }

    if(getDBStatus()) {
        closeDB();
    }

    folder_path.replace(" ", "\ ");
    folder_path.replace("file://","");
    qCInfo(cb_browser) << "Attempting to create new database '" << db_name << "' with folder path " << folder_path;

    if(folder_path.at(0) == "/" && folder_path.at(0) != QDir::separator()) {
        folder_path.remove(0, 1);
    }

    folder_path.replace("/", QDir::separator());
    QDir dir(folder_path);
    folder_path += QDir::separator();

    if(!dir.isAbsolute() || !dir.mkpath(folder_path)) {
        qCCritical(cb_browser) << "Problem with path to database file: " + file_path_;
        setMessage(0, "Problem with initialization of database.");
        return;
    }

    file_path_ = folder_path + "db" + QDir::separator() + db_name + QDir::separator() + "db.sqlite3";
    QFileInfo file(file_path_);

    if(file.exists()) {
        qCCritical(cb_browser) << "Attempted to create new database with name '" << db_name << "', but it already exists in this location.";
        setMessage(0, "Database " + db_name + " already exists in the selected location.");
        return;
    }

    setDBName(db_name);
    setDBPath(folder_path);
    sg_db_ = new SGDatabase(db_name_.toStdString(), db_path_.toStdString());
    setDBstatus(false);
    setRepstatus(false);

    if (sg_db_ == nullptr || sg_db_->open() != SGDatabaseReturnStatus::kNoError || !sg_db_->isOpen()) {
        qCCritical(cb_browser) << "Problem with initialization of database.";
        setMessage(0, "Problem with initialization of database.");
        return;
    }

    document_keys_.clear();
    listened_channels_.clear();
    suggested_channels_.clear();
    setDBstatus(true);
    emitUpdate();
    setAllChannelsStr();

    if(config_mgr) {
        config_mgr->addDBToConfig(getDBName(),file_path_);
        emit jsonConfigChanged();
    }

    qCInfo(cb_browser) << "Successfully created database '" << db_name + "'.";
    setMessage(1, "Successfully created database '" + db_name + "'.");
}

void DatabaseImpl::closeDB()
{
    if(!getDBStatus()) {
        setMessage(0, "No open database, cannot close.");
        return;
    }

    setDBstatus(false);
    stopListening();

    if(sg_replicator_ != nullptr) {
        delete sg_replicator_;
        sg_replicator_ = nullptr;
    }

    if(url_endpoint_ != nullptr) {
        delete url_endpoint_;
        url_endpoint_ = nullptr;
    }

    if(sg_replicator_configuration_ != nullptr) {
        delete sg_replicator_configuration_;
        sg_replicator_configuration_ = nullptr;
    }

    if(sg_basic_authenticator_ != nullptr) {
        delete sg_basic_authenticator_;
        sg_basic_authenticator_ = nullptr;
    }

    if(sg_db_ != nullptr) {
        delete sg_db_;
        sg_db_ = nullptr;
    }

    document_keys_.clear();
    listened_channels_.clear();
    suggested_channels_.clear();
    qCInfo(cb_browser) << "Successfully closed database '" << getDBName() << "'.";
    setMessage(1,"Successfully closed database '" + getDBName() + "'.");
    setDBName("");
    JsonDBContents_ = "{}";
    emit jsonDBContentsChanged();
}

void DatabaseImpl::emitUpdate(bool cache)
{
    if(!cache || all_docs_cached_JsonDBContents_.isEmpty()) {
        if(setDocumentKeys()) {
            setJSONResponse(document_keys_);
            all_docs_cached_JsonDBContents_ = JsonDBContents_;
        }
    }
    else {
        setJSONResponse(all_docs_cached_JsonDBContents_);
    }

    emit jsonDBContentsChanged();
    qCInfo(cb_browser) << "Emitted update to UI.";
}

bool DatabaseImpl::stopListening()
{
    if(sg_replicator_ != nullptr && getListenStatus()) {
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

void DatabaseImpl::createNewDoc(QString id, QString body)
{
    if(!isDBOpen()) {
        qCCritical(cb_browser) << "Attempted to create document " << id << " but database is not open.";
        return;
    }

    if(id.isEmpty() || body.isEmpty()) {
        setMessage(0, "ID and body contents of document may not be empty.");
        return;
    }

    SGMutableDocument newDoc(sg_db_,id.toStdString());

    if(newDoc.exist()) {
        setMessage(0, "A document with ID '" + id + "' already exists. Modify the ID and try again.");
        return;
    }

    if(!newDoc.setBody(body.toStdString())) {
        setMessage(0, "Error setting content of created document. Body must be in JSON format.");
        return;
    }

    if(sg_db_->save(&newDoc) != SGDatabaseReturnStatus::kNoError) {
        setMessage(0, "Error saving document to database.");
        return;
    }

    getChannelSuggestions();
    setAllChannelsStr();
    emitUpdate();
    qCInfo(cb_browser) << "Successfully created document '" << id << "'.";
    setMessage(1, "Successfully created document '" + id + "'.");
}

bool DatabaseImpl::startListening(QString url, QString username, QString password, QString rep_type, vector<QString> channels)
{
    if(url.isEmpty()) {
        setMessage(0, "URL may not be empty.");
        return false;
    }

    if(!isDBOpen()) {
        setMessage(0, "Database must be open and running for replication to be activated.");
        return false;
    }

    if(getListenStatus()) {
        setMessage(0, "Replicator is already running, cannot start again.");
        return false;
    }

    url_ = url;
    username_ = username;
    password_ = password;
    rep_type_ = rep_type;
    listened_channels_.clear();

    for(QString chan : channels) {
        listened_channels_ << chan;
    }

    url_endpoint_ = new SGURLEndpoint(url_.toStdString());

    if(!url_endpoint_->init() || url_endpoint_ == nullptr) {
        setMessage(0, "Invalid URL endpoint.");
        return false;
    }

    sg_replicator_configuration_ = new SGReplicatorConfiguration(sg_db_, url_endpoint_);

    if(sg_replicator_configuration_ == nullptr) {
        setMessage(0, "Problem with start of replicator.");
        return false;
    }

    if(rep_type_ == "pull") {
        sg_replicator_configuration_->setReplicatorType(SGReplicatorConfiguration::ReplicatorType::kPull);
    } else if(rep_type_ == "push") {
        sg_replicator_configuration_->setReplicatorType(SGReplicatorConfiguration::ReplicatorType::kPush);
    } else if(rep_type_ == "pushpull") {
        sg_replicator_configuration_->setReplicatorType(SGReplicatorConfiguration::ReplicatorType::kPushAndPull);
    } else {
        setMessage(0, "Unidentified replicator type selected.");
        return false;
    }

    if(!username_.isEmpty() && !password_.isEmpty()) {
        sg_basic_authenticator_ = new SGBasicAuthenticator(username_.toStdString(),password_.toStdString());
        if(sg_basic_authenticator_ == nullptr) {
            setMessage(0, "Problem with authentication.");
            return false;
        }
        sg_replicator_configuration_->setAuthenticator(sg_basic_authenticator_);
    }

    if(!sg_replicator_configuration_->isValid()) {
        setMessage(0, "Problem with authentication.");
        return false;
    }

    vector<string> chan_strvec{};

    for(QString chan : listened_channels_) {
        chan_strvec.push_back(chan.toStdString());
    }

    if(!chan_strvec.empty()) {
        sg_replicator_configuration_->setChannels(chan_strvec);
    }

    sg_replicator_ = new SGReplicator(sg_replicator_configuration_);

    if(sg_replicator_ == nullptr) {
        setMessage(0, "Problem with start of replicator.");
        return false;
    }

    sg_replicator_->addChangeListener(bind(&DatabaseImpl::repStatusChanged, this, _1));
    manual_replicator_stop_ = false;
    replicator_first_connection_ = true;

    if(sg_replicator_->start() == false) {
        setMessage(0, "Problem with start of replicator.");
        return false;
    }

    if(config_mgr) {
        config_mgr->addRepToConfigDB(db_name_,url_,username_,rep_type_,chan_strvec);
    }

    emit jsonConfigChanged();
    return true;
}

void DatabaseImpl::repStatusChanged(SGReplicator::ActivityLevel level)
{
    if(!isDBOpen() || sg_replicator_ == nullptr) {
        qCCritical(cb_browser) << "Attempted to update status of replicator, but replicator is not running.";
        return;
    }

    switch(level) {
        case SGReplicator::ActivityLevel::kStopped:
            activity_level_ = "Stopped";

            if(!manual_replicator_stop_) {
                qCCritical(cb_browser) << "Replicator activity level changed to 'Stopped' (Problems connecting with replication service)";
                setMessage(0, "Problems connecting with replication service.");
            }
            else {
                qCInfo(cb_browser) << "Successfully stopped replicator.";
                setMessage(1, "Successfully stopped replicator.");
            }

            manual_replicator_stop_ = false;
            sg_replicator_->stop();
            setRepstatus(false);
            listened_channels_.clear();
            break;
        case SGReplicator::ActivityLevel::kIdle:
            activity_level_ = "Idle";
            setRepstatus(true);
            qCInfo(cb_browser) << "Replicator activity level changed to 'Idle'";
            setMessage(1, "Successfully received updates.");
            getChannelSuggestions();
            setAllChannelsStr();
            break;
        case SGReplicator::ActivityLevel::kBusy:
            activity_level_ = "Busy";
            setRepstatus(true);
            qCInfo(cb_browser) << "Replicator activity level changed to 'Busy'";
            break;
        default:
            qCCritical(cb_browser) << "Received unknown activity level.";
    }

    if(level != SGReplicator::ActivityLevel::kStopped && replicator_first_connection_) {
        qCInfo(cb_browser) << "Successfully started replicator.";
        setMessage(1, "Successfully started replicator.");
    }

    replicator_first_connection_ = false;
    emit activityLevelChanged();
    emitUpdate();
}

void DatabaseImpl::editDoc(QString oldId, QString newId, QString body)
{
    if(!isDBOpen()) {
        qCCritical(cb_browser) << "Attempted to edit document " << oldId << " but database is not open.";
        setMessage(0, "Attempted to edit document " + oldId + " but database is not open.");
        return;
    }

    if(oldId.isEmpty()) {
        qCCritical(cb_browser) << "Received empty existing document ID, cannot edit.";
        setMessage(0, "Received empty existing document ID, cannot edit.");
        return;
    }

    if(find(document_keys_.begin(), document_keys_.end(), oldId.toStdString()) == document_keys_.end()) {
        qCCritical(cb_browser) << "Attempted to edit document " << oldId << " but it does not exist in the database.";
        setMessage(0, "Attempted to edit document " + oldId + " but it does not exist in the database.");
        return;
    }

    oldId = oldId.simplified();
    newId = newId.simplified();

    if(newId.isEmpty() && body.isEmpty()) {
        qCInfo(cb_browser) << "Received empty new ID and body, nothing to edit.";
        setMessage(0, "Received empty new ID and body, nothing to edit.");
        return;
    }

    // Only need to edit body (no need to re-create document)
    if(newId.isEmpty() || newId == oldId) {
        SGMutableDocument doc(sg_db_,oldId.toStdString());
        doc.setBody(body.toStdString());
        if(sg_db_->save(&doc) != SGDatabaseReturnStatus::kNoError) {
            qCCritical(cb_browser) << "Error saving document to database.";
            setMessage(0, "Error saving document to database.");
            return;
        }
        emitUpdate();
    }
    // Other case: need to edit ID
    else {
        // If the given body is empty, use the body of the old document
        if(body.isEmpty()) {
            SGDocument doc(sg_db_,oldId.toStdString());
            body = QString::fromStdString(doc.getBody());
        }

        // Create new doc with new ID and body, then delete old doc
        createNewDoc(newId, body);
        if(!isJsonMsgSuccess(message_)) {
            qCCritical(cb_browser) << "Error editing document " << oldId;
            setMessage(0, "Error editing document " + oldId + ".");
            return;
        }

        // Delete existing document with ID = OLD ID
        deleteDoc(oldId);
        if(!isJsonMsgSuccess(message_)) {
            qCCritical(cb_browser) << "Error editing document " << oldId;
            setMessage(0, "Error editing document " + oldId + ".");
            return;
        }
    }

    getChannelSuggestions();
    setAllChannelsStr();

    if(newId.isEmpty() || newId == oldId) {
        qCInfo(cb_browser) << "Successfully edited document '" << oldId << "'.";
        setMessage(1, "Successfully edited document '" + oldId + "'");
    } else {
        if(!getListenStatus()) {
            qCInfo(cb_browser) << "Successfully edited document (" << oldId << " -> " << newId << ").";
            setMessage(1, "Successfully edited document (" + oldId + " -> " + newId + ").");
        } else {
            qCInfo(cb_browser) << "Successfully edited document (" << oldId << " -> " << newId << ").";
            setMessage(2, "Successfully edited document (" + oldId + " -> " + newId + "). Local changes (document edition) may not reflect on remote server.");
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
        qCCritical(cb_browser) << "Attempted to delete document " << id << " but database is not open.";
        return;
    }

    if(id.isEmpty()) {
        qCCritical(cb_browser) << "Received empty document ID, cannot delete.";
        setMessage(0, "Received empty document ID, cannot delete.");
        return;
    }

    SGDocument doc(sg_db_,id.toStdString());

    if(!doc.exist()) {
        setMessage(0, "Document with ID = '" + id + "' does not exist. Cannot delete.");
        return;
    }

    sg_db_->deleteDocument(&doc);
    emitUpdate();
    qCInfo(cb_browser) << "Successfully deleted document '" + id + "'.";

    if(!getListenStatus()) {
        setMessage(1, "Successfully deleted document '" + id + "'.");
    } else {
        setMessage(2, "Successfully deleted document '" + id + "'. Local changes (document deletion) may not reflect on remote server.");
    }
}

void DatabaseImpl::saveAs(QString path, QString db_name)
{
    if(path.isEmpty() || db_name.isEmpty()) {
        qCCritical(cb_browser) << "Received empty ID or path, unable to save.";
        setMessage(0, "Received empty ID or path, unable to save.");
        return;
    }

    if(!isDBOpen()) {
        qCCritical(cb_browser) << "Database must be open for it to be saved elsewhere.";
        setMessage(0, "Database must be open for it to be saved elsewhere.");
        return;
    }

    path.replace(" ", "\ ");
    path.replace("file://","");
    qCInfo(cb_browser) << "Attempting to save database '" << getDBName() << "' to path " << path << " and name '" << db_name << "'.";

    if(path.at(0) == "/" && path.at(0) != QDir::separator()) {
        path.remove(0, 1);
    }

    path.replace("/", QDir::separator());
    QDir dir(path);
    path = dir.path() + QDir::separator();

    if(!dir.exists() || !dir.isAbsolute()) {
        qCCritical(cb_browser) << "Received invalid path, unable to save.";
        setMessage(0,"Received invalid path, unable to save.");
        return;
    }

    SGDatabase temp_db(db_name.toStdString(), path.toStdString());

    if(temp_db.open() != SGDatabaseReturnStatus::kNoError || !temp_db.isOpen()) {
        qCCritical(cb_browser) << "Problem saving database.";
        setMessage(0, "Problem saving database.");
        return;
    }

    for(string iter : document_keys_) {
        SGMutableDocument temp_doc(&temp_db, iter);
        SGDocument existing_doc(sg_db_, iter);
        temp_doc.setBody(existing_doc.getBody());
        temp_db.save(&temp_doc);
    }

    if(config_mgr) {
        path += QString("db") + QDir::separator() + db_name + QDir::separator() + "db.sqlite3";
        config_mgr->addDBToConfig(db_name, path);
        emit jsonConfigChanged();
    }

    qCInfo(cb_browser) << "Saved database " << db_name << " successfully.";
    setMessage(1, "Saved database " + db_name + " successfully.");
}

bool DatabaseImpl::setDocumentKeys()
{
    document_keys_.clear();

    if(!sg_db_->getAllDocumentsKey(document_keys_)) {
        qCCritical(cb_browser) << "Failed to run getAllDocumentsKey().";
        return false;
    }

    return true;
}

void DatabaseImpl::setJSONResponse(vector<string> &docs)
{
    QString temp_str = "";
    JsonDBContents_ = "{";

    for(string iter : docs) {
        SGDocument usbPDDocument(sg_db_, iter);
        temp_str = "\"" + QString::fromStdString(iter)  + "\":" + QString::fromStdString(usbPDDocument.getBody()) + ",";
        JsonDBContents_ += temp_str;
    }

    if(JsonDBContents_.length() > 1) {
        JsonDBContents_.chop(1);
    }

    JsonDBContents_ += "}";
}

void DatabaseImpl::setJSONResponse(const QString &response)
{
    JsonDBContents_ = response;
}

void DatabaseImpl::searchDocById(QString id)
{
    if(!isDBOpen()) {
        setMessage(0,"Database must be open to search.");
        return;
    }

    // ID is empty, so return all documents as usual
    if(id.isEmpty()) {
        emitUpdate(true);
        setMessage(1, "Empty document ID searched, showing all documents.");
        return;
    }

    vector <string> searchMatches{};
    id = id.simplified().toLower();

    for(string iter : document_keys_) {
        if(QString::fromStdString(iter).toLower().contains(id)) {
            searchMatches.push_back(iter);
        }
    }

    setJSONResponse(searchMatches);
    emit jsonDBContentsChanged();
    qCInfo(cb_browser) << "Emitted update to UI.";

    if(searchMatches.size() == 1) {
        setMessage(1,"Found one document with ID containing '" + id + "'.");
        qCInfo(cb_browser) << "Found one document with ID containing '" << id << "'.";
        return;
    } else if(searchMatches.size() > 0) {
        setMessage(1,"Found " + QString::number(searchMatches.size()) + " documents with ID containing '" + id + "'.");
        qCInfo(cb_browser) << "Found " << QString::number(searchMatches.size()) << " documents with ID containing '" << id << "'.";
        return;
    }

    setMessage(1, "Found no documents containing ID = '" + id + "'.");
}

void DatabaseImpl::searchDocByChannel(vector<QString> channels)
{
    if(!getDBStatus()) {
        setMessage(0,"Database must be open to change channel display.");
        return;
    }

    // No channels specified, so return all documents as usual
    if(channels.empty()) {
        emitUpdate(true);
        setMessage(1, "Showing all documents.");
        return;
    }

    vector <string> channelMatches{};

    // Need to return a JSON response corresponding only to the channels requested
    for(string iter : document_keys_) {
        SGDocument doc(sg_db_, iter);
        QJsonObject obj = QJsonDocument::fromJson(QString::fromStdString(doc.getBody()).toUtf8()).object();

        if(obj.contains("channels")) {
            QJsonValue val = obj.value("channels");
            QString element = val.toString();

            // Document contains a 'channel' field, non empty, single valued, and in string format
            // Need to determine if it matches any entries in the provided channels vector
            if(!element.isEmpty()) {
                if(find(channels.begin(), channels.end(), element) != channels.end()) {
                    channelMatches.push_back(iter);
                }

            } else {
                QJsonArray arr = val.toArray();
                if(!arr.isEmpty()) {
                    for(QJsonValue element : arr) {
                        if(find(channels.begin(), channels.end(), element.toString()) != channels.end()) {
                            channelMatches.push_back(iter);
                        }
                    }
                }
            }
        }
    }

    setJSONResponse(channelMatches);
    emit jsonDBContentsChanged();
    qCInfo(cb_browser) << "Emitted update to UI: successfully switched channel display.";
    setMessage(1,"Successfully switched channel display.");
}

void DatabaseImpl::setDBstatus(bool status)
{
    DBstatus_ = status;
    emit dbStatusChanged();
}

void DatabaseImpl::setRepstatus(bool status)
{
    Repstatus_ = status;
    emit listenStatusChanged();
}

void DatabaseImpl::setDBName(QString db_name)
{
    db_name_ = db_name;
    emit dbNameChanged();
}

void DatabaseImpl::setMessage(const int &status, QString msg)
{
    if(msg.isEmpty()) {
        qCCritical(cb_browser) << "The setMessage function received an empty message.";
        return;
    }

    msg.replace('\"',"'");

    switch(status) {
        case 0:
            message_ = "{\"status\":\"fail\",\"msg\":\"" + msg + QString("\"}");
            qCInfo(cb_browser) << "Emitted fail message: " << msg;
            break;
        case 1:
            message_ = "{\"status\":\"success\",\"msg\":\"" + msg + QString("\"}");
            qCInfo(cb_browser) << "Emitted success message: " << msg;
            break;
        case 2:
            message_ = "{\"status\":\"warning\",\"msg\":\"" + msg + QString("\"}");
            qCInfo(cb_browser) << "Emitted warning message: " << msg;
            break;
        default:
            qCCritical(cb_browser) << "The setMessage function received an unknown status code.";
            return;
    }

    emit messageChanged();
}

void DatabaseImpl::setDBPath(QString db_path)
{
    db_path_ = db_path;
}

void DatabaseImpl::setAllDocsCache(QString json)
{
    all_docs_cached_JsonDBContents_ = json;
}

QString DatabaseImpl::getDBPath()
{
    return db_path_;
}

QString DatabaseImpl::getDBName()
{
    return db_name_;
}

QString DatabaseImpl::getJsonDBContents()
{
    return JsonDBContents_;
}

QString DatabaseImpl::getJsonConfig()
{
    return config_mgr ? config_mgr->getConfigJson() : "{}";
}

bool DatabaseImpl::getDBStatus()
{
    return DBstatus_;
}

bool DatabaseImpl::getListenStatus()
{
    return isDBOpen() && Repstatus_;
}

void DatabaseImpl::setAllChannelsStr()
{
    JSONChannels_ = "{";

    QStringList listened_channels_copy = listened_channels_;
    QStringList suggested_channels_copy = suggested_channels_;

    if(getListenStatus() && listened_channels_copy.empty() && !suggested_channels_copy.empty()) {
        listened_channels_copy << suggested_channels_copy;
    }

    // Add channels to the active channel list (listened_channels_)
    for(QString iter : listened_channels_copy) {
        JSONChannels_ += "\"" + iter + "\":\"active\",";
    }

    // Add channels to the suggested channel list (suggested_channels_)
    for(QString iter : suggested_channels_copy) {
        if(!listened_channels_copy.contains(iter)) {
            JSONChannels_ += "\"" + iter + "\":\"suggested\",";
        }
    }

    if(JSONChannels_.length() > 1) {
        JSONChannels_.chop(1);
    }

    JSONChannels_ += "}";
    emit channelsChanged();
}

QString DatabaseImpl::getAllChannels()
{
    return JSONChannels_;
}

QString DatabaseImpl::getMessage()
{
    return message_;
}

QString DatabaseImpl::getActivityLevel()
{
    return activity_level_;
}

bool DatabaseImpl::isDBOpen()
{
    return sg_db_ && sg_db_->isOpen() && getDBStatus();
}

QString DatabaseImpl::getAllDocsCache()
{
    return all_docs_cached_JsonDBContents_;
}
