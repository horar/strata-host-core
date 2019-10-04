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
};

class LogModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QString getErrorMsg READ getErrorMsg NOTIFY errorMsgChanged)
    Q_DISABLE_COPY(LogModel)

public:
    explicit LogModel(QObject *parent = nullptr);
    ~LogModel() override;

    enum {
        TimestampRole = Qt::UserRole,
        PidRole,
        TidRole,
        LevelRole,
        MessageRole,
    };

    Q_INVOKABLE bool populateModel(const QString &path);

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    void clear();
    QString getErrorMsg() const;
    int count() const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();
    void errorMsgChanged();

private:
    QList<LogItem*>data_;
    QString errorMsg;
    bool errorCount = false;
    static LogItem* parseLine(const QString &line);
};
#endif
