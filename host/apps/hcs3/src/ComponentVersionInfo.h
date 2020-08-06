#pragma once

#include <QObject>
#include <QDir>
#include <QDomDocument>

class Database;

class ComponentVersionInfo : public QObject
{
    Q_OBJECT

public:
    void setDatabase(Database* db);

public slots:
    void requestVersionInfo(const QByteArray &clientId);

signals:
    void versionInfoResponseRequested(QByteArray clientId, QString currentVersion, QString latestVersion, QString errorString);

    void updateApplicationResponseRequested(QByteArray clientId, QString errorString);

private:
    void handleVersionInfoResponse(const QByteArray &clientId, const QString &currentVersion, const QString &latestVersion, const QString &errorString = QString());

    QString getLatestVersionOfComponent(const QByteArray &clientId);

    QString getCurrentVersionOfComponent(const QByteArray &clientId);

    QString findVersionFromComponentsXml(const QDomDocument &xmlDocument, const QString &packageName);

    QString locateMaintenanceTool(const QByteArray &clientId, const QDir &applicationDir);

    Database* db_{nullptr};
};