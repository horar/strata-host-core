#pragma once

#include <QAbstractListModel>

class SciPlatform;


struct SciCommandHistoryModelItem {
    QString message;
    bool isJsonValid;
};

class SciCommandHistoryModel: public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(SciCommandHistoryModel)

    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit SciCommandHistoryModel(SciPlatform *platform);
    virtual ~SciCommandHistoryModel() override;

    enum ModelRole {
        MessageRole = Qt::UserRole,
        IsJsonValidRole,
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
    Q_INVOKABLE bool removeAt(int row);

signals:
    void countChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private:
    QList<SciCommandHistoryModelItem> commandList_;
    int maximumCount_;
    SciPlatform *platform_;

    void sanitize();
};
