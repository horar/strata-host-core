#ifndef LOGMODEL_H
#define LOGMODEL_H

#include <QAbstractListModel>
#include <QDateTime>

/*forward declarations*/
struct LogItem;

class LogModel : public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(LogModel)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QDateTime oldestTimestamp READ oldestTimestamp NOTIFY oldestTimestampChanged)
    Q_PROPERTY(QDateTime newestTimestamp READ newestTimestamp NOTIFY newestTimestampChanged)

public:
    explicit LogModel(QObject *parent = nullptr);
    virtual ~LogModel() override;

    enum {
        TimestampRole = Qt::UserRole,
        PidRole,
        TidRole,
        LevelRole,
        MessageRole,
        RowIndexRole,
    };

    enum LogLevel {
        LevelUnknown,
        LevelDebug,
        LevelInfo,
        LevelWarning,
        LevelError
    };
    Q_ENUM(LogLevel)

    Q_INVOKABLE QString populateModel(const QString &path);

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    void clear();

    QDateTime oldestTimestamp() const;
    QDateTime newestTimestamp() const;

    int count() const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();
    void oldestTimestampChanged();
    void newestTimestampChanged();

private:
    QList<LogItem*>data_;

    static LogItem* parseLine(const QString &line);

    QDateTime oldestTimestamp_;
    QDateTime newestTimestamp_;

    void findOldestTimestamp();
    void findNewestTimestamp();

    void setOldestTimestamp(const QDateTime &timestamp);
    void setNewestTimestamp(const QDateTime &timestamp);
};

struct LogItem {

    LogItem()
        : level(LogModel::LogLevel::LevelUnknown)
    {
    }

    QDateTime timestamp;
    QString pid;
    QString tid;
    LogModel::LogLevel level;
    QString message;
    uint rowIndex;
};

#endif
