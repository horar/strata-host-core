#ifndef LOGMODEL_H
#define LOGMODEL_H

#include <QAbstractListModel>
#include <QDateTime>

struct LogItem {    
    QDateTime timestamp;
    QString pid;
    QString tid;
    QString level;
    QString message;
    uint rowIndex;
};

class LogModel : public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(LogModel)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

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

    Q_INVOKABLE QString populateModel(const QString &path);

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    void clear();
    int count() const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();

private:
    QList<LogItem*>data_;
    static LogItem* parseLine(const QString &line);
};
#endif
