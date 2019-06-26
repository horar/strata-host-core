#ifndef DATABASEINTERFACE_H
#define DATABASEINTERFACE_H

#include <QObject>
#include <QCoreApplication>
#include <QTextStream>
#include <QFileDialog>
#include <QTextEdit>
#include <QDir>
#include <QQmlProperty>
#include <QDebug>

#include <iostream>

#include "SGFleece.h"
#include "SGCouchBaseLite.h"

using namespace std;
using namespace fleece;
using namespace fleece::impl;
using namespace std::placeholders;
using namespace Spyglass;

class DatabaseInterface
{

public:
    DatabaseInterface(QString file_path);

    QString m_file_path, m_db_path, m_db_name;

    void setFilePath(QString file_path);

    QString getFilePath();

    void setDBPath(QString db_path);

    QString getDBPath();

    void setDBName(QString db_name);

    QString getDBName();

    void parseFilePath();

    SGDatabase *sg_db{nullptr};

    int db_init();

    vector<string> document_keys;

    int setDocumentKeys();

    QString JSONResponse;

    void setJSONResponse();

    QString getJSONResponse();
};

#endif // DATABASEINTERFACE_H
