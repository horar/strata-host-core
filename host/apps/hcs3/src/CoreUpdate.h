#pragma once

#include <QObject>
#include <QDomDocument>

class Database;

class CoreUpdate : public QObject
{
    Q_OBJECT

public:
    void setDatabase(Database* db);

public slots:
    void requestVersionInfo(const QByteArray &clientId);
    void requestUpdateApplication(const QByteArray &clientId);

signals:
    void versionInfoResponseRequested(QByteArray clientId, QString currentVersion, QString latestVersion, QString errorString);
    void updateApplicationResponseRequested(QByteArray clientId, QString errorString);

private:
    void handleVersionInfoResponse(const QByteArray &clientId, const QString &currentVersion, const QString &latestVersion, const QString &errorString = QString());
    void handleUpdateApplicationResponse(const QByteArray &clientId, const QString &errorString = QString());

    QString getLatestVersion(const QByteArray &clientId);

    QString getCurrentVersion(const QByteArray &clientId);

    QString findVersionFromComponentsXml(const QDomDocument &xmlDocument, const QString &packageName);

    Database* db_{nullptr};
};