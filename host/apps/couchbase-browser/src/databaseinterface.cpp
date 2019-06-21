#include "databaseinterface.h"

#define DEBUG(...) printf("TEST Database Interface: "); printf(__VA_ARGS__)

DatabaseInterface::DatabaseInterface(QString file_path) : m_file_path(file_path)
{
    parseFilePath();

    db_init();
}

int DatabaseInterface::db_init()
{
    sg_db = new SGDatabase(m_db_name.toStdString(), m_db_path.toStdString());


    //  SGDatabase sg_db(database_name.toStdString(), database_path.toStdString());

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

    cout << "about to call set document contens...." << endl;

    setDocumentKeys();
    setDocumentContents();

    return 0;
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
    if(!sg_db->getAllDocumentsKey(document_keys)) {
        DEBUG("Failed to run getAllDocumentsKey()\n");
        return 1;
    }
    return 0;
}

void DatabaseInterface::setDocumentContents()
{
    QString str;

    // Printing the list of documents key from the local DB.
    for(std::vector <string>::iterator iter = document_keys.begin(); iter != document_keys.end(); iter++) {

        SGDocument usbPDDocument(sg_db, (*iter));

        pair<string,string> keyAndValue;

        keyAndValue.first = (*iter).c_str();
        keyAndValue.second = usbPDDocument.getBody().c_str();

        document_contents.push_back(keyAndValue);
    }
}

vector<pair<string,string>> DatabaseInterface::getDocumentContents()
{
    return document_contents;
}
