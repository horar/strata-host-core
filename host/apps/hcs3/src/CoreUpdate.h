#pragma once

#include <memory>

#include <QObject>
#include <QStringList>
#include <QMap>
#include <QJsonArray>
#include <QDebug>
#include <QUrl>
#include <QPointer>

class Database;

class CoreUpdate : public QObject
{
    Q_OBJECT

public:
    // CoreUpdate(QObject* parent = nullptr);
    // ~CoreUpdate();

    /**
     * Sets the database pointer
     * @param db
     */
    void setDatabase(Database* db);

public slots:
    void requestVersionInfo(const QByteArray &clientId);

private:
    Database* db_{nullptr};

};