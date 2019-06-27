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

void QMLBridge::setFilePath(int id, QString file_path)
{
    DatabaseInterface *db = new DatabaseInterface(file_path, id);
    //allDatabases.insert(databasePair(id, db));
    allDatabases[id] = db;
    QObject::connect(&(*allDatabases[id]),&DatabaseInterface::newUpdate, this, &QMLBridge::newUpdateSignal);
    QQmlProperty::write(allWindows[id],"fileName",allDatabases[id]->getDBName());
    QQmlProperty::write(allWindows[id],"content",allDatabases[id]->getJSONResponse());
}

void QMLBridge::newUpdateSignal(int id)
{
    QQmlProperty::write(allWindows[id],"fileName",allDatabases[id]->getDBName());
    QQmlProperty::write(allWindows[id],"content",allDatabases[id]->getJSONResponse());
}
