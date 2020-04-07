#include "LogModel.h"
#include "logging/LoggingQtCategories.h"

#include <QFile>
#include <QFileInfo>
#include <QTimer>

using namespace std;


LogModel::LogModel(QObject *parent)
    : QAbstractListModel(parent)
{
    timer_ = new QTimer(this);
    connect (timer_, &QTimer::timeout,this, &LogModel::checkFile);
}

LogModel::~LogModel()
{
    clear(true);
    delete timer_;
}

QString LogModel::populateModel(const QString &path, bool logRotated)
{
    beginResetModel();
    clear(false);
    setNewestTimestamp(QDateTime());
    setOldestTimestamp(QDateTime());

    QFile file(path);

    if (logRotated == false) {
        filePath_ = path;
    }

    if (file.open(QIODevice::ReadOnly | QIODevice::Text) == false) {
        qCWarning(logCategoryLogViewer) << "cannot open " + path + " " + file.errorString();
        emit countChanged();
        endResetModel();
        return file.errorString();
    }

    QTextStream stream(&file);
    QString line;

    while (stream.atEnd() == false) {
        line = stream.readLine();
        LogItem *item = parseLine(line);
        if (item->message.endsWith("\n")) {
            item->message.chop(1);
        }
        item->rowIndex = data_.length() + 1;
        data_.append(item);
    }

    if (logRotated == false) {
        lastPos_ = stream.pos();
        timer_->start(std::chrono::milliseconds(500));
    }

    emit countChanged();
    endResetModel();

    updateTimestamps();

    return "";
}

QString LogModel::followFile(const QString &path)
{
    return populateModel(path,logRotated_);
}

void LogModel::updateModel(const QString &path)
{
    QFile file(path);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        QTextStream stream(&file);
        QString line;
        QStringList lines;

        if (logRotated_) {
            stream.seek(rotatedPos_);
        } else {
            stream.seek(lastPos_);
        }

        while (stream.atEnd() == false) {
            line = stream.readLine();
            lines.append(line);
        }

        if (logRotated_) {
            rotatedPos_ = stream.pos();
        } else {
            lastPos_ = stream.pos();
        }

        beginInsertRows(QModelIndex(),data_.length(),data_.length() + lines.size() - 1);

        for (int i = 0; i < lines.size(); i++) {
            LogItem *item = parseLine(lines[i]);
            item->rowIndex = data_.length() + 1;
            data_.append(item);
        }

        emit countChanged();
        endInsertRows();

        file.close();

        updateTimestamps();
    } else {
        qCWarning(logCategoryLogViewer) << "cannot open " + path + " " + file.errorString();
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

    qDeleteAll(data_);
    data_.clear();

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

void LogModel::checkFile()
{
    QFile file(filePath_);

    if (file.size() != lastPos_) {
        if (file.size() < lastPos_) {
            logRotated_ = true;
            rotatedPos_ = 0;

            QFile rotatedFile(getRotatedFilePath(filePath_));
            if (rotatedFile.exists()) {
                qCDebug(logCategoryLogViewer) << "file" << filePath_ << "has rotated";
                followFile(getRotatedFilePath(filePath_));
            }
        }
        updateModel(filePath_);
        lastPos_ = file.size();
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
