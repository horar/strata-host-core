#ifndef LOGMODEL_H
#define LOGMODEL_H

#include <QAbstractListModel>
#include <QDateTime>
#include <FileModel.h>


struct LogItem;
class QTimer;

class LogModel : public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(LogModel)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QDateTime oldestTimestamp READ oldestTimestamp NOTIFY oldestTimestampChanged)
    Q_PROPERTY(QDateTime newestTimestamp READ newestTimestamp NOTIFY newestTimestampChanged)
    Q_PROPERTY(FileModel* fileModel READ fileModel CONSTANT)

public:
    explicit LogModel(QObject *parent = nullptr);
    virtual ~LogModel() override;

    enum {
        TimestampRole = Qt::UserRole,
        PidRole,
        TidRole,
        LevelRole,
        MessageRole,
    };

    enum LogLevel {
        LevelUnknown,
        LevelDebug,
        LevelInfo,
        LevelWarning,
        LevelError
    };
    Q_ENUM(LogLevel)
    Q_INVOKABLE QString followFile(const QString &path);
    Q_INVOKABLE void removeFile(const QString &path);
    Q_INVOKABLE void clear();

    QString getRotatedFilePath(const QString &path) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QDateTime oldestTimestamp() const;
    QDateTime newestTimestamp() const;
    int count() const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    FileModel *fileModel();
    void removeRowsFromModel(const uint pathHash);
    void insertChunk(QList<LogItem*>::iterator chunkIter, QList<LogItem*> chunk);
    QList<LogItem*>::iterator removeChunk(const QList<LogItem*>::iterator &chunkStart, const QList<LogItem*>::iterator &chunkEnd);

public slots:
    void checkFile();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();
    void oldestTimestampChanged();
    void newestTimestampChanged();

private:
    bool followingInitialized_ = false;
    QTimer *timer_;
    QDateTime oldestTimestamp_;
    QDateTime newestTimestamp_;
    QDateTime previousTimestamp_;
    QList<LogItem*> data_;
    QVector<qint64> lastPositions_;
    LogItem* parseLine(const QString &line);
    QString populateModel(const QString &path, const qint64 &lastPosition);
    void updateTimestamps();
    FileModel fileModel_;
    void setOldestTimestamp(const QDateTime &timestamp);
    void setNewestTimestamp(const QDateTime &timestamp);
};

struct LogItem {

    LogItem()
        : level(LogModel::LogLevel::LevelUnknown)
    {
    }

    bool operator<(const LogItem& second) const {
        return (timestamp < second.timestamp);
    }

    static bool comparator(const LogItem* first, const LogItem* second) {
        return *first < *second;
    }

    QDateTime timestamp;
    QString pid;
    QString tid;
    QString message;
    LogModel::LogLevel level;
    uint filehash;
};

#endif
