#include "Database.h"

Database::Database(QObject *parent) :
    QObject(parent)
{
}

void Database::init(QQmlApplicationEngine *engine, QQmlComponent *component)
{
    this->engine = engine;
    this->component = component;
    createNewWindow();
}

QString Database::setFilePath(int windowId, QString file_path)
{
    DatabaseImpl *db = new DatabaseImpl(windowId);
    allDatabases[windowId] = db;
    QObject::connect(&(*allDatabases[windowId]),&DatabaseImpl::newUpdate, this, &Database::newUpdateSignal);
    return allDatabases[windowId]->setFilePath(file_path);
}

QString Database::createNewDatabase(int windowId, bool createWindow, QString folder_path, QString dbName)
{
    QDir dir(folder_path);
    QString path = dir.path() + dir.separator() + "db" + dir.separator() + dbName + dir.separator() + "db.sqlite3";
    qDebug() << path << endl;
    if (createWindow) {
        createNewWindow();
        windowId = ids;
    }
    QString message = setFilePath(windowId,path);
    if (message.length() != 0) {
        delete allDatabases[windowId];
        allDatabases.erase(windowId);
        if (createWindow) {
            delete allWindows[ids];
            allWindows.erase(ids);
            ids--;
        }
    }
    else QQmlProperty::write(allWindows[windowId],"openedFile",true);
    return message;
}

QString Database::createNewDocument(int windowId, QString id, QString body)
{
    qDebug() << windowId << id << body << endl;
    return allDatabases[windowId]->createNewDoc(id, body);
}

QString Database::editDoc(int windowId, QString oldId, QString newId, QString body)
{
    return allDatabases[windowId]->editDoc(oldId, newId, body);
}

QString Database::deleteDoc(int windowId, QString id)
{
    return allDatabases[windowId]->deleteDoc(id);
}

void Database::closeFile(int windowId)
{
    delete allDatabases[windowId];
    allDatabases.erase(windowId);
    QQmlProperty::write(allWindows[windowId],"fileName","");
    QQmlProperty::write(allWindows[windowId],"allDocuments","{}");
}

QString Database::startReplicator(int windowId, QString url, QString username, QString password, QString type, std::vector<QString> channels)
{
    Spyglass::SGReplicatorConfiguration::ReplicatorType rep_type;
    qDebug() << type << endl;
    if (type == "pull") rep_type = Spyglass::SGReplicatorConfiguration::ReplicatorType::kPull;
    if (type == "push") rep_type = Spyglass::SGReplicatorConfiguration::ReplicatorType::kPush;
    if (type == "pushpull") rep_type = Spyglass::SGReplicatorConfiguration::ReplicatorType::kPushAndPull;
    for (unsigned long i = 0;i<channels.size();i++)
        qDebug()<<channels[i]<<" ";
    qDebug()<<endl;
    return allDatabases[windowId]->rep_init(url,username,password,rep_type,channels);
}

void Database::stopReplicator(int windowId)
{
    allDatabases[windowId]->rep_stop();
}

void Database::createNewWindow()
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
