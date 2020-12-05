#include "DocumentListModel.h"

#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>
#include <QJsonObject>

DocumentListModel::DocumentListModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

DocumentListModel::~DocumentListModel()
{
    clear();
}

QVariant DocumentListModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= data_.count()) {
        return QVariant();
    }

    DocumentItem *item = data_.at(row);

    if (item == nullptr) {
        return QVariant();
    }

    switch (role) {
    case UriRole:
        return item->uri;
    case PrettyNameRole:
        return item->prettyName;
    case DirnameRole:
        return item->dirname;
    case PreviousDirnameRole:
        return data(DocumentListModel::index(row - 1, 0), DirnameRole);
    }

    return QVariant();
}

int DocumentListModel::count() const
{
    return data_.length();
}

int DocumentListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)

    return data_.length();
}

void DocumentListModel::populateModel(const QList<DocumentItem *> &list)
{
    beginResetModel();

    clear(false);
    data_.append(list);

    endResetModel();

    emit countChanged();
}

void DocumentListModel::clear(bool emitSignals)
{
    if (emitSignals) {
        beginResetModel();
    }

    for (int i = 0; i < data_.length(); i++) {
        delete data_[i];
    }
    data_.clear();

    if (emitSignals) {
        endResetModel();
        emit countChanged();
    }
}

QString DocumentListModel::getFirstUri()
{
    if (data_.length() == 0) {
        return QString();
    }

    return data_.at(0)->uri;
}

QString DocumentListModel::dirname(int index) {
    if (index < 0 || index >= data_.count()) {
        return QString();
    }

    return data_.at(index)->dirname;
}

QHash<int, QByteArray> DocumentListModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[UriRole] = "uri";
    names[PrettyNameRole] = "prettyName";
    names[DirnameRole] = "dirname";
    names[PreviousDirnameRole] = "previousDirname";

    return names;
}

QString DocumentListModel::getMD5()
{
    QJsonObject jsonObj;
    for (const auto &item : data_) {
        jsonObj.insert(item->prettyName, item->md5);
    }
    QJsonDocument doc(jsonObj);
    QString strJson(doc.toJson(QJsonDocument::Compact));
    return strJson;
}
