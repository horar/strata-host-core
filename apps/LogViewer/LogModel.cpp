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
    delete timer_;
}

QString LogModel::populateModel(const QString &path, const qint64 &lastPosition)
{
    QFile file(path);

    if (file.open(QIODevice::ReadOnly | QIODevice::Text) == false) {
        qCWarning(logCategoryLogViewer) << "cannot open file with path " + path + " " + file.errorString();
        return file.errorString();
    }
    if (fileModel_.containsFilePath(path) == false) {
        fileModel_.append(path);
    }

    QTextStream stream(&file);
    stream.seek(lastPosition);

    QList<LogItem*> chunk;
    bool chunkReady = false;

    QList<LogItem*>::iterator up = data_.begin();
    QList<LogItem*>::iterator chunkIter = up;

    while (stream.atEnd() == false) {

        LogItem *item = parseLine(stream.readLine());
        item->filehash = qHash(path);

        up = std::upper_bound(data_.begin(), data_.end(), item, LogItem::comparator);

        if (up != chunkIter) {
            chunkReady = true;
        }

        if (chunkReady) {
            if (chunk.isEmpty() == false) {
                insertChunk(chunkIter, chunk);
            }
            chunk.clear();
            chunkReady = false;
            up = std::upper_bound(data_.begin(), data_.end(), item, LogItem::comparator);
            chunkIter = up;
        }
        chunk.append(item);
    }

    if (chunk.isEmpty() == false) {
        insertChunk(chunkIter, chunk);
    }

    if (lastPositions_.length() < fileModel_.count()) {
        lastPositions_.append(stream.pos());
    }
    if (followingInitialized_ == false) {
        timer_->start(std::chrono::milliseconds(500));
        followingInitialized_ = true;
    }

    emit countChanged();
    updateTimestamps();
    return "";
}

void LogModel::insertChunk(QList<LogItem*>::iterator chunkIter, QList<LogItem*> chunk)
{
    int position = chunkIter - data_.begin();

    beginInsertRows(QModelIndex(), position, position + chunk.length() - 1);
    for (int i = 0; i < chunk.length(); ++i) {
        data_.insert(position + i, chunk.at(i));
    }
    endInsertRows();
}

QString LogModel::followFile(const QString &path)
{
    if (fileModel_.containsFilePath(path)) {
        qCWarning(logCategoryLogViewer) << "cannot open file with path " + path + " " + "file is already opened";
        return "file is already opened";
    } else {
        return populateModel(path, 0);
    }
}

void LogModel::removeFile(const QString &path)
{
    int removedAt = fileModel_.remove(path);
    if (removedAt >= 0) {
        lastPositions_.removeAt(removedAt);
        removeRowsFromModel(qHash(path));
    } else {
        qCCritical(logCategoryLogViewer) << "path not found";
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

    for (int i = 0; i < data_.length(); i++) {
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
    previousTimestamp_ = QDateTime();

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
    return data_.length();
}

QVariant LogModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= data_.count()) {
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
    return data_.length();
}

LogItem* LogModel::parseLine(const QString &line)
{
    LogItem* item = new LogItem;
    QStringList splitIt = line.split('\t');

    if (splitIt.length() >= 5) {
        item->timestamp = QDateTime::fromString(splitIt.takeFirst(), Qt::DateFormat::ISODateWithMs);
        previousTimestamp_ = item->timestamp;
        item->pid = splitIt.takeFirst().replace("PID:","");
        previousPid_ = item->pid;
        item->tid = splitIt.takeFirst().replace("TID:","");
        previousTid_ = item->tid;
        QString level = splitIt.takeFirst();

        if (level == "[D]") {
            item->level = LevelDebug;
        } else if (level == "[I]") {
            item->level = LevelInfo;
        } else if (level == "[W]") {
            item->level = LevelWarning;
        } else if (level == "[E]") {
            item->level = LevelError;
        }
        previousLevel_ = item->level;
        item->message = splitIt.join('\t');
    } else {
        item->message = line;
    }

    if (item->timestamp.isNull()) {
        item->timestamp = previousTimestamp_;
    }
    if (item->pid.isNull()) {
        item->pid = previousPid_;
    }
    if (item->tid.isNull()) {
        item->tid = previousTid_;
    }
    if (item->level == LogLevel::LevelUnknown) {
        item->level = previousLevel_;
    }

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
        QFile file(filePath);

        if (file.size() != lastPositions_[i]) {
            if (file.size() < lastPositions_[i]) {
                QFile rotatedFile(getRotatedFilePath(filePath));
                if (rotatedFile.exists()) {
                    qCDebug(logCategoryLogViewer) << filePath << "has rotated into" << getRotatedFilePath(filePath) ;
                    populateModel(getRotatedFilePath(filePath), lastPositions_[i]);
                }
                populateModel(filePath, 0);
                lastPositions_[i] = file.size();
            }

            if (file.size() > lastPositions_[i]) {
                populateModel(filePath, lastPositions_[i]);
                lastPositions_[i] = file.size();
            }
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
