/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "LogFilesCompress.h"
#include "logging/LoggingQtCategories.h"
#include <QFile>
#include <QStandardPaths>
#include <QGuiApplication>
#include <quazip/quazip.h>
#include <quazip/JlCompress.h>

LogFilesCompress::LogFilesCompress(QObject *parent)
    : QObject{parent}
{

}

bool LogFilesCompress::logExport(QString exportPath)
{
    //check export path
    QDir exportDir(exportPath);
    if (exportDir.exists() == false || QFileInfo(exportPath).isWritable() == false) {
        qCWarning(lcLcu) << "Non-existent or non-writable directory";
        return false;
    }
    const QString timeStamp = QDateTime::currentDateTime().toString("dd-MM-yyyy-hh-mm-ss");
    const QString zipName(exportDir.path() + "/strata-logs-" + timeStamp + ".zip");

    QString logPath{QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)};

    //LCU app compresses log files of app that is chosen in comboBox
    if (QCoreApplication::applicationName() == "Logging Configuration Utility") {
        logPath.replace(QCoreApplication::applicationName(), applicationName);
    }

    //SDS, PRT (or any other app) compresses their own log files
    QDir logDir(logPath);
    QFileInfoList fileInfoList(logDir.entryInfoList({applicationName + "*.log"}, QDir::Files));

    //SDS compresses also HCS log files
    if (QCoreApplication::applicationName() == "Strata Developer Studio") {
        QDir hcsLogDir(logPath.replace(applicationName, "Host Controller Service"));
        fileInfoList << hcsLogDir.entryInfoList({"Host Controller Service*.log"}, QDir::Files);
    }

    if (compress (fileInfoList, zipName)) {
        qCDebug(lcLcu) << "Compressing succesfully completed";
        qCDebug(lcLcu) << "Path to strata-log archive: " << zipName;
        return true;
    } else {
        qCWarning(lcLcu) << "Compressing unsuccessful";
        return false;
    }

}

bool LogFilesCompress::compress(QFileInfoList filesToZip, QString zipName)
{
    QuaZip zip(zipName);
    if (!zip.open(QuaZip::mdCreate)) {
        qCWarning(lcLcu) << "Couldn't open " << zipName;
        return false;
    }

    foreach (QFileInfo fileInfo, filesToZip) {
        QuaZipFile zipFile(&zip);
        QString filePath = fileInfo.absoluteFilePath();
        QString fileName = fileInfo.fileName();
        QuaZipNewInfo newInfo(fileName, filePath);

        if (!zipFile.open(QIODevice::WriteOnly, newInfo, NULL, 0, fileInfo.isDir() ? 0 : 8)) {
            qCWarning(lcLcu) << "Couldn't open " << fileName << " in " << zipName;
            return false;
        }
        if (!fileInfo.isDir()) {
            QFile file(filePath);
            if (!file.open(QIODevice::ReadOnly)) {
                qCWarning(lcLcu) << "Couldn't open " << filePath;
                return false;
            }
            while (!file.atEnd()) {
                char buf[4096];
                qint64 l = file.read(buf, 4096);
                if (l <= 0) {
                    qCWarning(lcLcu) << "Couldn't read " << filePath;
                    return false;
                }
                if (zipFile.write(buf, l) != l) {
                    qCWarning(lcLcu) << "Couldn't write to " << filePath << " in " << zipName;
                    return false;
                }
            }
            file.close();
        }
        zipFile.close();
    }

    zip.setComment(applicationName +" log files archive");
    zip.close();

    if (zipName.startsWith("<")) { // something like "<QIODevice pointer>"
        return false;
    } else {
        qCDebug(lcLcu) << "ZipFile exists: " << QFileInfo::exists(zipName);
        return true;
    }
}

QString LogFilesCompress::appName() const
{
    return applicationName;
}

void LogFilesCompress::setAppName(const QString &appName)
{
    applicationName = appName;

    emit appNameChanged();
}
