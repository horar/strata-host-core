#include "databaseinterface.h"

#include <iostream>

using namespace std;
using namespace Spyglass;

#define DEBUG(...) printf("TEST Database Interface: "); printf(__VA_ARGS__)

DatabaseInterface::DatabaseInterface(QObject *parent) : QObject (parent)
{
}

DatabaseInterface::DatabaseInterface(const int &id) : id_(id)
{
}

DatabaseInterface::~DatabaseInterface()
{cout << "\n\nIn the ~DatabaseInterface\n" << endl;
    rep_stop();
    delete sg_replicator_;
    delete url_endpoint_;
    delete sg_replicator_configuration_;
    delete sg_basic_authenticator_;
    delete sg_db_;
    setDBstatus(false);
    setRepstatus(false);
}

QString DatabaseInterface::setFilePath(QString file_path)
{
    file_path_ = file_path;
    if(!parseFilePath()) {
        return("Problem with path to database file. The file must be located according to: \".../db/(db_name)/db.sqlite3\"\n");
    } else if(!db_init()) {
        return("Problem initializing database.");
    }

    // temporary
//    SGMutableDocument newdoc(sg_db_, "victorNewDoc");
//    newdoc.set("number", 30);
//    newdoc.set("Name", "victor luiz");

    emitUpdate();

    return("");
}

void DatabaseInterface::emitUpdate()
{
    if(setDocumentKeys()) {
        setJSONResponse();
    }

    emit newUpdate(this->id_);
}

void DatabaseInterface::rep_stop()
{
    if (getRepstatus()) {
        sg_replicator_->stop(); cout << "\nStopped replicator." << endl;
    }

    setRepstatus(false);
}

QString DatabaseInterface::createNewDoc(const QString &id, const QString &body)
{
    if(id.isEmpty() || body.isEmpty()) {
        return ("Document's id or body contents may not be empty.");
    }

    return createNewDoc_(id,body);

//    cout << "\nCreate doc: " << id.toStdString() << "   " << body.toStdString() << endl;

//    emitUpdate();



//    SGMutableDocument usbPDDocument(sg_db_, "victorsDDOCUMENT");``


//     DEBUG("document Id: %s, body: %s\n", usbPDDocument.getId().c_str(), usbPDDocument.getBody().c_str());

//     std::string json_data = R"foo({"name":"VICTORVICTORVICTORVICTORVICTOR","age":200,"myobj":{"mykey":"myvalue","myarray":[1,2,3,4]} })foo";
//         if( usbPDDocument.setBody(json_data) ){
//             DEBUG("json_data is a valid json\n");
//         }

//     if(sg_db_->save(&usbPDDocument) == SGDatabaseReturnStatus::kNoError) {
//             cout << "\nthis works." << endl;
//    }

//    emitUpdate();
}

QString DatabaseInterface::createNewDoc_(const QString &id, const QString &body)
{
    //    SGMutableDocument newDoc(sg_db_,id.toStdString());

    //    if(!newDoc.setBody(body.toStdString())) {
    //        DEBUG("Error setting content of created document. Body must be in JSON format.");
    //        return false;
    //    }

    //     if(sg_db_->save(&newDoc) == SGDatabaseReturnStatus::kNoError) {
    //             cout << "\nthis works." << endl;
    //    }

    return("");
}

 bool DatabaseInterface::db_init()
{
    sg_db_ = new SGDatabase(db_name_.toStdString(), db_path_.toStdString());

    if(sg_db_ == nullptr) {
        DEBUG("Problem with initialization of database.");
        return false;
    }

    setDBstatus(false);
    setRepstatus(false);

    if (sg_db_->open() != SGDatabaseReturnStatus::kNoError) {
        DEBUG("Can't open database.\n");
        return false;
    }

    if (sg_db_->isOpen()) {
        DEBUG("Database is open using isOpen API.\n");
    } else {
        DEBUG("Database is not open, exiting.\n");
        return false;
    }

    setDBstatus(true);
    emitUpdate();
    return true;
}

QString DatabaseInterface::rep_init(const QString &url, const QString &username, const QString &password, const SGReplicatorConfiguration::ReplicatorType &rep_type,
                                    const vector<QString> &channels)
{
    if(url.isEmpty()) {
        return ("URL may not be empty.");
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
        return("Invalid URL endpoint.");
    }

    return rep_init_();
}

QString DatabaseInterface::rep_init_()
{
    if(!getDBstatus()) {
        return("Database must be open and running for replication to be activated.");
    }

    if(getRepstatus()) {
        return("Replicator is already running, cannot start again.");
    }

    sg_replicator_configuration_ = new SGReplicatorConfiguration(sg_db_, url_endpoint_);

    if(sg_replicator_configuration_ == nullptr) {
        return("Problem with start of replication.");
    }

    sg_replicator_configuration_->setReplicatorType(rep_type_);

    if(!username_.isEmpty() && !password_.isEmpty()) {
        sg_basic_authenticator_ = new SGBasicAuthenticator(username_.toStdString(),password_.toStdString());
        if(sg_basic_authenticator_ == nullptr) {
            return("Problem with authentication.");
        }
        sg_replicator_configuration_->setAuthenticator(sg_basic_authenticator_);
    }

    if(!channels_.empty()) {
        sg_replicator_configuration_->setChannels(channels_);
    }

    sg_replicator_ = new SGReplicator(sg_replicator_configuration_);

    if(sg_replicator_ == nullptr) {
        return("Problem with start of replication.");
    }

    sg_replicator_->addDocumentEndedListener(bind(&DatabaseInterface::emitUpdate, this));
    sg_replicator_->addChangeListener(bind(&DatabaseInterface::emitUpdate, this));
    sg_replicator_->addValidationListener(bind(&DatabaseInterface::emitUpdate, this));

    if(sg_replicator_->start() == false) {
        return("Problem with start of replicator.");
    }

    setRepstatus(true);
    emitUpdate();

    return("");
}

bool DatabaseInterface::parseFilePath()
{
    QFileInfo info(file_path_);

    if(info.exists()) {
        return parseExistingFile();
    } else {
        return parseNewFile();
    }
}

bool DatabaseInterface::parseExistingFile()
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

bool DatabaseInterface::parseNewFile()
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

QString DatabaseInterface::editDoc(const QString &oldId, const QString &newId, const QString &body)
{
    if(oldId.isEmpty()) {
        return("Received empty id, cannot edit.");
    }

    if(newId.isEmpty() && body.isEmpty()) {
        return("Received empty new id and body, nothing to edit.");
    }

    SGMutableDocument doc(sg_db_,oldId.toStdString());

    if(!doc.exist()) {
        return("\nDocument with id = \"" + oldId + "\" does not exist. Cannot edit.");
    }

    return editDoc_(doc, newId, body);
}

QString DatabaseInterface::editDoc_(SGMutableDocument &doc, const QString &newId, const QString &body)
{
//    C4Document *c4_doc = sg_db_->getDocumentById(id.toStdString());

//    SGDocument sg_doc;

//    sg_doc.setC4document(c4_doc);

//    SGDocument doc = sg_db_->getDocumentById(id.toStdString());

//    std::vector <string>::iterator iter = document_keys_.begin();

//    QString temp_name = "first_Doc";

//    SGMutableDocument d(sg_db_, (*iter));

//    SGMutableDocument doc(sg_db_,temp_name.toStdString());

    if(!newId.isEmpty()) {
        doc.setId(newId.toStdString());
    }

    if(!body.isEmpty()) {
        doc.setBody(body.toStdString());
    }

    // needs to be saved to show up

    emitUpdate();

    return("");
}

QString DatabaseInterface::deleteDoc(const QString &id)
{
    if(id.isEmpty()) {
        return("Received empty id, cannot delete.");
    }

    SGDocument doc(sg_db_,id.toStdString());

    if(!doc.exist()) {
        return("\nDocument with id = \"" + id + "\" does not exist. Cannot delete.");
    }

    return deleteDoc_(doc);
}

QString DatabaseInterface::deleteDoc_(SGDocument &doc)
{
    sg_db_->deleteDocument(&doc);
    emitUpdate();
    return("");
}

QString DatabaseInterface::saveAs(const QString &id, const QString &path)
{
    if(id.isEmpty() || path.isEmpty()) {
        return("Received empty id or path, unable to save.");
    }

    QDir dir(path);

    if(!dir.isAbsolute()) {
        return("Received invalid path, unable to save.");
    }

    return(saveAs_(id, path));
}

QString DatabaseInterface::saveAs_(const QString &id, const QString &path)
{
    SGDatabase temp_db(id.toStdString(), path.toStdString());

    if(temp_db.open() != SGDatabaseReturnStatus::kNoError) {
        return("Problem saving database.");
    }

    for(std::vector <string>::iterator iter = document_keys_.begin(); iter != document_keys_.end(); iter++) {
        SGMutableDocument temp_doc(&temp_db, (*iter));
        SGDocument existing_doc(sg_db_, (*iter));
        temp_doc.setBody(existing_doc.getBody());
//        temp_db.save(&temp_doc);
    }

    return("");
}

bool DatabaseInterface::setDocumentKeys()
{
    document_keys_.clear();

    if(!sg_db_->getAllDocumentsKey(document_keys_)) {
        DEBUG("Failed to run getAllDocumentsKey()\n");
        return false;
    }
    return true;
}

void DatabaseInterface::setJSONResponse()
{
    QString temp_str = "";
    JSONResponse_ = "{";

    for(std::vector <string>::iterator iter = document_keys_.begin(); iter != document_keys_.end(); iter++) {
        SGDocument usbPDDocument(sg_db_, (*iter));
        temp_str = "\"" + QString((*iter).c_str()) + "\":" + QString(usbPDDocument.getBody().c_str()) + (iter + 1 != document_keys_.end() ? "," : "");
        JSONResponse_ += temp_str;
    }

    JSONResponse_ += "}";
}

QString DatabaseInterface::getJSONResponse()
{
    return JSONResponse_;
}

bool DatabaseInterface::getDBstatus()
{
    return DBstatus_;
}

bool DatabaseInterface::getRepstatus()
{
    return Repstatus_;
}

void DatabaseInterface::setDBstatus(bool status)
{
    DBstatus_ = status;
}

void DatabaseInterface::setRepstatus(bool status)
{
    Repstatus_ = status;
}

QString DatabaseInterface::getFilePath()
{
    return file_path_;
}

void DatabaseInterface::setDBPath(QString db_path)
{
    db_path_ = db_path;
}

QString DatabaseInterface::getDBPath()
{
    return db_path_;
}

void DatabaseInterface::setDBName(QString db_name)
{
    db_name_ = db_name;
}

QString DatabaseInterface::getDBName()
{
    return db_name_;
}
