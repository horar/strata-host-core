#include "databaseinterface.h"

#include "QJsonDocument"
#include "QJsonObject"

using namespace std;
using namespace std::placeholders;
using namespace Spyglass;

#define DEBUG(...) printf("TEST Database Interface: "); printf(__VA_ARGS__)

DatabaseInterface::DatabaseInterface(QObject *parent) : QObject (parent)
{
}

DatabaseInterface::DatabaseInterface(const QString &file_path, const int &id) : file_path_(file_path), id_(id)
{
    if(!parseFilePath()) {
        DEBUG("Problem parsing file path.");
    } else if(!db_init()) {
        DEBUG("Problem initializing database.");
    }
}

DatabaseInterface::~DatabaseInterface()
{
    std::cout << "\n\nDestructor activated\n\n" << endl;
}

void DatabaseInterface::emitUpdate()
{
    setDocumentKeys();
    setJSONResponse();
    emit newUpdate(this->id_);
}

bool DatabaseInterface::createNewDoc(const QString &id, const QString &body)
{
    if(id.isEmpty() || body.isEmpty()) {
        DEBUG("Document's id or body contents may not be empty.");
        return false;
    }

    SGMutableDocument newDoc(sg_db_,id.toStdString());

    if (!newDoc.exist()) {
        DEBUG("Error initializing new document.");
        return false;
    }

    if(!newDoc.setBody(body.toStdString())) {
        DEBUG("Error setting body contents to created document.");
        return false;
    }

    emitUpdate();
    return true;
}

 bool DatabaseInterface::db_init()
{
    sg_db_ = new SGDatabase(db_name_.toStdString(), db_path_.toStdString());
    setDBstatus(false);

    if (!sg_db_->isOpen()) {
        DEBUG("Db is not open yet\n");
    }

    if (sg_db_->open() != SGDatabaseReturnStatus::kNoError) {
        DEBUG("Can't open DB!\n");
        return false;
    }

    if (sg_db_->isOpen()) {
        DEBUG("DB is open using isOpen API\n");
    } else {
        DEBUG("DB is not open, exiting!\n");
        return false;
    }

    setDBstatus(true);
    setDocumentKeys();
    setJSONResponse();

    // temporarily hard coded:
    rep_init();

    return true;
}

void DatabaseInterface::rep_init()
{
    // temporarily hard coded:

    setRepstatus(false);

    qDebug() << "\n\nin rep_init()\n\n";

    std::string url = "ws://localhost:4984/db2";

    url_endpoint_ = new SGURLEndpoint(url);

    if(url_endpoint_->init()) {
        DEBUG("url_endpoint is valid \n");
    } else {
        DEBUG("Invalid url_endpoint\n");
        return;
    }

    DEBUG("host %s, \n", url_endpoint_->getHost().c_str());
    DEBUG("schema %s, \n", url_endpoint_->getSchema().c_str());
    DEBUG("getPath %s, \n", url_endpoint_->getPath().c_str());

    sg_replicator_configuration_ = new SGReplicatorConfiguration(sg_db_, url_endpoint_);
    sg_replicator_configuration_->setReplicatorType(SGReplicatorConfiguration::ReplicatorType::kPull);
    sg_replicator_ = new SGReplicator(sg_replicator_configuration_);
    sg_replicator_->addDocumentEndedListener(std::bind(&DatabaseInterface::emitUpdate, this));

    if(sg_replicator_->start() == false) {
        DEBUG("Problem with start of replication.");
        return;
    }

    setRepstatus(true);
}

void DatabaseInterface::setFilePath(QString file_path)
{
    file_path_ = file_path;
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

bool DatabaseInterface::parseFilePath()
{
    QFileInfo info(file_path_);

    if(!info.exists() || info.fileName() != "db.sqlite3") {
        DEBUG("Problem with path to database file. The file must be located according to: \".../db/(db_name)/db.sqlite3\" \n");
        return false;
    }

    QDir dir(file_path_);

    if(!dir.cdUp()) {
        DEBUG("Problem with path to database file. The file must be located according to: \".../db/(db_name)/db.sqlite3\" \n");
        return false;
    }

    setDBName(dir.dirName());

    if(!dir.cdUp() || !dir.cdUp()) {
        DEBUG("Problem with path to database file. The file must be located according to: \".../db/(db_name)/db.sqlite3\" \n");
        return false;
    }

    setDBPath(dir.path() + dir.separator());

    return true;
}

int DatabaseInterface::setDocumentKeys()
{
    document_keys_.clear();

    if(!sg_db_->getAllDocumentsKey(document_keys_)) {
        DEBUG("Failed to run getAllDocumentsKey()\n");
        return 1;
    }
    return 0;
}

void DatabaseInterface::setJSONResponse()
{
    QString temp_str = "";
    JSONResponse_ = "{";

    // Printing the list of documents key from the local DB.
    for(std::vector <string>::iterator iter = document_keys_.begin(); iter != document_keys_.end(); iter++) {
        SGDocument usbPDDocument(sg_db_, (*iter));
        temp_str = "\"" + QString((*iter).c_str()) + "\":" + QString(usbPDDocument.getBody().c_str()) + (iter + 1 == document_keys_.end() ? "}" : ",");
        JSONResponse_ = JSONResponse_ + temp_str;
    }
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
