/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>
#include <QDir>

class LogFilesCompress : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(LogFilesCompress)

public:
    explicit LogFilesCompress(QObject *parent = nullptr);

    Q_INVOKABLE bool logExport(QString exportPath, QStringList fileNamesToZip);
    Q_INVOKABLE bool checkExportPath(QString exportPath);
    Q_INVOKABLE bool createFolderForFile(const QString &filePath);

    int compress (QFileInfoList filesToZip, QString zipName);

signals:
    void showExportMessage(QString msg, bool error);
    void nonExistentDirectory();
};