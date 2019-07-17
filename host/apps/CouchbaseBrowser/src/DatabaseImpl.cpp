#include "DatabaseImpl.h"
#include "ConfigManager.h"

#include <iostream>
#include <QCoreApplication>
#include <QDir>

using namespace std;
using namespace Spyglass;

#define DEBUG(...) printf("TEST Database Interface: "); printf(__VA_ARGS__)

DatabaseImpl::DatabaseImpl(QObject *parent, bool mgr) : QObject (parent), cb_browser("cb_browser")
{
    JSONResponse_ = "{}";
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
        setMessage(makeJsonMsg(0, "Problem with path to database file. The file must be located according to: \".../db/(db_name)/db.sqlite3\""));
        return;
    }

    setDBName(dir.dirName());

    if(!dir.cdUp() || !dir.cdUp()) {
        qCCritical(cb_browser) << "Problem with path to database file: " << file_path_;
        setMessage(makeJsonMsg(0, "Problem with path to database file. The file must be located according to: \".../db/(db_name)/db.sqlite3\""));
        return;
    }

    setDBPath(dir.path() + dir.separator());
    sg_db_ = new SGDatabase(db_name_.toStdString(), db_path_.toStdString());
    setDBstatus(false);
    setRepstatus(false);

    if (sg_db_ == nullptr || sg_db_->open() != SGDatabaseReturnStatus::kNoError || !sg_db_->isOpen()) {
        qCCritical(cb_browser) << "Problem with initialization of database.";
        setMessage(makeJsonMsg(0,"Problem with initialization of database."));
        return;
    }

    setDBstatus(true);
    emitUpdate();

   if(config_mgr) {
       config_mgr->addDBToConfig(getDBName(),file_path);
       emit jsonConfigChanged();
   }

    qCInfo(cb_browser) << "Successfully opened database '" << getDBName() << "'.";
    setMessage(makeJsonMsg(1, "Successfully opened database '" + getDBName() + "'."));
}

void DatabaseImpl::deleteConfigEntry(QString db_name)
{
    if(!config_mgr) {
        setMessage(makeJsonMsg(0, "Unable to delete Config DB entry '" + db_name + "'."));
        return;
    }

    if(config_mgr->deleteConfigEntry(db_name)) {
        setMessage(makeJsonMsg(1, "Successfully deleted Config DB entry '" + db_name + "'."));
        emit jsonConfigChanged();
        return;
    }

    setMessage(makeJsonMsg(0, "Unable to delete Config DB entry '" + db_name + "'."));
}

void DatabaseImpl::clearConfig()
{
    if(!config_mgr) {
        setMessage(makeJsonMsg(0, "Unable to clear Config DB."));
        return;
    }

    if(config_mgr->clearConfig()) {
        setMessage(makeJsonMsg(1, "Successfully cleared Config DB."));
        emit jsonConfigChanged();
        return;
    }

    setMessage(makeJsonMsg(0, "Unable to clear Config DB."));
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
        setMessage(makeJsonMsg(0,"Problem with initialization of database."));
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
        setMessage(makeJsonMsg(0,"Problem with initialization of database."));
        return;
    }

    setDBstatus(true);
    emitUpdate();

    if(config_mgr) {
        config_mgr->addDBToConfig(getDBName(),file_path_);
        emit jsonConfigChanged();
    }

    qCInfo(cb_browser) << "Successfully created database '" << db_name + "'.";
    setMessage(makeJsonMsg(1, "Successfully created database '" + db_name + "'."));
}

void DatabaseImpl::closeDB()
{
    if(!getDBStatus()) {
        setMessage(makeJsonMsg(0, "No open database, cannot close."));
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
    setMessage(makeJsonMsg(1,"Successfully closed database '" + getDBName() + "'."));
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

void DatabaseImpl::setMessage(QString message)
{
    message_ = message;
    emit messageChanged();
}

void DatabaseImpl::stopListening()
{
    if (sg_replicator_ != nullptr && getListenStatus()) {
        sg_replicator_->stop();
    }

    setRepstatus(false);
    qCInfo(cb_browser) << "Stopped replicator.";
    setMessage(makeJsonMsg(1,"Stopped replicator."));
}

void DatabaseImpl::createNewDoc(QString id, QString body)
{
    if(id.isEmpty() || body.isEmpty()) {
        setMessage(makeJsonMsg(0,"ID and body contents of document may not be empty."));
        return;
    }

    SGMutableDocument newDoc(sg_db_,id.toStdString());

    if(newDoc.exist()) {
        setMessage(makeJsonMsg(0,"A document with ID '" + id + "' already exists. Modify the ID and try again."));
        return;
    }

    if(!newDoc.setBody(body.toStdString())) {
        setMessage(makeJsonMsg(0,"Error setting content of created document. Body must be in JSON format."));
        return;
    }

    if(sg_db_->save(&newDoc) != SGDatabaseReturnStatus::kNoError) {
        setMessage(makeJsonMsg(0,"Error saving document to database."));
        return;
    }

    emitUpdate();
    qCInfo(cb_browser) << "Successfully created document '" << id << "'.";
    setMessage(makeJsonMsg(1,"Successfully created document '" + id + "'."));
}

void DatabaseImpl::startListening(QString url, QString username, QString password, QString rep_type, vector<QString> channels)
{
    if(url.isEmpty()) {
        setMessage(makeJsonMsg(0,"URL may not be empty."));
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
        setMessage(makeJsonMsg(0,"Invalid URL endpoint."));
        return;
    }

    setMessage(startRep());
}

void DatabaseImpl::setChannels(vector<QString> channels)
{
    if(!getListenStatus()) {
        setMessage(makeJsonMsg(0,"Replicator is not running, cannot set or modify channels."));
        return;
    }

    stopListening();

    if(!channels.empty()) {
        channels_.clear();
        for(auto &val : channels) {
            channels_.push_back(val.toStdString());
        }
    }

    sg_replicator_configuration_->setChannels(channels_);
    startRep();
    qCInfo(cb_browser) << "Successfully switched channels.";
    setMessage(makeJsonMsg(1,"Successfully switched channels."));
}

QString DatabaseImpl::startRep()
{
    if(!getDBStatus()) {
        return makeJsonMsg(0,"Database must be open and running for replication to be activated.");
    }

    if(getListenStatus()) {
        return makeJsonMsg(0,"Replicator is already running, cannot start again.");
    }

    sg_replicator_configuration_ = new SGReplicatorConfiguration(sg_db_, url_endpoint_);

    if(sg_replicator_configuration_ == nullptr) {
        return makeJsonMsg(0,"Problem with start of replicator.");
    }

    if(rep_type_ == "pull") {
        sg_replicator_configuration_->setReplicatorType(SGReplicatorConfiguration::ReplicatorType::kPull);
    } else if(rep_type_ == "push") {
        sg_replicator_configuration_->setReplicatorType(SGReplicatorConfiguration::ReplicatorType::kPush);
    } else if(rep_type_ == "pushpull") {
        sg_replicator_configuration_->setReplicatorType(SGReplicatorConfiguration::ReplicatorType::kPushAndPull);
    } else {
        return makeJsonMsg(0,"Unidentified replicator type selected.");
    }

    if(!username_.isEmpty() && !password_.isEmpty()) {
        sg_basic_authenticator_ = new SGBasicAuthenticator(username_.toStdString(),password_.toStdString());
        if(sg_basic_authenticator_ == nullptr) {
            return makeJsonMsg(0,"Problem with authentication.");
        }
        sg_replicator_configuration_->setAuthenticator(sg_basic_authenticator_);
    }

    if(!channels_.empty()) {
        sg_replicator_configuration_->setChannels(channels_);
    }

    sg_replicator_ = new SGReplicator(sg_replicator_configuration_);

    if(sg_replicator_ == nullptr) {
        return makeJsonMsg(0,"Problem with start of replicator.");
    }

    sg_replicator_->addDocumentEndedListener(bind(&DatabaseImpl::emitUpdate, this));
    sg_replicator_->addValidationListener(bind(&DatabaseImpl::emitUpdate, this));

    if(sg_replicator_->start() == false) {
        return makeJsonMsg(0,"Problem with start of replicator.");
    }

    setRepstatus(true);
    config_mgr->addRepToConfigDB(db_name_,url_,username_,rep_type_);
    emit jsonConfigChanged();
    emitUpdate();
    qCInfo(cb_browser) << "successfully started replicator.";
    return makeJsonMsg(1,"successfully started listening.");
}

void DatabaseImpl::editDoc(QString oldId, QString newId, const QString body)
{
    oldId = oldId.simplified();
    newId = newId.simplified();

    if(oldId.isEmpty()) {
        setMessage(makeJsonMsg(0,"Received empty existing ID, cannot edit."));
        return;
    }

    if(newId.isEmpty() && body.isEmpty()) {
        setMessage(makeJsonMsg(0,"Received empty new ID and body, nothing to edit."));
        return;
    }

    // Only need to edit body (no need to re-create document)
    if(newId.isEmpty() || newId == oldId) {
        SGMutableDocument doc(sg_db_,oldId.toStdString());
        doc.setBody(body.toStdString());
        if(sg_db_->save(&doc) != SGDatabaseReturnStatus::kNoError) {
            setMessage(makeJsonMsg(0,"Error saving document to database."));
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
        setMessage(makeJsonMsg(1,"Successfully edited document '" + oldId + "'"));
        return;
    }

    qCInfo(cb_browser) << "Successfully edited document (" + oldId + " -> " + newId + ").";
    setMessage(makeJsonMsg(1,"Successfully edited document (" + oldId + " -> " + newId + ")."));
}

bool DatabaseImpl::isJsonMsgSuccess(const QString &msg)
{
    QJsonObject obj = QJsonDocument::fromJson(msg.toUtf8()).object();
    return obj.value("status").toString() == "success";
}

void DatabaseImpl::deleteDoc(QString id)
{
    if(id.isEmpty()) {
        setMessage(makeJsonMsg(0,"Received empty ID, cannot delete."));
        return;
    }

    SGDocument doc(sg_db_,id.toStdString());

    if(!doc.exist()) {
        setMessage(makeJsonMsg(0,"Document with ID = '" + id + "' does not exist. Cannot delete."));
        return;
    }

    sg_db_->deleteDocument(&doc);
    emitUpdate();
    qCInfo(cb_browser) << "Successfully deleted document '" + id + "'.";
    setMessage(makeJsonMsg(1,"Successfully deleted document '" + id + "'."));
}

void DatabaseImpl::saveAs(QString path, QString id)
{
    if(!getDBStatus()) {
        setMessage(makeJsonMsg(0,"Database must be open for it to be saved elsewhere."));
        return;
    }

    if(id.isEmpty() || path.isEmpty()) {
        setMessage(makeJsonMsg(0,"Received empty ID or path, unable to save."));
        return;
    }

    path.replace("file://","");
    QDir dir(path);
    path = dir.path() + dir.separator();

    if(!dir.exists() || !dir.isAbsolute()) {
        setMessage(makeJsonMsg(0,"Received invalid path, unable to save."));
        return;
    }

    SGDatabase temp_db(id.toStdString(), path.toStdString());

    if(temp_db.open() != SGDatabaseReturnStatus::kNoError || !temp_db.isOpen()) {
        setMessage(makeJsonMsg(0,"Problem saving database."));
    }

    for(string iter : document_keys_) {
        SGMutableDocument temp_doc(&temp_db, iter);
        SGDocument existing_doc(sg_db_, iter);
        temp_doc.setBody(existing_doc.getBody());
        temp_db.save(&temp_doc);
    }

    setMessage(makeJsonMsg(1, "Saved database successfully."));
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
        setMessage(makeJsonMsg(0,"Database must be open to search."));
        return;
    }

    // ID is empty, so return all documents as usual
    if(id.isEmpty()) {
        emitUpdate();
        setMessage(makeJsonMsg(1, "Empty ID searched, showing all documents."));
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
        setMessage(makeJsonMsg(1,"Found one document with ID containing '" + id + "'."));
        return;
    } else if(searchMatches.size() > 0) {
        setMessage(makeJsonMsg(1,"Found " + QString::number(searchMatches.size()) + " documents with ID containing '" + id + "'."));
        return;
    }

    setMessage(makeJsonMsg(1, "Found no documents containing ID = '" + id + "'."));
}

QString DatabaseImpl::makeJsonMsg(const bool &success, QString msg)
{
    return "{\"status\":\"" + QString(success ? "success" : "fail") + "\",\"msg\":\"" + msg.replace('\"',"'") + QString("\"}");
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

void DatabaseImpl::setDBPath(QString db_path)
{
    db_path_ = db_path;
}

QString DatabaseImpl::getDBPath()
{
    return db_path_;
}

void DatabaseImpl::setDBName(QString db_name)
{
    db_name_ = db_name;
    emit dbNameChanged();
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
        qCCritical(cb_browser) << "Attempted to get channel list, but replicator is not running.";
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
