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

void QMLBridge::setFilePath(int windowId, QString file_path)
{
    DatabaseInterface *db = new DatabaseInterface(file_path, windowId);
    allDatabases[windowId] = db;
    QObject::connect(&(*allDatabases[windowId]),&DatabaseInterface::newUpdate, this, &QMLBridge::newUpdateSignal);
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
    //allDatabases[windowId]->rep_stop();
}

void QMLBridge::createNewWindow()
{
    ids++;
    engine->load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    allWindows[ids] = engine->rootObjects()[ids];
    QQmlProperty::write(allWindows[ids],"id",ids);
}

void QMLBridge::newUpdateSignal(int windowId)
{
    QQmlProperty::write(allWindows[windowId],"fileName",allDatabases[windowId]->getDBName());
    QQmlProperty::write(allWindows[windowId],"content",allDatabases[windowId]->getJSONResponse());
}
