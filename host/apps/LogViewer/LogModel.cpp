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
    timer_ = new QTimer(this);
    connect (timer_, &QTimer::timeout, this, &LogModel::checkFile);
}

LogModel::~LogModel()
{
    clear(true);
    delete timer_;
}

QString LogModel::populateModel(const QString &path, const qint64 &lastPosition)
{
    QFile file(path);

    if (file.open(QIODevice::ReadOnly | QIODevice::Text) == false) {
        qCWarning(logCategoryLogViewer) << "cannot open " + path + " " + file.errorString();
        return file.errorString();
    }
    if (fileModel_.containsFilePath(path) == false) {
        fileModel_.append(path);
    }
    setNewestTimestamp(QDateTime());
    setOldestTimestamp(QDateTime());
    previousTimestamp_ = QDateTime();

    QTextStream stream(&file);
    stream.seek(lastPosition);

    while (stream.atEnd() == false) {
        LogItem item;
        parseLine(stream.readLine(), item);
        if (item.message.endsWith("\n")) {
            item.message.chop(1);
        }
        item.rowIndex = data_.length() + 1;

        QList<LogItem>::iterator up = std::upper_bound(data_.begin(), data_.end(), item);
        beginInsertRows(QModelIndex(), up - data_.begin(), up - data_.begin());

        data_.insert(up, item);
        endInsertRows();
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

QString LogModel::followFile(const QString &path)
{
    if (fileModel_.containsFilePath(path)) {
        qCWarning(logCategoryLogViewer) << "cannot open " + path + " " + "Already following";
        return "Already following file";
    } else {
        return populateModel(path, 0);
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

void LogModel::clear(bool emitSignals)
{
    if (emitSignals) {
        beginResetModel();
    }
    lastPositions_.clear();
    data_.clear();
    previousTimestamp_ = QDateTime();

    if(emitSignals) {
        endResetModel();
    }
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
    const auto validTimestamp = [](const LogItem item) {
        return item.timestamp.isNull() == false;
    };

    const auto firstLogItem = find_if(cbegin(data_), cend(data_), validTimestamp);
    if (firstLogItem != data_.cend()) {
        setOldestTimestamp((*firstLogItem).timestamp);
    }

    const auto lastLogItem = find_if(crbegin(data_), crend(data_), validTimestamp);
    if (lastLogItem != data_.crend()) {
        setNewestTimestamp((*lastLogItem).timestamp);
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
    LogItem item = data_.at(row);

    switch (role) {
    case TimestampRole:
        return item.timestamp;
    case PidRole:
        return item.pid;
    case TidRole:
        return item.tid;
    case LevelRole:
        return item.level;
    case MessageRole:
        return item.message;
    case RowIndexRole:
        return item.rowIndex;
    }
    return QVariant();
}

QHash<int, QByteArray> LogModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[TimestampRole] = "timestamp";
    names[PidRole] = "pid";
    names[TidRole] = "tid";
    names[LevelRole] = "level";
    names[MessageRole] = "message";
    names[RowIndexRole] = "rowIndex";
    return names;
}

int LogModel::count() const
{
    return data_.length();
}

void LogModel::parseLine(const QString &line, LogItem &item)
{
    QStringList splitIt = line.split('\t');

    if (splitIt.length() >= 5) {
        item.timestamp = QDateTime::fromString(splitIt.takeFirst(), Qt::DateFormat::ISODateWithMs);
        previousTimestamp_ = item.timestamp;
        item.pid = splitIt.takeFirst().replace("PID:","");
        item.tid = splitIt.takeFirst().replace("TID:","");
        QString level = splitIt.takeFirst();

        if (level == "[D]") {
            item.level = LevelDebug;
        } else if (level == "[I]") {
            item.level = LevelInfo;
        } else if (level == "[W]") {
            item.level = LevelWarning;
        } else if (level == "[E]") {
            item.level = LevelError;
        }
        item.message = splitIt.join('\t');
    } else {
        item.message = line;
    }

    if (line.isEmpty()) {
        item.timestamp = previousTimestamp_;
    }
    if (item.timestamp.isNull()) {
        item.timestamp = previousTimestamp_;
    }
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

FileModel *LogModel::fileModel()
{
    return &fileModel_;
}
