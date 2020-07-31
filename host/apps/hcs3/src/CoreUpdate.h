#pragma once

#include <QObject>
#include <QDomDocument>

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
    void versionInfoResponseRequested(QByteArray clientId, QString currentVersion, QString latestVersion, QString errorString);

private:
    void handleCoreUpdateResponse(const QByteArray &clientId, const QString &currentVersion, const QString &latestVersion, const QString &errorString = QString());

    QString getLatestVersion(const QByteArray &clientId);

    QString getCurrentVersion(const QByteArray &clientId);

    QString findVersionFromComponentsXml(const QDomDocument &xmlDocument, const QString &packageName);

    Database* db_{nullptr};
};