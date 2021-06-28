#pragma once

#include <QAbstractListModel>
#include <Mock/MockDeviceConstants.h>

class SciMockCommandModel : public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(SciMockCommandModel)

    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit SciMockCommandModel(QObject *parent = nullptr);
    virtual ~SciMockCommandModel() override;

    Q_INVOKABLE QVariantMap get(int row);
    Q_INVOKABLE int find(const QVariant& type) const;
    Q_INVOKABLE QVariant data(int row, const QByteArray &role) const;

    enum ModelRole {
        TypeRole = Qt::UserRole + 1,
        NameRole
    };

    struct CommandData {
        strata::device::MockCommand type_;
        QString name_;
    };

    void updateModelData(const strata::device::MockVersion& version);
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int count() const;

signals:
    void countChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private:
    void clear();
    void setModelRoles();

    QHash<int, QByteArray> roleByEnumHash_;
    QHash<QByteArray, int> roleByNameHash_;
    QList<CommandData> commands_;
};
