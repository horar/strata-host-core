#include "qmlbridge.h"

QMLBridge::QMLBridge(QObject *parent) :
    QObject(parent)
{
}

void QMLBridge::init(QQmlApplicationEngine *engine, QQmlComponent *component)
{
    this->engine = engine;
    this->component = component;
    createNewWindow();
}

QString QMLBridge::getDBName(int windowId)
{
    return allDatabases[windowId]->getDBName();
}

QString QMLBridge::setFilePath(int windowId, QString file_path)
{
    DatabaseInterface *db = new DatabaseInterface(windowId);
    allDatabases[windowId] = db;
    QObject::connect(&(*allDatabases[windowId]),&DatabaseInterface::newUpdate, this, &QMLBridge::newUpdateSignal);
    return allDatabases[windowId]->setFilePath(file_path);
}

QString QMLBridge::createNewDatabase(QString folder_path, QString dbName)
{
    createNewWindow();
    QDir dir(folder_path);
    QString path = dir.path() + dir.separator() + "db" + dir.separator() + dbName + dir.separator() + "db.sqlite3";
    qDebug() << path << endl;
    QString message = setFilePath(ids,path);
    if (message.length() != 0) {
        delete allWindows[ids];
        allWindows.erase(ids);
        delete allDatabases[ids];
        allDatabases.erase(ids);
        ids--;
    }
    return message;
}

bool QMLBridge::createNewDocument(int windowId, QString id, QString body)
{
    qDebug() << windowId << id << body << endl;
    return allDatabases[windowId]->createNewDoc(id, body);
}

void QMLBridge::closeFile(int windowId)
{
    delete allDatabases[windowId];
    allDatabases.erase(windowId);
    QQmlProperty::write(allWindows[windowId],"fileName","");
    QQmlProperty::write(allWindows[windowId],"content","");
}

QString QMLBridge::startReplicator(int windowId, QString hostName, QString username, QString password)
{
    return allDatabases[windowId]->rep_init(hostName,username,password);
}

void QMLBridge::stopReplicator(int windowId)
{
    allDatabases[windowId]->rep_stop();
}

void QMLBridge::createNewWindow()
{
    ids++;
    engine->load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    allWindows[ids] = engine->rootObjects().last();
    QQmlProperty::write(allWindows[ids],"id",ids);
}

void QMLBridge::newUpdateSignal(int windowId)
{
    QQmlProperty::write(allWindows[windowId],"fileName",allDatabases[windowId]->getDBName());
    QQmlProperty::write(allWindows[windowId],"content",allDatabases[windowId]->getJSONResponse());
}
