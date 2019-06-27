#include "qmlbridge.h"

QMLBridge::QMLBridge(QObject *parent) :
    QObject(parent)
{
}

void QMLBridge::init(QQmlApplicationEngine *engine, QQmlComponent *component)
{
    this->engine = engine;
    this->component = component;
    CreateNewWindow();
}

int QMLBridge::CreateNewWindow()
{
    ids++;
    engine->load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    windowObject = engine->rootObjects()[ids];
    QQmlProperty::write(windowObject,"id",ids);
    return ids;
}

void QMLBridge::setFilePath(QString file_path)
{
    db = new DatabaseInterface(file_path);
    QObject::connect(&(*db),&DatabaseInterface::newUpdate, this, &QMLBridge::newUpdateSignal);
    QQmlProperty::write(windowObject,"fileName",db->getDBName());
    QQmlProperty::write(windowObject,"content",db->getJSONResponse());
}

QString QMLBridge::getDBName()
{
    return db->getDBName();
}

void QMLBridge::newUpdateSignal()
{
    qDebug() << "Got signal" << endl;
}
