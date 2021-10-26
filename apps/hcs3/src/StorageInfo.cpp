/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "StorageInfo.h"

#include "logging/LoggingQtCategories.h"

#include <QDirIterator>
#include <QFuture>
#include <QtConcurrent>


namespace {

StorageInfo::FolderSize scanFolder(const QFileInfo& folderInfo)
{
    QDirIterator it(folderInfo.absoluteFilePath(), QDir::Files | QDir::NoSymLinks, QDirIterator::Subdirectories);

    qint64 filesSize{0};
    while (it.hasNext()) {
        it.next();
        filesSize += it.fileInfo().size();
    }

    return {folderInfo.fileName(), filesSize};
}

}


StorageInfo::StorageInfo(QObject * /*parent*/, QString cacheDir) : cacheDir_(std::move(cacheDir))
{
    qCDebug(lcHcsStorageCache) << "Cache location:" << cacheDir_.absolutePath();
}

void StorageInfo::calculateSize() const
{
    const auto dirs{cacheDir_.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot)};
    if (dirs.isEmpty()) {
        qCDebug(lcHcsStorageCache) << "Cache folders not created yet";
        return;
    }

    QFuture<FolderSize> future = QtConcurrent::mapped(dirs, scanFolder);
    future.waitForFinished();

    QLocale locale;
    for (const auto& [folderName, folderSize] : future.results()) {
        qCDebug(lcHcsStorageCache) << locale.formattedDataSize(folderSize) << "in" << folderName;
    }
}
