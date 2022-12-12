/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "LogModel.h"
#include "logging/LoggingQtCategories.h"

#include <QFile>
#include <QFileInfo>
#include <QTimer>

using namespace std;


LogModel::LogModel(QObject *parent)
    : QAbstractListModel(parent),
      fileModel_()
{
    setModelRoles();
    timer_ = new QTimer(this);
    connect (timer_, &QTimer::timeout, this, &LogModel::checkFile);
}

LogModel::~LogModel()
{
    clear();
    timer_->stop();
    delete timer_;
}

QString LogModel::populateModel(const QString &path)
{
    QFile file(path);

    if (file.open(QIODevice::ReadOnly | QIODevice::Text) == false) {
        qCWarning(lcLogViewer).nospace().noquote() << "Cannot open file '" + path + "': " + file.errorString();
        return file.errorString();
    }

    int fileIndex = fileModel_.getFileIndex(path);
    if (fileIndex < 0) {
        fileIndex = fileModel_.append(path);
    }

    FileModel::FileMetadata metadata = fileModel_.getFileMetadataAt(fileIndex);

    file.seek(metadata.lastPosition);

    QList<LogItem*> chunk;
    QList<LogItem*>::iterator upperBound = data_.begin();
    const uint hash = qHash(path);

    while (file.atEnd() == false) {
        QByteArray line = file.readLine();

        if (metadata.lastPartialLine.isEmpty() == false) {
            line = metadata.lastPartialLine + line;
            metadata.lastPartialLine.clear();
        }

        if (line.endsWith('\n')) {
            line.chop(1);  // remove new-line character
        } else {
            metadata.lastPartialLine = line;
            continue;  // skip incomplete lines
        }

        LogItem *item = parseLine(line, metadata);
        item->filehash = hash;

        if ((upperBound != data_.end()) && (*item >= **upperBound)) {
            QList<LogItem*>::iterator afterChunk = insertChunk(upperBound, chunk);
            upperBound = std::upper_bound(afterChunk, data_.end(), item, LogItem::comparator);
            chunk.clear();
        }
        chunk.append(item);
    }
    insertChunk(upperBound, chunk);

    metadata.lastPosition = file.pos();
    fileModel_.setFileMetadataAt(fileIndex, metadata);

    if (followingInitialized_ == false) {
        timer_->start(std::chrono::milliseconds(500));
        followingInitialized_ = true;
    }

    emit countChanged();
    updateTimestamps();
    return "";
}

QList<LogItem*>::iterator LogModel::insertChunk(QList<LogItem*>::iterator insertIter, const QList<LogItem*> &chunk)
{
    if (chunk.isEmpty() == false) {
        int position = insertIter - data_.begin();

        beginInsertRows(QModelIndex(), position, position + chunk.size() - 1);
        for (int i = 0; i < chunk.size(); ++i) {
            insertIter = data_.insert(insertIter, chunk.at(i)) + 1;
        }
        endInsertRows();
    }

    return insertIter;
}

QString LogModel::followFile(const QString &path)
{
    if (fileModel_.containsFilePath(path)) {
        qCWarning(lcLogViewer).nospace().noquote() << "Cannot open file '" + path + "': file is already opened";
        return "File is already opened";
    } else {
        return populateModel(path);
    }
}

void LogModel::removeFile(const QString &path)
{
    int removedAt = fileModel_.remove(path);
    if (removedAt >= 0) {
        removeRowsFromModel(qHash(path));
    } else {
        qCCritical(lcLogViewer) << "Path not found";
    }
}

void LogModel::removeAllFiles()
{
    int count = fileModel_.count();
    for (int i = count - 1; i >= 0; i--) {
        removeFile(fileModel_.getFilePathAt(i));
    }
}

QString LogModel::getRotatedFilePath(const QString &path) const
{
    QFileInfo fi(path);
    uint indexOfRotation = fi.completeSuffix().remove(fi.suffix()).remove(".").toUInt();
    ++indexOfRotation;
    QString rotatedFilePath = fi.filePath().remove(fi.completeSuffix()) + QString::number(indexOfRotation) + "." + fi.suffix();
    return rotatedFilePath;
}

void LogModel::clear()
{
    beginResetModel();

    for (int i = 0; i < data_.size(); i++) {
        delete data_.at(i);
    }
    data_.clear();

    endResetModel();
    emit countChanged();
    updateTimestamps();
}

QDateTime LogModel::oldestTimestamp() const
{
    return oldestTimestamp_;
}

QDateTime LogModel::newestTimestamp() const
{
    return newestTimestamp_;
}

void LogModel::updateTimestamps() {

    setNewestTimestamp(QDateTime());
    setOldestTimestamp(QDateTime());

    const auto validTimestamp = [](const LogItem* item) {
        return item->timestamp.isNull() == false;
    };

    const auto firstLogItem = find_if(cbegin(data_), cend(data_), validTimestamp);
    if (firstLogItem != data_.cend()) {
        setOldestTimestamp((*firstLogItem)->timestamp);
    }

    const auto lastLogItem = find_if(crbegin(data_), crend(data_), validTimestamp);
    if (lastLogItem != data_.crend()) {
        setNewestTimestamp((*lastLogItem)->timestamp);
    }

    if (data_.isEmpty()) {
        followingInitialized_ = false;
    }
}

int LogModel::rowCount(const QModelIndex &) const
{
    return data_.size();
}

QVariant LogModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= data_.size()) {
        return QVariant();
    }
    LogItem* item = data_.at(row);

    switch (role) {
    case TimestampRole:
        return item->timestamp;
    case PidRole:
        return item->pid;
    case TidRole:
        return item->tid;
    case LevelRole:
        return item->level;
    case MessageRole:
        return item->message;
    case IsMarkedRole:
        return item->isMarked;
    }
    return QVariant();
}

QVariant LogModel::data(int row, const QByteArray &role) const
{
    int enumRole = roleByNameHash_.value(role, -1);
    return data(this->index(row), enumRole);
}

QHash<int, QByteArray> LogModel::roleNames() const
{
    return roleByEnumHash_;
}

void LogModel::setModelRoles()
{
    roleByEnumHash_.clear();
    roleByEnumHash_.insert(TimestampRole, "timestamp");
    roleByEnumHash_.insert(PidRole, "pid");
    roleByEnumHash_.insert(TidRole, "tid");
    roleByEnumHash_.insert(LevelRole, "level");
    roleByEnumHash_.insert(MessageRole, "message");
    roleByEnumHash_.insert(IsMarkedRole, "isMarked");

    QHash<int, QByteArray>::const_iterator i = roleByEnumHash_.constBegin();
    while (i != roleByEnumHash_.constEnd()) {
        roleByNameHash_.insert(i.value(), i.key());
        ++i;
    }
}

int LogModel::count() const
{
    return data_.size();
}

LogItem* LogModel::parseLine(const QByteArray &line, FileModel::FileMetadata &metadata)
{
    LogItem* item = new LogItem;
    QList<QByteArray> splitIt = line.split('\t');

    if (splitIt.size() >= 5) {
        metadata.lastTimestamp = QDateTime::fromString(splitIt.takeFirst(), Qt::DateFormat::ISODateWithMs);

        metadata.lastPid = splitIt.takeFirst().mid(4);  // remove "PID:" prefix

        metadata.lastTid = splitIt.takeFirst().mid(4);  // remove "TID:" prefix

        QByteArray level = splitIt.takeFirst();
        if ((level.size() == 3) && (level[0] == '[') && (level[2] == ']')) {
            switch (level[1]) {
            case 'D':
                metadata.lastLogLevel = LogLevel::Value::LevelDebug;
                break;
            case 'I':
                metadata.lastLogLevel = LogLevel::Value::LevelInfo;
                break;
            case 'W':
                metadata.lastLogLevel = LogLevel::Value::LevelWarning;
                break;
            case 'E':
                metadata.lastLogLevel = LogLevel::Value::LevelError;
                break;
            }
        }

        item->message = splitIt.join('\t');
    } else {
        item->message = line;
    }

    item->timestamp = metadata.lastTimestamp;
    item->pid = metadata.lastPid;
    item->tid = metadata.lastTid;
    item->level = metadata.lastLogLevel;

    return item;
}

void LogModel::removeRowsFromModel(const uint pathHash)
{
    QList<LogItem*>::iterator chunkStart, chunkEnd;
    QList<LogItem*>::iterator it = data_.begin();
    bool chunkForRemoveBegan = false;
    bool gotChunk = false;

    while (it != data_.end()) {

        LogItem* item = *it;

        if (item->filehash == pathHash) {
            if (chunkForRemoveBegan == false) {
                chunkForRemoveBegan = true;
                chunkStart = it;
            }
        } else {
            if (chunkForRemoveBegan) {
                chunkForRemoveBegan = false;
                gotChunk = true;
                chunkEnd = it;
            }
        }

        if (gotChunk) {
            it = removeChunk(chunkStart, chunkEnd);
            gotChunk = false;
        }
        ++it;
    }

    if (chunkForRemoveBegan) {
        removeChunk(chunkStart, data_.end());
    }

    emit countChanged();
    updateTimestamps();
}

QList<LogItem*>::iterator LogModel::removeChunk(const QList<LogItem*>::iterator &chunkStart, const QList<LogItem*>::iterator &chunkEnd)
{
    int first = chunkStart - data_.begin();
    int last = chunkEnd - data_.begin() - 1;

    beginRemoveRows(QModelIndex(), first, last);
    for (auto it = chunkStart; it != chunkEnd; ++it) {
        delete *it;
    }
    QList<LogItem*>::iterator it = data_.erase(chunkStart, chunkEnd);
    endRemoveRows();
    return it;
}

void LogModel::checkFile()
{
    for (int i = 0; i < fileModel_.count(); i++) {
        const QString filePath = fileModel_.getFilePathAt(i);
        const qint64 lastPosition = fileModel_.getLastPositionAt(i);
        QFile file(filePath);

        if (file.size() != lastPosition) {
            if (file.size() < lastPosition) {
                const QString rotatedFilePath = getRotatedFilePath(filePath);
                QFile rotatedFile(rotatedFilePath);
                if (rotatedFile.exists()) {
                    qCDebug(lcLogViewer) << filePath << "has rotated into" << rotatedFilePath;
                    int rotatedIndex = fileModel_.append(rotatedFilePath);
                    fileModel_.copyFileMetadata(i, rotatedIndex);
                    populateModel(rotatedFilePath);
                }
                fileModel_.setLastPositionAt(i, 0);
            }
            populateModel(filePath);
        }
    }
}

void LogModel::setOldestTimestamp(const QDateTime &timestamp)
{
    if (oldestTimestamp_ != timestamp) {
        oldestTimestamp_ = timestamp;
        emit oldestTimestampChanged();
    }
}

void LogModel::setNewestTimestamp(const QDateTime &timestamp)
{
    if (newestTimestamp_ != timestamp) {
        newestTimestamp_ = timestamp;
        emit newestTimestampChanged();
    }
}

void LogModel::toggleIsMarked(int position)
{
    data_.at(position)->isMarked = !data_.at(position)->isMarked;
    emit dataChanged(index(position), index(position), QVector<int>() << IsMarkedRole);
}

FileModel *LogModel::fileModel()
{
    return &fileModel_;
}

void LogModel::handleQmlWarning(const QList<QQmlError> &warnings)
{
    QStringList msg;
    foreach (const QQmlError &error, warnings) {
        msg << error.toString();
    }
    emit notifyQmlError(msg.join(QStringLiteral("\n")));
}
