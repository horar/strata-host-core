#include "DatabaseImpl.h"
#include "ConfigManager.h"

#include <iostream>
#include <QCoreApplication>
#include <QDir>
#include <QJsonArray>


///
#include "SGFleece.h"
#include "SGCouchBaseLite.h"
//using namespace std;
using namespace fleece;
using namespace fleece::impl;
using namespace std::placeholders;
//using namespace Spyglass;
///
///

using namespace std;
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
    qCInfo(cb_browser) << "Attempting to open database with file path " << file_path;

    if(getDBStatus()) {
        closeDB();
    }

    file_path.replace("file://","");
    file_path_ = file_path;
    QDir dir(file_path_);
    QFileInfo info(file_path_);

    if(info.fileName() != "db.sqlite3" || !dir.cdUp()) {
        qCCritical(cb_browser) << "Problem with path to database file: " << file_path_;
        setMessage(0, "Problem with path to database file. The file must be located according to: \".../db/(db_name)/db.sqlite3\"");
        return;
    }

    setDBName(dir.dirName());

    if(!dir.cdUp() || !dir.cdUp()) {
        qCCritical(cb_browser) << "Problem with path to database file: " << file_path_;
        setMessage(0, "Problem with path to database file. The file must be located according to: \".../db/(db_name)/db.sqlite3\"");
        return;
    }

    setDBPath(dir.path() + dir.separator());
    sg_db_ = new SGDatabase(db_name_.toStdString(), db_path_.toStdString());
    setDBstatus(false);
    setRepstatus(false);

    if (sg_db_ == nullptr || sg_db_->open() != SGDatabaseReturnStatus::kNoError || !sg_db_->isOpen()) {
        qCCritical(cb_browser) << "Problem with initialization of database.";
        setMessage(0,"Problem with initialization of database.");
        return;
    }

    setDBstatus(true);
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
        setMessage(0, "Unable to delete Config DB entry '" + db_name + "'.");
        return;
    }

    if(config_mgr->deleteConfigEntry(db_name)) {
        setMessage(1, "Successfully deleted Config DB entry '" + db_name + "'.");
        emit jsonConfigChanged();
        return;
    }

    setMessage(0, "Unable to delete Config DB entry '" + db_name + "'.");
}

void DatabaseImpl::clearConfig()
{
    if(!config_mgr) {
        setMessage(0, "Unable to clear Config DB.");
        return;
    }

    if(config_mgr->clearConfig()) {
        setMessage(1, "Successfully cleared Config DB.");
        emit jsonConfigChanged();
        return;
    }

    setMessage(0, "Unable to clear Config DB.");
}

QStringList DatabaseImpl::getChannelSuggestions()
{
    QStringList suggestions;

    if(!getDBStatus()) {
        return suggestions;
    }

    // Get channels previously used with this DB, if any
    if(config_mgr) {
        QJsonObject outer_obj = QJsonDocument::fromJson(config_mgr->getConfigJson().toUtf8()).object();
        QJsonObject inner_obj = outer_obj.value(getDBName()).toObject();
        QJsonValue val = inner_obj.value("channels");
        QJsonArray arr = val.toArray();

        for(QJsonValue val : arr) {
            suggestions << val.toString();
        }
    }

    // Get channels from the metadata of each document in the current DB
//    SGMutableDocument doc(sg_db_,"a");
////    cout << "\nGet 'meta' for document: ";
//    const Value *name_value = doc.get("click");
//    cout << "\nMeta: " << name_value->toString().asString() << "<-" << endl; // crashes program



    ////////
    cout << "\n\n\n\n\n\n\nSUGGESTIONS BEING MADE: "; for(QString q : suggestions) cout << q.toStdString() << " "; cout << "\n" << endl;// remove later

    return suggestions;
}

void DatabaseImpl::createNewDB(QString folder_path, QString db_name)
{
    qCInfo(cb_browser) << "Attempting to create new database '" << db_name << "' with folder path " << folder_path;

    if(getDBStatus()) {
        closeDB();
    }

    folder_path.replace("file://","");
    QDir dir(folder_path);
    folder_path += dir.separator();

    if(!dir.isAbsolute() || !dir.mkpath(folder_path)) {
        qCCritical(cb_browser) << "Problem with path to database file: " + file_path_;
        setMessage(0,"Problem with initialization of database.");
        return;
    }

    file_path_ = folder_path + "db" + dir.separator() + db_name + dir.separator() + "db.sqlite3";
    setDBName(db_name);
    setDBPath(folder_path);
    sg_db_ = new SGDatabase(db_name_.toStdString(), db_path_.toStdString());
    setDBstatus(false);
    setRepstatus(false);

    if (sg_db_ == nullptr || sg_db_->open() != SGDatabaseReturnStatus::kNoError || !sg_db_->isOpen()) {
        qCCritical(cb_browser) << "Problem with initialization of database.";
        setMessage(0,"Problem with initialization of database.");
        return;
    }

    setDBstatus(true);
    emitUpdate();

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
    setDBstatus(false);
    setRepstatus(false);
    qCInfo(cb_browser) << "Successfully closed database '" << getDBName() << "'.";
    setMessage(1,"Successfully closed database '" + getDBName() + "'.");
    setDBName("");
    JSONResponse_ = "{}";
    emit jsonDBContentsChanged();
}

void DatabaseImpl::emitUpdate()
{
    if(setDocumentKeys()) {
        setJSONResponse(document_keys_);
    }
}

void DatabaseImpl::stopListening()
{
    waiting_for_stop = true;
    if (sg_replicator_ != nullptr && getListenStatus()) {
        sg_replicator_->stop();
    }
//    setRepstatus(false);
//    qCInfo(cb_browser) << "Stopped replicator.";
//    setMessage(1,"Stopped replicator.");
}

void DatabaseImpl::createNewDoc(QString id, QString body)
{
    if(id.isEmpty() || body.isEmpty()) {
        setMessage(0,"ID and body contents of document may not be empty.");
        return;
    }

    SGMutableDocument newDoc(sg_db_,id.toStdString());

    if(newDoc.exist()) {
        setMessage(0,"A document with ID '" + id + "' already exists. Modify the ID and try again.");
        return;
    }

    if(!newDoc.setBody(body.toStdString())) {
        setMessage(0,"Error setting content of created document. Body must be in JSON format.");
        return;
    }

    if(sg_db_->save(&newDoc) != SGDatabaseReturnStatus::kNoError) {
        setMessage(0,"Error saving document to database.");
        return;
    }

    emitUpdate();
    qCInfo(cb_browser) << "Successfully created document '" << id << "'.";
    setMessage(1,"Successfully created document '" + id + "'.");
}

void DatabaseImpl::setChannels(vector<QString> channels)
{
    if(!getListenStatus() || sg_replicator_ == nullptr) {
        setMessage(0,"Replicator is not running, cannot set or modify channels.");
        return;
    }

    sg_replicator_->stop();

    if(!channels.empty()) {
        channels_.clear();
        for(auto &val : channels) {
            channels_.push_back(val.toStdString());
        }
    } else {
        channels_.clear();
        return;
    }

    sg_replicator_configuration_->setChannels(channels_);
    startRep();
    qCInfo(cb_browser) << "Successfully switched channels.";
    setMessage(1,"Successfully switched channels.");
}

void DatabaseImpl::startListening(QString url, QString username, QString password, QString rep_type, vector<QString> channels)
{
    if(url.isEmpty()) {
        setMessage(0,"URL may not be empty.");
        return;
    }

    url_ = url;
    username_ = username;
    password_ = password;
    rep_type_ = rep_type;

    if(!channels.empty()) {
        channels_.clear();
        for(auto &val : channels) {
            channels_.push_back(val.toStdString());
        }
        emit channelsChanged();
    }

    url_endpoint_ = new SGURLEndpoint(url_.toStdString());

    if(!url_endpoint_->init() || url_endpoint_ == nullptr) {
        setMessage(0,"Invalid URL endpoint.");
        return;
    }

    startRep();
}

void DatabaseImpl::startRep()
{
    if(!getDBStatus()) {
        setMessage(0,"Database must be open and running for replication to be activated.");
        return;
    }

    if(getListenStatus()) {
        setMessage(0,"Replicator is already running, cannot start again.");
        return;
    }

    sg_replicator_configuration_ = new SGReplicatorConfiguration(sg_db_, url_endpoint_);

    if(sg_replicator_configuration_ == nullptr) {
        setMessage(0,"Problem with start of replicator.");
        return;
    }

    if(rep_type_ == "pull") {
        sg_replicator_configuration_->setReplicatorType(SGReplicatorConfiguration::ReplicatorType::kPull);
    } else if(rep_type_ == "push") {
        sg_replicator_configuration_->setReplicatorType(SGReplicatorConfiguration::ReplicatorType::kPush);
    } else if(rep_type_ == "pushpull") {
        sg_replicator_configuration_->setReplicatorType(SGReplicatorConfiguration::ReplicatorType::kPushAndPull);
    } else {
        setMessage(0,"Unidentified replicator type selected.");
        return;
    }

    if(!username_.isEmpty() && !password_.isEmpty()) {
        sg_basic_authenticator_ = new SGBasicAuthenticator(username_.toStdString(),password_.toStdString());
        if(sg_basic_authenticator_ == nullptr) {
            setMessage(0,"Problem with authentication.");
            return;
        }
        sg_replicator_configuration_->setAuthenticator(sg_basic_authenticator_);
    }

    if(!channels_.empty()) {
        sg_replicator_configuration_->setChannels(channels_);
    }

    sg_replicator_ = new SGReplicator(sg_replicator_configuration_);

    if(sg_replicator_ == nullptr) {
        setMessage(0,"Problem with start of replicator.");
        return;
    }

    waiting_for_start = true;

    sg_replicator_->addDocumentEndedListener(bind(&DatabaseImpl::emitUpdate, this));
    sg_replicator_->addValidationListener(bind(&DatabaseImpl::emitUpdate, this));
    sg_replicator_->addChangeListener(bind(&DatabaseImpl::repStatusChanged, this, _1));

    if(sg_replicator_->start() == false) {
        setMessage(0,"Problem with start of replicator.");
        return;
    }

    config_mgr->addRepToConfigDB(db_name_,url_,username_,rep_type_,channels_);
    emit jsonConfigChanged();
}

void DatabaseImpl::repStatusChanged(SGReplicator::ActivityLevel level)
{
    if(!getDBStatus() || sg_replicator_ == nullptr) {
        qCCritical(cb_browser) << "Attempted to update status of replicator, but replicator is not running.";
        return;
    }

    switch(level) {
        case SGReplicator::ActivityLevel::kStopped:
            if(getListenStatus()) {
                setRepstatus(false);
                if (!waiting_for_stop) {
                    qCCritical(cb_browser) << "Replicator activity level changed to Stopped (Problems connecting with replication service)";
                    setMessage(0, "Problems connecting with replication service.");
                }
                else {
                    qCInfo(cb_browser) << "Stopped replicator.";
                    setMessage(1,"Stopped replicator.");
                    waiting_for_stop = false;
                    delete sg_replicator_;
                    sg_replicator_ = nullptr;
                }
            }
            else {
                if(waiting_for_start) setMessage(0,"Problem with start of replicator.");
            }
            activity_level_ = "Stopped";
            break;
        case SGReplicator::ActivityLevel::kOffline:
            if(getListenStatus()) {
                waiting_for_connection = true;
                qCCritical(cb_browser) << "Replicator activity level changed to Offline (Problems connecting with replication service)";
                setMessage(0, "Problems connecting with replication service.");
            }
            else {
                if(waiting_for_start) setMessage(0,"Problem with start of replicator.");
            }
            activity_level_ = "Offline";
            qCInfo(cb_browser) << "Replicator activity level changed to Offline";
            break;
        case SGReplicator::ActivityLevel::kConnecting:
            if(!getListenStatus()) {
                if (waiting_for_start) {
                    setRepstatus(true);
                    setMessage(1, "Successfully started replicator.");
                    waiting_for_start = false;
                }
                else {
                    stopListening();
                }
            }
            else {
                if(waiting_for_connection) {
                    setMessage(1, "Reconnecting replicator");
                    waiting_for_connection = false;
                }
            }
            activity_level_ = "Connecting";
            qCInfo(cb_browser) << "Replicator activity level changed to Connecting";
            break;
        case SGReplicator::ActivityLevel::kIdle:
            if(!getListenStatus()) {
                if (waiting_for_start) {
                    setRepstatus(true);
                    setMessage(1, "Successfully started replicator.");
                    waiting_for_start = false;
                }
                else {
                    stopListening();
                }
            }
            else {
                if(waiting_for_connection) {
                    setMessage(1, "Successfully reconnected replicator");
                    waiting_for_connection = false;
                }
            }
            activity_level_ = "Idle";
            qCInfo(cb_browser) << "Replicator activity level changed to Idle";
            break;
        case SGReplicator::ActivityLevel::kBusy:
            if(!getListenStatus()) {
                if (waiting_for_start) {
                    setRepstatus(true);
                    setMessage(1, "Successfully started replicator.");
                    waiting_for_start = false;
                }
                else {
                    stopListening();
                }
            }
            else {
                if(waiting_for_connection) {
                    setMessage(1, "Successfully reconnected replicator");
                    waiting_for_connection = false;
                }
            }
            activity_level_ = "Busy";
            qCInfo(cb_browser) << "Replicator activity level changed to Busy";
            break;
    }

    emit activityLevelChanged();
}

void DatabaseImpl::editDoc(QString oldId, QString newId, const QString body)
{
    oldId = oldId.simplified();
    newId = newId.simplified();

    if(oldId.isEmpty()) {
        setMessage(0,"Received empty existing ID, cannot edit.");
        return;
    }

    if(newId.isEmpty() && body.isEmpty()) {
        setMessage(0,"Received empty new ID and body, nothing to edit.");
        return;
    }

    // Only need to edit body (no need to re-create document)
    if(newId.isEmpty() || newId == oldId) {
        SGMutableDocument doc(sg_db_,oldId.toStdString());
        doc.setBody(body.toStdString());
        if(sg_db_->save(&doc) != SGDatabaseReturnStatus::kNoError) {
            setMessage(0,"Error saving document to database.");
            return;
        }
        emitUpdate();
    }
    // Other case: need to edit ID
    else {
        createNewDoc(newId, body);
        // Create new doc with new ID and body, then delete old doc
        if(!isJsonMsgSuccess(message_)) {
            return;
        }

        // Delete existing document with ID = OLD ID
        deleteDoc(oldId);
        if(!isJsonMsgSuccess(message_)) {
            return;
        }
    }

    if(newId.isEmpty() || newId == oldId) {
        qCInfo(cb_browser) << "Successfully edited document '" << oldId << "'.";
        setMessage(1,"Successfully edited document '" + oldId + "'");
        return;
    }

    qCInfo(cb_browser) << "Successfully edited document (" + oldId + " -> " + newId + ").";
    setMessage(1,"Successfully edited document (" + oldId + " -> " + newId + ").");
}

bool DatabaseImpl::isJsonMsgSuccess(const QString &msg)
{
    QJsonObject obj = QJsonDocument::fromJson(msg.toUtf8()).object();
    return obj.value("status").toString() == "success";
}

void DatabaseImpl::deleteDoc(QString id)
{
    if(id.isEmpty()) {
        setMessage(0,"Received empty ID, cannot delete.");
        return;
    }

    SGDocument doc(sg_db_,id.toStdString());

    if(!doc.exist()) {
        setMessage(0,"Document with ID = '" + id + "' does not exist. Cannot delete.");
        return;
    }

    sg_db_->deleteDocument(&doc);
    emitUpdate();
    qCInfo(cb_browser) << "Successfully deleted document '" + id + "'.";
    setMessage(1,"Successfully deleted document '" + id + "'.");
}

void DatabaseImpl::saveAs(QString path, QString id)
{
    if(!getDBStatus()) {
        setMessage(0,"Database must be open for it to be saved elsewhere.");
        return;
    }

    if(id.isEmpty() || path.isEmpty()) {
        setMessage(0,"Received empty ID or path, unable to save.");
        return;
    }

    path.replace("file://","");
    QDir dir(path);
    path = dir.path() + dir.separator();

    if(!dir.exists() || !dir.isAbsolute()) {
        setMessage(0,"Received invalid path, unable to save.");
        return;
    }

    SGDatabase temp_db(id.toStdString(), path.toStdString());

    if(temp_db.open() != SGDatabaseReturnStatus::kNoError || !temp_db.isOpen()) {
        setMessage(0,"Problem saving database.");
    }

    for(string iter : document_keys_) {
        SGMutableDocument temp_doc(&temp_db, iter);
        SGDocument existing_doc(sg_db_, iter);
        temp_doc.setBody(existing_doc.getBody());
        temp_db.save(&temp_doc);
    }

    setMessage(1, "Saved database successfully.");
}

bool DatabaseImpl::setDocumentKeys()
{
    document_keys_.clear();

    if(!sg_db_->getAllDocumentsKey(document_keys_)) {
        qCCritical(cb_browser) << "Failed to run getAllDocumentsKey()";
        return false;
    }

    return true;
}

void DatabaseImpl::setJSONResponse(vector<string> &docs)
{
    QString temp_str = "";
    JSONResponse_ = "{";

    for(string iter : docs) {
        SGDocument usbPDDocument(sg_db_, iter);
        temp_str = "\"" + QString::fromStdString(iter)  + "\":" + QString::fromStdString(usbPDDocument.getBody()) + ",";
        JSONResponse_ += temp_str;
    }

    if(JSONResponse_.length() > 1) {
        JSONResponse_.chop(1);
    }

    JSONResponse_ += "}";
    emit jsonDBContentsChanged();
    qCInfo(cb_browser) << "Emitted update to UI.";
}

void DatabaseImpl::searchDocById(QString id)
{
    if(!getDBStatus()) {
        setMessage(0,"Database must be open to search.");
        return;
    }

    // ID is empty, so return all documents as usual
    if(id.isEmpty()) {
        emitUpdate();
        setMessage(1, "Empty ID searched, showing all documents.");
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

    if(searchMatches.size() == 1) {
        setMessage(1,"Found one document with ID containing '" + id + "'.");
        return;
    } else if(searchMatches.size() > 0) {
        setMessage(1,"Found " + QString::number(searchMatches.size()) + " documents with ID containing '" + id + "'.");
        return;
    }

    setMessage(1, "Found no documents containing ID = '" + id + "'.");
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

void DatabaseImpl::setMessage(const bool &success, QString msg)
{
    message_ = "{\"status\":\"" + QString(success ? "success" : "fail") + "\",\"msg\":\"" + msg.replace('\"',"'") + QString("\"}");
    emit messageChanged(); cout << "\n\n\n\n\nmessaege was: " << message_.toStdString() << endl << endl << endl;
}

void DatabaseImpl::setDBPath(QString db_path)
{
    db_path_ = db_path;
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
    return JSONResponse_;
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
    return Repstatus_;
}

QStringList DatabaseImpl::getChannels()
{
    if(!getListenStatus()) {
        qCInfo(cb_browser) << "Attempted to get channel list, but replicator is not running.";
        return QStringList();
    }

    QStringList qstrl;

    for(string it : channels_) {
        qstrl.push_back(QString::fromStdString(it));
    }

    return qstrl;
}

QString DatabaseImpl::getMessage()
{
    return message_;
}

QString DatabaseImpl::getActivityLevel()
{
    return activity_level_;
}
