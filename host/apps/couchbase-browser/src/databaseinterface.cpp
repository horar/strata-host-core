#include "databaseinterface.h"

#include "QJsonDocument"
#include "QJsonObject"

#define DEBUG(...) printf("TEST Database Interface: "); printf(__VA_ARGS__)

DatabaseInterface::DatabaseInterface(QObject *parent) :
    QObject (parent)
{
}

//void onDocumentEnded(bool pushing, std::string doc_id, std::string error_message, bool is_error,bool transient){
//    DEBUG("onDocumentError: pushing: %d, Doc Id: %s, is error: %d, error message: %s, transient:%d\n", pushing, doc_id.c_str(), is_error, error_message.c_str(), transient);
//    // send signal here
//    emit newUpdate(true);
//}

DatabaseInterface::DatabaseInterface(QString file_path) : m_file_path(file_path)
{
    parseFilePath();
    db_init();
}

DatabaseInterface::~DatabaseInterface()
{
    std::cout << "\n\nDestructor activated\n\n" << endl;
}

void DatabaseInterface::test(bool /*pushing*/, std::string doc_id, std::string /*error_message*/, bool /*is_error*/, bool /*error_is_transient*/)
{
    std::cout << "\n\nin test function \n\n" << endl;
    emit newUpdate();
}

int DatabaseInterface::db_init()
{
    sg_db = new SGDatabase(m_db_name.toStdString(), m_db_path.toStdString());

    if (!sg_db->isOpen()) {
        DEBUG("Db is not open yet\n");
    }

    if (sg_db->open() != SGDatabaseReturnStatus::kNoError) {
        DEBUG("Can't open DB!\n");
        return 1;
    }

    if (sg_db->isOpen()) {
        DEBUG("DB is open using isOpen API\n");
    } else {
        DEBUG("DB is not open, exiting!\n");
        return 1;
    }

    setDocumentKeys();
    setJSONResponse();

    // temporarily hard coded:
    rep_init();

    return 0;
}

void DatabaseInterface::rep_init()
{
    qDebug() << "\n\nin rep_init()\n\n";

    std::string url = "ws://localhost:4984/db2";

    url_endpoint = new SGURLEndpoint(url);

    if(url_endpoint->init())
    {
        DEBUG("url_endpoint is valid \n");
    }
    else
    {
        DEBUG("Invalid url_endpoint\n");
        return;
    }

    DEBUG("host %s, \n", url_endpoint->getHost().c_str());
    DEBUG("schema %s, \n", url_endpoint->getSchema().c_str());
    DEBUG("getPath %s, \n", url_endpoint->getPath().c_str());

    sg_replicator_configuration = new SGReplicatorConfiguration(sg_db, url_endpoint);
    sg_replicator_configuration->setReplicatorType(SGReplicatorConfiguration::ReplicatorType::kPull);
    sg_replicator = new SGReplicator(sg_replicator_configuration);
//    sg_replicator->addDocumentEndedListener(onDocumentEnded);

//    sg_replicator->addDocumentEndedListener(test);

    sg_replicator->addDocumentEndedListener(std::bind(&DatabaseInterface::test, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3, std::placeholders::_4, std::placeholders::_5));


    if(sg_replicator->start() == false)
    {
        std::cout << "\n PROBLEM WITH REPLICATION START, EXITING." << endl;
        return;
    }

    setDocumentKeys();
    setJSONResponse();
}

void DatabaseInterface::setFilePath(QString file_path)
{
    m_file_path = file_path;
}

QString DatabaseInterface::getFilePath()
{
    return m_file_path;
}

void DatabaseInterface::setDBPath(QString db_path)
{
    m_db_path = db_path;
}

QString DatabaseInterface::getDBPath()
{
    return m_db_path;
}

void DatabaseInterface::setDBName(QString db_name)
{
    m_db_name = db_name;
}

QString DatabaseInterface::getDBName()
{
    return m_db_name;
}

void DatabaseInterface::parseFilePath()
{
    QDir dir(m_file_path);
    dir.cdUp();
    setDBName(dir.dirName());
    dir.cdUp(); dir.cdUp();
    setDBPath(dir.path() + dir.separator());
}

int DatabaseInterface::setDocumentKeys()
{
    document_keys.clear();

    if(!sg_db->getAllDocumentsKey(document_keys)) {
        DEBUG("Failed to run getAllDocumentsKey()\n");
        return 1;
    }
    return 0;
}

void DatabaseInterface::setJSONResponse()
{
    QString temp_str = "";
    JSONResponse = "{";

    // Printing the list of documents key from the local DB.
    for(std::vector <string>::iterator iter = document_keys.begin(); iter != document_keys.end(); iter++) {
        SGDocument usbPDDocument(sg_db, (*iter));
        temp_str = "\"" + QString((*iter).c_str()) + "\":" + QString(usbPDDocument.getBody().c_str()) + (iter + 1 == document_keys.end() ? "}" : "\",");
        JSONResponse = JSONResponse + temp_str;
    }
}

QString DatabaseInterface::getJSONResponse()
{
    return JSONResponse;
}
