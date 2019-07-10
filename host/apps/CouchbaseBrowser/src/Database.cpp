#include "Database.h"

Database::Database(QObject *parent) :
    QObject(parent)
{
}

void Database::init(QQmlApplicationEngine *engine, QQmlComponent *component)
{
    this->engine = engine;
    this->component = component;
    newWindow();
}

QString Database::open(int windowId, QString file_path)
{
    DatabaseImpl *db = new DatabaseImpl(windowId);
    allDatabases[windowId] = db;
    QObject::connect(&(*allDatabases[windowId]),&DatabaseImpl::newUpdate, this, &Database::newUpdateSignal);
    return allDatabases[windowId]->setFilePath(file_path);
}

QString Database::newDocument(int windowId, QString id, QString body)
{
    qDebug() << windowId << id << body << endl;
    return allDatabases[windowId]->createNewDoc(id, body);
}

QString Database::deleteDocument(int windowId, QString id)
{
    return allDatabases[windowId]->deleteDoc(id);
}

QString Database::editDocument(int windowId, QString oldId, QString newId, QString body)
{
    return allDatabases[windowId]->editDoc(oldId, newId, body);
}

QString Database::saveAs(int windowId, QString folder_path, QString dbName)
{
    // need to implement
}
void Database::close(int windowId)
{
    delete allDatabases[windowId];
    allDatabases.erase(windowId);
    QQmlProperty::write(allWindows[windowId],"fileName","");
    QQmlProperty::write(allWindows[windowId],"allDocuments","{}");
}

QString Database::startListening(int windowId, QString url, QString username, QString password, QString type)
{
    return allDatabases[windowId]->startListening(url,username,password,type);
}

QString Database::setChannels(int windowId, std::vector<QString> channels)
{
    return allDatabases[windowId]->setChannels(channels);
}

void Database::stopListening(int windowId)
{
    allDatabases[windowId]->stopListening();
}

QString Database::newDatabase(int windowId, QString folder_path, QString dbName)
{
    QDir dir(folder_path);
    QString path = dir.path() + dir.separator() + "db" + dir.separator() + dbName + dir.separator() + "db.sqlite3";
    qDebug() << path << endl;
    int newDatabaseWindowId = windowId;
    if (allDatabases.find(windowId) != allDatabases.end()) {
        newWindow();
        newDatabaseWindowId = ids;
    }
    QString message = open(newDatabaseWindowId,path);
    if (message.length() != 0) {
        delete allDatabases[newDatabaseWindowId];
        allDatabases.erase(newDatabaseWindowId);
        if (newDatabaseWindowId != windowId) {
            delete allWindows[newDatabaseWindowId];
            allWindows.erase(newDatabaseWindowId);
        }
    }
    return message;
}

void Database::newWindow()
{
    ids++;
    engine->load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    allWindows[ids] = engine->rootObjects().last();
    QQmlProperty::write(allWindows[ids],"id",ids);
}

void Database::newUpdateSignal(int windowId)
{
    QQmlProperty::write(allWindows[windowId],"fileName",allDatabases[windowId]->getDBName());
    QQmlProperty::write(allWindows[windowId],"allDocuments",allDatabases[windowId]->getJSONResponse());
}

QString Database::searchDocById(int windowId, QString id)
{
    return allDatabases[windowId]->searchDocById(id);
}
