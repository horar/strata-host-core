#include "LogModel.h"

#include <QFile>
#include <QDebug>


LogModel::LogModel(QObject *parent)
    : QAbstractListModel(parent),
      numberOfSkippedLines_()
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
        qWarning() << "cannot open file" << path << file.errorString();
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

        if (item->message.isEmpty() == true) {
            item = nullptr;
        }
        if (item == nullptr) {
            skippedLine++;
            qDebug() << "#### Line [" << lineNum << "] has empty message/s, need to skip" << skippedLine << "empty line/s. ####";
        }

        else {
            if (item->timestamp.isValid() == true) {
                data_.append(item);
            }
            if (item->timestamp.isValid() == false) {
                data_.last()->message += "\n" + item->message;
                delete item;
            }
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

int LogModel::rowCount(const QModelIndex &) const
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
    case LevelRole:
        return item->level;
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
    names[LevelRole] = "level";
    names[MessageRole] = "message";
    return names;
}

int LogModel::count() const
{
    return data_.length();
}

int LogModel::numberOfSkippedLines() const
{
    return numberOfSkippedLines_;
}

QString LogModel::longMsgJoin (const QStringList &input) {
    QString msg = input.join(" ").trimmed();
    return msg;
}

QStringList LogModel::longMsgListAppend (const QString &input) {

    QStringList appendMsg;
    appendMsg.append(input.trimmed());
    return appendMsg;
}


LogItem *LogModel::parseLine(const QString &line)
{
    QStringList splitIt = line.split('\t');
    LogItem *item = new LogItem;
    if (splitIt.length() >= 5) {

        item->timestamp = QDateTime::fromString(splitIt.takeFirst().trimmed(), Qt::DateFormat::ISODateWithMs);
        item->pid = splitIt.takeFirst().trimmed().replace("PID:","");
        item->tid = splitIt.takeFirst().trimmed().replace("TID:","");
        item->level = splitIt.takeFirst().trimmed();
        item->message = splitIt.join('\t').trimmed();

        return item;
    }
    item->message = longMsgJoin(splitIt);
    return item;

}

void LogModel::setNumberOfSkippedLines(int skippedLines)
{
    if (numberOfSkippedLines_ != skippedLines) {
        numberOfSkippedLines_ = skippedLines;
        emit numberOfSkippedLinesChanged();
    }
}
