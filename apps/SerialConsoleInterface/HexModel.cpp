#include "HexModel.h"
#include <QDebug>


HexModel::HexModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

HexModel::~HexModel()
{
}

QVariant HexModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= content_.count()) {
        return QVariant();
    }

    unsigned char c = content_.at(row);

    switch (role) {
    case CharValueRole:
        return c;
    case OctValueRole:
        return QByteArray::number(c, 8);
    case DecValueRole:
        return QByteArray::number(c, 10);
    case HexValueRole:
        return QByteArray::number(c, 16);
    }

    return QVariant();
}

int HexModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)

    return content_.length();
}

QByteArray HexModel::content()
{
    return content_;
}

void HexModel::setContent(const QByteArray &content)
{
    if (content_ == content) {
        return;
    }

    beginResetModel();

    content_ = content;

    endResetModel();
}

QHash<int, QByteArray> HexModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[CharValueRole] = "charValue";
    roles[OctValueRole] = "octValue";
    roles[DecValueRole] = "decValue";
    roles[HexValueRole] = "hexValue";

    return roles;
}
