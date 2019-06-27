#ifndef QMLBRIDGE_H
#define QMLBRIDGE_H

#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQmlProperty>
#include <QObject>
#include <QString>
#include "databaseinterface.h"

//typedef std::pair<int, QObject*> windowPair;
//typedef std::pair<int, DatabaseInterface*> databasePair;

class QMLBridge : public QObject
{
    Q_OBJECT
    public:
        explicit QMLBridge(QObject *parent = nullptr);
        void init(QQmlApplicationEngine *engine, QQmlComponent *component);
        Q_INVOKABLE int createNewWindow();
        Q_INVOKABLE void setFilePath(int id, QString file_path);

    public slots:
        void newUpdateSignal(int id);

    private:
        QQmlApplicationEngine *engine = nullptr;
        QQmlComponent *component = nullptr;

        int ids = -1;
        std::map<int, QObject*> allWindows;
        std::map<int, DatabaseInterface*> allDatabases;
};

#endif // QMLBRIDGE_H
