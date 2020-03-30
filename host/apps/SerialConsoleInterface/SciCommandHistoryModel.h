#ifndef SCI_COMMAND_HISTORY_MODEL_H
#define SCI_COMMAND_HISTORY_MODEL_H

#include <QAbstractListModel>

struct SciCommandHistoryModelItem {
    QString message;
};

class SciCommandHistoryModel: public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(SciCommandHistoryModel)

    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit SciCommandHistoryModel(QObject *parent = nullptr);
    virtual ~SciCommandHistoryModel() override;

    enum ModelRole {
        MessageRole = Qt::UserRole,
    };

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int count() const;

    Q_INVOKABLE QVariantMap get(int row);

    int maximumCount() const;
    void setMaximumCount(int maximumCount);

    void add(const QString &message);
    void populate(const QStringList &list);
    QStringList getCommandList() const;

signals:
    void countChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private:
    QList<SciCommandHistoryModelItem> commandList_;
    int maximumCount_;

    void sanitize();
};

#endif //SCI_COMMAND_HISTORY_MODEL_H
