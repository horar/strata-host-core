#ifndef DATABASE_H
#define DATABASE_H

#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQmlProperty>
#include <QObject>
#include <QString>
#include "DatabaseImpl.h"

class Database : public QObject
{
    Q_OBJECT
    public:
        explicit Database(QObject *parent = nullptr);
        void init(QQmlApplicationEngine *engine, QQmlComponent *component);
        Q_INVOKABLE QString open(int windowId, QString file_path);
        Q_INVOKABLE QString newDocument(int windowId, QString id, QString body);
        Q_INVOKABLE QString deleteDocument(int windowId, QString id);
        Q_INVOKABLE QString editDocument(int windowId, QString oldId, QString newId, QString body);
        Q_INVOKABLE QString saveAs(int windowId, QString folder_path, QString dbName);
        Q_INVOKABLE void close(int windowId);
        Q_INVOKABLE QString startListening(int windowId, QString url, QString username, QString password, QString type);
        Q_INVOKABLE QString setChannels(int windowId, std::vector<QString> channels);
        Q_INVOKABLE void stopListening(int windowId);
        Q_INVOKABLE QString newDatabase(int windowId, QString folder_path, QString dbName);
        Q_INVOKABLE void newWindow();
        Q_INVOKABLE QString searchDocById(int windowId, QString id);

    public slots:
        void newUpdateSignal(int windowId);

    private:
        QQmlApplicationEngine *engine = nullptr;
        QQmlComponent *component = nullptr;

        int ids = -1;
        std::map<int, QObject*> allWindows;
        std::map<int, DatabaseImpl*> allDatabases;
};

#endif // DATABASE_H
