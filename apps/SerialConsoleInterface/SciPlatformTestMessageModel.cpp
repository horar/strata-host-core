#include "SciPlatformTestMessageModel.h"


SciPlatformTestMessageModel::SciPlatformTestMessageModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

SciPlatformTestMessageModel::~SciPlatformTestMessageModel()
{

}

QVariant SciPlatformTestMessageModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= data_.count()) {
        return QVariant();
    }

    TestMessageItem item = data_.at(row);

    switch (role) {
    case Qt::DisplayRole:
    case TextRole: return item.text;
    case TypeRole: return item.type;
    }

    return QVariant();
}

int SciPlatformTestMessageModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)

    return data_.size();
}

void SciPlatformTestMessageModel::clear()
{
    beginResetModel();

    data_.clear();

    endResetModel();
}

void SciPlatformTestMessageModel::addMessage(MessageType type, QString text)
{

    beginInsertRows(QModelIndex(), data_.length(), data_.length());

    data_.append(TestMessageItem{type, text});

    endInsertRows();

}

QHash<int, QByteArray> SciPlatformTestMessageModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[TextRole] = "text";
    roles[TypeRole] = "type";

    return roles;
}
