#include "LogModel.h"
#include "logging/LoggingQtCategories.h"

#include <QFile>


LogModel::LogModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

LogModel::~LogModel()
{
    clear();
}

QString LogModel::populateModel(const QString &path)
{
    beginResetModel();
    clear();
    setNewestTimestamp(QDateTime());
    setOldestTimestamp(QDateTime());

    QFile file(path);
    uint rowIndex = 0;

    if (file.open(QIODevice::ReadOnly | QIODevice::Text) == false) {
        qCWarning(logCategoryLogViewer) << "cannot open " + path + " " + file.errorString();
        emit countChanged();
        endResetModel();
        return file.errorString();
    }

    while (file.atEnd() == false) {
        QByteArray line = file.readLine();
        LogItem *item = parseLine(line);
        if (item->message.endsWith("\n")) {
            item->message.chop(1);
        }
        data_.append(item);
        item->rowIndex = ++rowIndex;
    }

    emit countChanged();
    endResetModel();

    findOldestTimestamp();
    findNewestTimestamp();

    return "";
}

void LogModel::clear()
{
    beginResetModel();
    for (int i = 0; i < data_.length(); i++) {
        delete data_[i];
    }
    data_.clear();
    endResetModel();
}

QDateTime LogModel::oldestTimestamp() const
{
    return oldestTimestamp_;
}

QDateTime LogModel::newestTimestamp() const
{
    return newestTimestamp_;
}

void LogModel::findOldestTimestamp()
{
    for (int i = 0; i < data_.length(); i++) {
        if (data_[i]->timestamp.isNull() == false) {
            setOldestTimestamp(data_[i]->timestamp);
            break;
        }
    }
}

void LogModel::findNewestTimestamp()
{
    for (int i = data_.length()-1; i >= 0; i--) {
        if (data_[i]->timestamp.isNull() == false) {
            setNewestTimestamp(data_[i]->timestamp);
            break;
        }
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

    LogItem *item = data_.at(row);

    if (item == nullptr) {
        return QVariant();
    }

    switch (role) {
    case TimestampRole:
        return item->timestamp.toString("yyyy-MM-dd hh:mm:ss.zzz t");
    case PidRole:
        return item->pid;
    case TidRole:
        return item->tid;
    case LevelRole:
        return item->level;
    case MessageRole:
        return item->message;
    case RowIndexRole:
        return item->rowIndex;
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

LogItem *LogModel::parseLine(const QString &line)
{
    QStringList splitIt = line.split('\t');
    LogItem *item = new LogItem;
    if (splitIt.length() >= 5) {
        item->timestamp = QDateTime::fromString(splitIt.takeFirst(), Qt::DateFormat::ISODateWithMs);
        item->pid = splitIt.takeFirst().replace("PID:","");
        item->tid = splitIt.takeFirst().replace("TID:","");
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

        item->message = splitIt.join('\t');
        return item;
    }
    item->message = line;
    return item;
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
