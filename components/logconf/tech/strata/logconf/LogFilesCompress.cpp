/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "LogFilesCompress.h"
#include "QtCore/qregularexpression.h"
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

bool LogFilesCompress::logExport(QString exportPath, QStringList fileNamesToZip)
{
    //check export path
    QDir exportDir(exportPath);
    if (exportDir.exists() == false || QFileInfo(exportPath).isWritable() == false) {
        emit showExportMessage("Log-export failed.  Non-existent or non-writable directory.", true);
        return false;
    }
    const QString timeStamp = QDateTime::currentDateTime().toString("yyyy-MM-dd-hh-mm-ss");
    QString zipName(exportDir.path() + "/strata-logs-" + timeStamp);

    while (QFile::exists(zipName + ".zip")) {
        QStringList nameSplit = zipName.split("_");
        if (nameSplit.length() == 1) {
            zipName.replace(timeStamp, timeStamp + "_1");
        } else {
            int newSuffix = nameSplit.at(1).toInt() + 1;
            zipName.replace(QRegularExpression("_\\d"), "_" + QString::number(newSuffix));
        }
    }
    zipName.append(".zip");

    QFileInfoList fileInfoList;

    foreach (QString fileName, fileNamesToZip) {
        QString logPath{QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)};
        logPath.replace(QCoreApplication::applicationName(), fileName);
        QDir logDir(logPath);
        fileInfoList << QFileInfoList(logDir.entryInfoList({fileName + "*.log"}, QDir::Files));
    }

    int zipError = compress (fileInfoList, zipName);

    if ( zipError == 0) {
        qCDebug(lcLcu) << "Compressing succesfully completed ";
        QFileInfo zipFile(zipName);
        emit showExportMessage("Logs exported successfully as: " + zipFile.fileName(), false);
        return true;
    } else {
        emit showExportMessage("Compressing unsuccessful.  ERROR: " + QString::number(zipError), true);
        return false;
    }
}

int LogFilesCompress::compress(QFileInfoList filesToZip, QString zipName)
{
    QuaZip zip(zipName);
    if (!zip.open(QuaZip::mdCreate)) {
        qCWarning(lcLcu) << "Couldn't open " << zipName;
        return zip.getZipError();
    }

    foreach (QFileInfo fileInfo, filesToZip) {
        QuaZipFile zipFile(&zip);
        QString filePath = fileInfo.absoluteFilePath();
        QString fileName = fileInfo.fileName();
        QuaZipNewInfo newInfo(fileName, filePath);

        if (!zipFile.open(QIODevice::WriteOnly, newInfo, NULL, 0, fileInfo.isDir() ? 0 : 8)) {
            qCWarning(lcLcu) << "Couldn't open " << fileName << " in " << zipName;
            return zipFile.getZipError();
        }
        if (!fileInfo.isDir()) {
            QFile file(filePath);
            if (!file.open(QIODevice::ReadOnly)) {
                qCWarning(lcLcu) << "Couldn't open " << filePath;
                return file.error();
            }
            while (!file.atEnd()) {
                char buf[4096];
                qint64 l = file.read(buf, 4096);
                if (l <= 0) {
                    qCWarning(lcLcu) << "Couldn't read " << filePath;
                    return file.error();
                }
                if (zipFile.write(buf, l) != l) {
                    qCWarning(lcLcu) << "Couldn't write to " << filePath << " in " << zipName;
                    return zipFile.getZipError();
                }
            }
            file.close();
        }
        zipFile.close();
    }

    zip.setComment("Strata-log archive");
    zip.close();

    return  zip.getZipError();
}
