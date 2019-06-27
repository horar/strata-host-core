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
        Q_INVOKABLE int CreateNewWindow();
        Q_INVOKABLE void setFilePath(QString file_path);
        Q_INVOKABLE QString getDBName();

    public slots:
        void newUpdateSignal();

    private:
        QQmlApplicationEngine *engine = nullptr;
        QQmlComponent *component = nullptr;

        int ids = -1;
        QObject *windowObject = nullptr;
        DatabaseInterface *db = nullptr;
};

#endif // QMLBRIDGE_H
