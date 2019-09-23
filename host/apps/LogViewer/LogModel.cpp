#include "LogModel.h"

#include <QFile>
#include <QDebug>


LogModel::LogModel(QObject *parent)
    : numberOfSkippedLines_(0)
{
}

LogModel::~LogModel()
{
    data_.clear();
}

bool LogModel::populateModel(const QString &path)
{
    QFile file(path);

    if (file.open(QIODevice::ReadOnly | QIODevice::Text) == false) {
        qDebug() << "#### ERROR code 1 : QFile::ReadError : LogModel.cpp : Cannot open file! ####";
        return false;
    }
    beginResetModel();
    clear();
    int lineNum = 0;
    int skippedLine = 0;

    while (!file.atEnd()) {
        lineNum++;
        QByteArray line = file.readLine();
        LogItem *item = parseLine(line);

        if (item == nullptr) {
            skippedLine++;
            qDebug() << "#### Line [" << lineNum << "] has the wrong format, need to skip" << skippedLine << "lines. ####";
        }
        else {
            data_.append(item);
        }
    }
    emit countChanged();
    endResetModel();
    setNumberOfSkippedLines(skippedLine);
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

    if (item == nullptr) {
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

const int LogModel::count()
{
    return data_.length();
}

const int LogModel::numberOfSkippedLines()
{
    return numberOfSkippedLines_;
}

LogItem *LogModel::parseLine(const QString &line)
{
    QStringList splitIt = line.split('\t');

    if (splitIt.length() >= 5) {

        LogItem *item = new LogItem;

        item->timestamp = QDateTime::fromString(splitIt.takeFirst().trimmed(), Qt::DateFormat::ISODateWithMs);
        item->pid = splitIt.takeFirst().trimmed();
        item->tid = splitIt.takeFirst().trimmed();
        item->type = splitIt.takeFirst().trimmed();
        item->message = splitIt.join('\t').trimmed();

        return item;
    }
    return nullptr;
}

void LogModel::setNumberOfSkippedLines(int skippedLines)
{
    if (numberOfSkippedLines_ != skippedLines) {
        numberOfSkippedLines_ = skippedLines;
        emit numberOfSkippedLinesChanged();
    }
}
