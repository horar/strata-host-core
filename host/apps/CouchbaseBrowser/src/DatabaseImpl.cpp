#include "DatabaseImpl.h"

#include <iostream>
#include <algorithm>
#include <QCoreApplication>
#include <QDir>
#include <QDebug>
#include <QLoggingCategory>

using namespace std;
using namespace Spyglass;

#define DEBUG(...) printf("TEST Database Interface: "); printf(__VA_ARGS__)

DatabaseImpl::DatabaseImpl(QObject *parent) : QObject (parent), cb_browser("cb_browser")
{
}

DatabaseImpl::~DatabaseImpl()
{
    closeDB();
}

QString DatabaseImpl::openDB(QString file_path)
{
    if(getDBstatus()) {
        closeDB();
    }

    file_path.replace("file://","");
    file_path_ = file_path;

    qCInfo(cb_browser) << "Attempting to open database with path " + file_path_;

    if(!parseFilePath()) {
        qCCritical(cb_browser) << "Problem with path to database file: " + file_path_;
        return makeJsonMsg(0, "Problem with path to database file. The file must be located according to: \".../db/(db_name)/db.sqlite3\"");
    }

    sg_db_ = new SGDatabase(db_name_.toStdString(), db_path_.toStdString());
    setDBstatus(false);
    setRepstatus(false);

    if (sg_db_ == nullptr || sg_db_->open() != SGDatabaseReturnStatus::kNoError || !sg_db_->isOpen()) {
        qCCritical(cb_browser) << "Problem with initialization of database.";
        return makeJsonMsg(0,"Problem with initialization of database.");
    }

    setDBstatus(true);
    emitUpdate();

    qCInfo(cb_browser) << "Succesfully opened database " << getDBName() << ".";
    return makeJsonMsg(1, "Succesfully opened database " + getDBName() + ".");
}

void DatabaseImpl::closeDB()
{
    if(!getDBstatus()) {
        return;
    }

    stopListening();
    delete sg_replicator_;
    delete url_endpoint_;
    delete sg_replicator_configuration_;
    delete sg_basic_authenticator_;
    delete sg_db_;
    document_keys_.clear();
    JSONResponse_ = "{}";
    setDBstatus(false);
    setRepstatus(false);
    emit newUpdate();
    qCInfo(cb_browser) << "Succesfully closed database " << getDBName() << ".";
}

void DatabaseImpl::emitUpdate()
{
    if(setDocumentKeys()) {
        setJSONResponse(document_keys_);
    }

    qCInfo(cb_browser) << "Emitted update to UI.";
    emit newUpdate();
}

void DatabaseImpl::stopListening()
{
    if (getRepstatus()) {
        sg_replicator_->stop();
    }

    setRepstatus(false);
    qCInfo(cb_browser) << "Stopped replicator.";
}

QString DatabaseImpl::createNewDoc(QString id, QString body)
{
    if(id.isEmpty() || body.isEmpty()) {
        return makeJsonMsg(0,"ID and body contents of document may not be empty.");
    }

    return createNewDoc_(id,body);
}

QString DatabaseImpl::createNewDoc_(const QString &id, const QString &body)
{
    SGMutableDocument newDoc(sg_db_,id.toStdString());

    if(newDoc.exist()) {
        return makeJsonMsg(0,"A document with ID \"" + id + "\" already exists. Modify the ID and try again.");
    }

    if(!newDoc.setBody(body.toStdString())) {
        return makeJsonMsg(0,"Error setting content of created document. Body must be in JSON format.");
    }

    if(sg_db_->save(&newDoc) != SGDatabaseReturnStatus::kNoError) {
        return makeJsonMsg(0,"Error saving document to database.");
    }

    emitUpdate();
    qCInfo(cb_browser) << "Succesfully created document " << id << ".";
    return makeJsonMsg(1,"Succesfully created document " + id);
}

QString DatabaseImpl::startListening(QString url, QString username, QString password, QString rep_type, vector<QString> channels)
{
    if(url.isEmpty()) {
        return makeJsonMsg(0,"URL may not be empty.");
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
    }

    url_endpoint_ = new SGURLEndpoint(url_.toStdString());

    if(!url_endpoint_->init() || url_endpoint_ == nullptr) {
        return makeJsonMsg(0,"Invalid URL endpoint.");
    }

    return startRep();
}

QString DatabaseImpl::setChannels(vector<QString> channels)
{
    if(!getRepstatus()) {
        return makeJsonMsg(0,"Replicator is not running, cannot set or modify channels.");
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
    qCInfo(cb_browser) << "Succesfully switched channels.";
    return makeJsonMsg(1,"Succesfully switched channels.");
}

QString DatabaseImpl::startRep()
{
    if(!getDBstatus()) {
        return makeJsonMsg(0,"Database must be open and running for replication to be activated.");
    }

    if(getRepstatus()) {
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
    sg_replicator_->addChangeListener(bind(&DatabaseImpl::emitUpdate, this));
    sg_replicator_->addValidationListener(bind(&DatabaseImpl::emitUpdate, this));

    if(sg_replicator_->start() == false) {
        return makeJsonMsg(0,"Problem with start of replicator.");
    }

    setRepstatus(true);
    emitUpdate();
    qCInfo(cb_browser) << "Succesfully started replicator.";
    return makeJsonMsg(1,"Succesfully started listening.");
}

bool DatabaseImpl::parseFilePath()
{
    QFileInfo info(file_path_);

    if(info.exists()) {
        return parseExistingFile();
    } else {
        return parseNewFile();
    }
}

bool DatabaseImpl::parseExistingFile()
{
    QDir dir(file_path_);
    QFileInfo info(file_path_);

    if(info.fileName() != "db.sqlite3") {
        return false;
    }

    if(!dir.cdUp()) {
        return false;
    }

    setDBName(dir.dirName());

    if(!dir.cdUp() || !dir.cdUp()) {
        return false;
    }

    setDBPath(dir.path() + dir.separator());
    return true;
}

bool DatabaseImpl::parseNewFile()
{
    QString folder_path = file_path_;
    folder_path.replace("db.sqlite3", "");
    QDir dir(folder_path);

    if(!dir.isAbsolute() || !dir.mkpath(folder_path)) {
        return false;
    }

    QFile file(file_path_);
    setDBName(dir.dirName());

    if(!dir.cdUp() || !dir.cdUp()) {
        return false;
    }

    setDBPath(dir.path() + dir.separator());

    if(!file.open(QIODevice::ReadWrite)) {
        return false;
    }

    return true;
}

QString DatabaseImpl::editDoc(QString oldId, QString newId, const QString body)
{
    oldId = oldId.simplified();
    newId = newId.simplified();

    if(oldId.isEmpty()) {
        return makeJsonMsg(0,"Received empty existing ID, cannot edit.");
    }

    if(newId.isEmpty() && body.isEmpty()) {
        return makeJsonMsg(0,"Received empty new ID and body, nothing to edit.");
    }

    // Only need to edit body (no need to re-create document)
    if(newId.isEmpty() || newId == oldId) {
        SGMutableDocument doc(sg_db_,oldId.toStdString());
        doc.setBody(body.toStdString());
        if(sg_db_->save(&doc) != SGDatabaseReturnStatus::kNoError) {
            return makeJsonMsg(0,"Error saving document to database.");
        }
        emitUpdate();
    }
    // Other case: need to edit ID
    else {
        // Create new doc with new ID and body, then delete old doc
        if(!createNewDoc(newId, body).isEmpty()) {
            return makeJsonMsg(0,"Problem with creation of document with ID = " + newId);
        }
        // Delete existing document with ID = OLD ID
        if(!deleteDoc(oldId).isEmpty()) {
            return makeJsonMsg(0,"Problem with deletion of document with ID = " + oldId);
        }
    }
    qCInfo(cb_browser) << "Succesfully edited document (" + oldId + "->" + newId + ").";
    return makeJsonMsg(1,"Succesfully edited document.");
}

QString DatabaseImpl::deleteDoc(QString id)
{
    if(id.isEmpty()) {
        return makeJsonMsg(0,"Received empty ID, cannot delete.");
    }

    SGDocument doc(sg_db_,id.toStdString());

    if(!doc.exist()) {
        return makeJsonMsg(0,"Document with ID = \"" + id + "\" does not exist. Cannot delete.");
    }

    sg_db_->deleteDocument(&doc);
    emitUpdate();
    qCInfo(cb_browser) << "Succesfully deleted document " + id + ".";
    return makeJsonMsg(1,"Succesfully deleted document " + id + ".");
}

QString DatabaseImpl::saveAs(QString id, QString path)
{
    if(id.isEmpty() || path.isEmpty()) {
        return makeJsonMsg(0,"Received empty ID or path, unable to save.");
    }

    path.replace("file://","");
    QDir dir(path);
    path = dir.path() + dir.separator();

    if(!dir.exists() || !dir.isAbsolute()) {
        return makeJsonMsg(0,"Received invalid path, unable to save.");
    }

    return saveAs_(id, path);
}

QString DatabaseImpl::saveAs_(const QString &id, const QString &path)
{
    SGDatabase temp_db(id.toStdString(), path.toStdString());

    if(temp_db.open() != SGDatabaseReturnStatus::kNoError || !temp_db.isOpen()) {
        return makeJsonMsg(0,"Problem saving database.");
    }

    for(std::vector <string>::iterator iter = document_keys_.begin(); iter != document_keys_.end(); iter++) {
        SGMutableDocument temp_doc(&temp_db, (*iter));
        SGDocument existing_doc(sg_db_, (*iter));
        temp_doc.setBody(existing_doc.getBody());
        temp_db.save(&temp_doc);
    }

    return makeJsonMsg(1, "Saved database succesfully.");
}

bool DatabaseImpl::setDocumentKeys()
{
    document_keys_.clear();

    if(!sg_db_->getAllDocumentsKey(document_keys_)) {
        DEBUG("Failed to run getAllDocumentsKey()\n");
        return false;
    }

    return true;
}

void DatabaseImpl::setJSONResponse(vector<string> &docs)
{
    QString temp_str = "";
    JSONResponse_ = "{";

    for(std::vector <string>::iterator iter = docs.begin(); iter != docs.end(); iter++) {
        SGDocument usbPDDocument(sg_db_, (*iter));
        temp_str = "\"" + QString((*iter).c_str()) + "\":" + QString(usbPDDocument.getBody().c_str()) + (iter + 1 != docs.end() ? "," : "");
        JSONResponse_ += temp_str;
    }

    JSONResponse_ += "}";
}

QString DatabaseImpl::searchDocById(QString id)
{
    // ID is empty, so return all documents as usual
    if(id.isEmpty()) {
        emitUpdate();
        return makeJsonMsg(0, "Empty ID searched, showing all documents.");
    }

    std::vector <string> searchMatches{};
    id = id.simplified().toLower();

    for(std::vector <string>::iterator iter = document_keys_.begin(); iter != document_keys_.end(); iter++) {
        if(QString((*iter).c_str()).toLower().contains(id)) {
            searchMatches.push_back(*iter);
        }
    }

    setJSONResponse(searchMatches);
    emit newUpdate();

    if(searchMatches.size() > 0) {
        return makeJsonMsg(1,"Found a total of " + QString::number(searchMatches.size()) + " documents with ID containing \"" + id + "\".");
    }

    return makeJsonMsg(1, "Found no documents containing ID = \"" + id + "\".");
}

QString DatabaseImpl::makeJsonMsg(const bool &success, const QString &msg)
{
    string temp = msg.toStdString();
    replace(temp.begin(),temp.end(),'"','\'');
    return "{\"status\":\"" + QString(success ? "success" : "fail") + "\",\"msg\":\"" + QString::fromStdString(temp) + QString("\"}");
}

QString DatabaseImpl::getJSONResponse()
{
    return JSONResponse_;
}

bool DatabaseImpl::getDBstatus()
{
    return DBstatus_;
}

bool DatabaseImpl::getRepstatus()
{
    return Repstatus_;
}

void DatabaseImpl::setDBstatus(bool status)
{
    DBstatus_ = status;
}

void DatabaseImpl::setRepstatus(bool status)
{
    Repstatus_ = status;
}

QString DatabaseImpl::getFilePath()
{
    return file_path_;
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
}

QString DatabaseImpl::getDBName()
{
    return db_name_;
}
