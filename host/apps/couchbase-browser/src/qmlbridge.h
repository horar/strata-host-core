#ifndef QMLBRIDGE_H
#define QMLBRIDGE_H

#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQmlProperty>
#include <QObject>
#include <QString>
#include "databaseinterface.h"

class QMLBridge : public QObject
{
    Q_OBJECT
    public:
        explicit QMLBridge(QObject *parent = nullptr);
        void init(QQmlApplicationEngine *engine, QQmlComponent *component);
        Q_INVOKABLE QString getDBName(int windowId);
        Q_INVOKABLE void setFilePath(int windowId, QString file_path);
        Q_INVOKABLE bool createNewDocument(int windowId, QString id, QString body);
        Q_INVOKABLE void closeFile(int windowId);
        Q_INVOKABLE QString startReplicator(int windowId, QString hostName, QString username, QString password);
        Q_INVOKABLE void stopReplicator(int windowId);
        Q_INVOKABLE void createNewWindow();

    public slots:
        void newUpdateSignal(int windowId);

    private:
        QQmlApplicationEngine *engine = nullptr;
        QQmlComponent *component = nullptr;

        int ids = -1;
        std::map<int, QObject*> allWindows;
        std::map<int, DatabaseInterface*> allDatabases;
};

#endif // QMLBRIDGE_H
