#include <QFile>
#include <QDebug>
#include "logfilesmodel.h"

LogModel::LogModel(QObject *parent)
    : skipLines_(0)
{
}

LogModel::~LogModel()
{
    data_.clear();
}

bool LogModel::populateModel(const QString &path)
{
    QFile file(path);

    if (file.open(QIODevice::ReadOnly | QIODevice::Text) == (false)) {
        qDebug() << "#### Cannot open file! ####";
        return false;
    }
    beginResetModel();
    clear();
    int lineNum = 0;
    int lineSkip = 0;

    while (!file.atEnd()) {
        lineNum++;
        QByteArray line = file.readLine();
        LogItem *item = parseLine(line);

        if (item == nullptr) {
            lineSkip ++;
            qDebug() << "#### Line [" << lineNum << "] has the wrong format, need to skip" << lineSkip << "lines. ####";
        }
        else {
            data_.append(item);
        }
    }
    emit countChanged();
    endResetModel();
    setSkipLines(lineSkip);
    return true;
}

void LogModel::clear()
{
    beginResetModel();
    for (int i = 0; i< data_.length(); i++) {
        delete data_[i];
    }
    data_.clear();
    endResetModel();
}

int LogModel::rowCount(const QModelIndex &parent) const
{
    return data_.length();
}

QVariant LogModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if(row < 0 || row >= data_.count()) {
        return QVariant();
    }

    LogItem *item = data_.at(row);

    if (LogItem *item = nullptr) {
        return QVariant();
    }

    switch (role) {
    case TimestampRole:
        return item->timestamp.toString("yyyy-MM-dd HH:mm:ss.zzz");
    case PidRole:
        return item->pid;
    case TidRole:
        return item->tid;
    case TypeRole:
        return item->type;
    case MessageRole:
        return item->message;
    }
    return QVariant();
}

QHash<int, QByteArray> LogModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[TimestampRole] = "timestamp";
    names[PidRole] = "pid";
    names[TidRole] = "tid";
    names[TypeRole] = "type";
    names[MessageRole] = "message";
    return names;
}

int LogModel::count()
{
    return data_.length();
}

int LogModel::skipLines()
{
    return skipLines_;
}

LogItem *LogModel::parseLine(const QString &line)
{
    QStringList splitIt = line.split('\t');

    if (splitIt.length() >= 5) {
        QString timestamp = splitIt.takeFirst().trimmed();
        QString pid = splitIt.takeFirst().trimmed();
        QString tid = splitIt.takeFirst().trimmed();
        QString type = splitIt.takeFirst().trimmed();
        QString message = splitIt.join('\t').trimmed();

        LogItem*item = new LogItem;

        item->timestamp = QDateTime::fromString(timestamp, Qt::DateFormat::ISODateWithMs);
        item->pid = pid;
        item->tid = tid;
        item->type = type;
        item->message = message;

        return item;
    }
    else {
        return nullptr;
    }
}

void LogModel::setSkipLines(int skipLines)
{
    if (skipLines_ != skipLines) {
        skipLines_ = skipLines;
        emit skipLinesChanged();
    }
}
