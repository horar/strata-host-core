#pragma once

#include <QAbstractListModel>

class HexModel: public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(HexModel)

    Q_PROPERTY(QByteArray content READ content WRITE setContent NOTIFY contentChanged)

public:
    explicit HexModel(QObject *parent = nullptr);
    virtual ~HexModel() override;

    enum ModelRole {
        CharValueRole = Qt::UserRole,
        OctValueRole,
        DecValueRole,
        HexValueRole,
    };

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QByteArray content();
    void setContent(const QByteArray &content);

signals:
    void contentChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private:
    QByteArray content_;
};
