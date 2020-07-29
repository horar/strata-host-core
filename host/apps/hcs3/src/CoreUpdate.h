#pragma once

#include <memory>

#include <QObject>

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

signals:
    void versionInfoResponseRequested(QByteArray clientId, QString latest_version);

private:
    void handleCoreUpdateResponse(const QByteArray &clientId, const QString &latest_version);

    Database* db_{nullptr};

};