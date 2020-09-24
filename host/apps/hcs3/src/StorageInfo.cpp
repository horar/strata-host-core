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
    qCDebug(logCategoryHcsStorageCache) << "Cache location:" << cacheDir_.absolutePath();
}

void StorageInfo::calculateSize() const
{
    const auto dirs{cacheDir_.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot)};
    if (dirs.isEmpty()) {
        qCDebug(logCategoryHcsStorageCache) << "Cache folders not created yet";
        return;
    }

    QFuture<FolderSize> future = QtConcurrent::mapped(dirs, scanFolder);
    future.waitForFinished();

    QLocale locale;
    for (const auto& [folderName, folderSize] : future.results()) {
        qCDebug(logCategoryHcsStorageCache) << locale.formattedDataSize(folderSize) << "in" << folderName;
    }
}
