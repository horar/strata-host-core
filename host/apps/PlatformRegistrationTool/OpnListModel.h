#pragma once

#include <QAbstractListModel>
#include <QPointer>
#include <QUrl>

class Deferred;
class RestClient;

struct OpnItem {
    QString opn;
    QString verboseName;
    QString classId;
    QUrl firmware;
    QString firmwareChecksum;
};

class OpnListModel: public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(OpnListModel)

    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    OpnListModel(RestClient *restClient, QObject *parent = nullptr);
    virtual ~OpnListModel() override;

    enum ModelRole {
        OpnRole = Qt::UserRole,
        VerboseNameRole,
        ClassIdRole,
    };

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    Q_INVOKABLE QVariant data(int row, QByteArray role);

    int count() const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    void clear();
    Q_INVOKABLE void populate();

signals:
    void countChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private:
    QHash<int, QByteArray> roleNames_;
    QPointer<RestClient> restClient_;
    QList<OpnItem*> data_;

    void populateOpnList(const QByteArray &data);
    OpnItem* createOpnItem(const QJsonObject &jsonObject);
};
