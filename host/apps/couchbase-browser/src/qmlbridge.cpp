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

int QMLBridge::createNewWindow()
{
    ids++;
    engine->load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    //allWindows.insert(windowPair(ids,engine->rootObjects()[ids]));
    allWindows[ids] = engine->rootObjects()[ids];
    QQmlProperty::write(allWindows[ids],"id",ids);
    return ids;
}

void QMLBridge::setFilePath(int windowId, QString file_path)
{
    DatabaseInterface *db = new DatabaseInterface(file_path, windowId);
    allDatabases[windowId] = db;
    QObject::connect(&(*allDatabases[windowId]),&DatabaseInterface::newUpdate, this, &QMLBridge::newUpdateSignal);
    QQmlProperty::write(allWindows[windowId],"fileName",allDatabases[windowId]->getDBName());
    QQmlProperty::write(allWindows[windowId],"content",allDatabases[windowId]->getJSONResponse());
}

void QMLBridge::createNewDocument(int windowId, QString id, QString body)
{
    qDebug() << windowId << id << body << endl;
    qDebug() << allDatabases[windowId]->createNewDoc(id, body);
}

void QMLBridge::closeFile(int windowId)
{
    delete allDatabases[windowId];
    allDatabases.erase(windowId);
    QQmlProperty::write(allWindows[windowId],"fileName","");
    QQmlProperty::write(allWindows[windowId],"content","");
}

void QMLBridge::newUpdateSignal(int windowId)
{
    QQmlProperty::write(allWindows[windowId],"fileName",allDatabases[windowId]->getDBName());
    QQmlProperty::write(allWindows[windowId],"content",allDatabases[windowId]->getJSONResponse());
}
