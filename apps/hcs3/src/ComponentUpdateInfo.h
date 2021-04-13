#pragma once

#include <QObject>
#include <QDir>
#include <QDomDocument>
#include <QJsonArray>

class Database;

class ComponentUpdateInfo : public QObject
{
    Q_OBJECT

public slots:
    void requestUpdateInfo(const QByteArray &clientId);

signals:
    void requestUpdateInfoFinished(QByteArray clientId, QJsonArray componentList, QString errorString);

private:
    void handleUpdateInfoResponse(const QByteArray &clientId, QJsonArray componentList, const QString &errorString);

    QString acquireUpdateInfo(const QString &updateMetadata, QJsonArray &updateInfo);

    QString parseUpdateMetadata(const QDomDocument &xmlDocument, const QMap<QString, QString>& componentMap, QJsonArray &updateInfo);

    QString parseUpdateSize(QString updateSize);

    QString getCurrentVersionOfComponents(QMap<QString, QString>& componentMap);

    QString acquireUpdateMetadata(QString &updateMetadata);

    QString locateMaintenanceTool(const QDir &applicationDir, QString &absPathMaintenanceTool);

    QString launchMaintenanceTool(const QString &absPathMaintenanceTool, const QDir &applicationDir, QString &updateMetadata);
};
