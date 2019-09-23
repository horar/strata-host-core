#ifndef LOGFILESMODEL_H
#define LOGFILESMODEL_H

#include <QAbstractListModel>
#include <QDateTime>

struct LogItem {
    QDateTime timestamp;
    QString pid;
    QString tid;
    QString type;
    QString message;
};

class LogModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int skipLines READ skipLines NOTIFY skipLinesChanged)

public:
    explicit LogModel(QObject *parent = nullptr);
    ~LogModel() override;

    enum {
        TimestampRole = Qt::UserRole,
        PidRole,
        TidRole,
        TypeRole,
        MessageRole,
    };

    Q_INVOKABLE bool populateModel(const QString &path);

    void clear();
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int count();
    int skipLines();
    void setSkipLines(int skipLines);

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();
    void skipLinesChanged();

private:
    QList<LogItem*>data_;        //list of all the log files
    LogItem* parseLine(const QString &line);
    int skipLines_;
};
#endif
