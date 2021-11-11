/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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

    QString acquireUpdateInfo(const QString &updateMetadata, QJsonArray &updateInfo) const;

    QString parseUpdateMetadata(const QDomDocument &xmlDocument, const QMap<QString, QString>& componentMap, QJsonArray &updateInfo) const;

    QString parseUpdateSize(const QString &updateSize) const;

    void preprocessOpenSSLVersion(QString& opensslVersion) const;

    QString getCurrentVersionOfComponents(QMap<QString, QString>& componentMap) const;

    QString acquireUpdateMetadata(QString &updateMetadata) const;

    QString locateMaintenanceTool(const QDir &applicationDir, QString &absPathMaintenanceTool) const;

    QString launchMaintenanceTool(const QString &absPathMaintenanceTool, const QDir &applicationDir, QString &updateMetadata) const;
};
