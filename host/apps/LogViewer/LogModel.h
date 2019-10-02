#ifndef LOGMODEL_H
#define LOGMODEL_H

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
    Q_PROPERTY(int numberOfSkippedLines READ numberOfSkippedLines NOTIFY numberOfSkippedLinesChanged)

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

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    void clear();
    void setNumberOfSkippedLines(int numberOfSkippedLines);
    int count() const;
    int numberOfSkippedLines() const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();
    void numberOfSkippedLinesChanged();

private:
    QList<LogItem*>data_;
    static LogItem* parseLine(const QString &line);
    int numberOfSkippedLines_;
};
#endif
