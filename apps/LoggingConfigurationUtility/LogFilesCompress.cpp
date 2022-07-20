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
#include <QDir>
#include <QFile>
#include <quazip/quazip.h>
#include <quazip/JlCompress.h>

LogFilesCompress::LogFilesCompress(QObject *parent)
    : QObject{parent}
{

}

void LogFilesCompress::compress()
{
    QDir dir;
    QStringList fileList = dir.entryList();

    QuaZip zip("file.zip");
    //zip.open(QuaZip::mdUnzip);
    //JlCompress::compressFiles("zip",fileList);
    //QuaZip file("file");
    qCDebug(lcLcu) << "compressing begins ";
}
