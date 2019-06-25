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

class DatabaseInterface : public QObject
{
    Q_OBJECT

public:
    explicit DatabaseInterface(QObject *parent = nullptr);

    //DatabaseInterface(QString file_path);

    QObject *mainComponent;
    void setMainComponent(QObject *component);

    QString m_file_path, m_db_path, m_db_name;

    Q_INVOKABLE void setFilePath(QString file_path);

    Q_INVOKABLE QString getFilePath();

    Q_INVOKABLE void setDBPath(QString db_path);

    Q_INVOKABLE QString getDBPath();

    Q_INVOKABLE void setDBName(QString db_name);

    Q_INVOKABLE QString getDBName();

    void parseFilePath();

    SGDatabase *sg_db{nullptr};

    int db_init();

    vector<string> document_keys;

    vector<QString> document_contents;

    int setDocumentKeys();

    Q_INVOKABLE void setDocumentContents();

    Q_INVOKABLE vector<QString> getDocumentContents();
};

#endif // DATABASEINTERFACE_H
