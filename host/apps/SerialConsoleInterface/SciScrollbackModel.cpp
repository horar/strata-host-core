#include "SciScrollbackModel.h"
#include "logging/LoggingQtCategories.h"

SciScrollbackModel::SciScrollbackModel(QObject *parent)
    : QAbstractListModel(parent)
{
    setModelRoles();
}

SciScrollbackModel::~SciScrollbackModel()
{
}

QVariant SciScrollbackModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= data_.count()) {
        return QVariant();
    }

    const ScrollbackModelItem &item = data_.at(row);

    switch (role) {
    case MessageRole:
        return item.message;
    case TypeRole:
        return static_cast<int>(item.type);
    case TimestampRole:
        return item.timestamp;
    case CondensedRole:
        return item.condensed;
    }

    return QVariant();
}

QVariant SciScrollbackModel::data(int row, const QByteArray &role) const
{
    int enumRole = roleByNameHash_.value(role, -1);
    return data(this->index(row), enumRole);
}

int SciScrollbackModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return data_.length();
}

int SciScrollbackModel::count() const
{
    return data_.length();
}

void SciScrollbackModel::append(const QString &message, MessageType type)
{
    beginInsertRows(QModelIndex(), data_.length(), data_.length());

    ScrollbackModelItem item;
    item.message = message;
    item.type = type;
    item.timestamp = QDateTime::currentDateTime();
    item.condensed = condensedMode_;
    data_.append(item);

    endInsertRows();

    emit countChanged();

    sanitize();
}

void SciScrollbackModel::setAllCondensed(bool condensed)
{
    for (auto &item : data_) {
        item.condensed = condensed;
    }

    emit dataChanged(
                createIndex(0, 0),
                createIndex(data_.length() - 1, 0),
                QVector<int>() << CondensedRole);
}

void SciScrollbackModel::setCondensed(int index, bool condensed)
{
    if (index < 0 || index >= data_.count()) {
        qCWarning(logCategorySci) << "index out of range";
        return;
    }

    data_[index].condensed = condensed;

    emit dataChanged(
                createIndex(index, 0),
                createIndex(index, 0),
                QVector<int>() << CondensedRole);
}

void SciScrollbackModel::clear()
{
    beginResetModel();
    data_.clear();
    endResetModel();
    emit countChanged();
}

QString SciScrollbackModel::getTextForExport() const
{
    QString text;
    for (const auto &item : data_) {
        QString line = QString("%1 %2 %3")
                .arg(item.timestamp.toString(Qt::ISODate))
                .arg(item.type == MessageType::Request ? "request" : "response")
                .arg(item.message);

        text.append(line+"\n");
    }

    return text;
}

bool SciScrollbackModel::condensedMode() const
{
    return condensedMode_;
}

void SciScrollbackModel::setCondensedMode(bool condensedMode)
{
    if (condensedMode_ != condensedMode) {
        condensedMode_ = condensedMode;
        emit condensedModeChanged();
    }
}

int SciScrollbackModel::maximumCount() const
{
    return maximumCount_;
}

void SciScrollbackModel::setMaximumCount(int maximumCount)
{
    if (maximumCount_ != maximumCount) {
        maximumCount_ = maximumCount;
        sanitize();
    }
}

QHash<int, QByteArray> SciScrollbackModel::roleNames() const
{
    return roleByEnumHash_;
}

void SciScrollbackModel::setModelRoles()
{
    roleByEnumHash_.clear();
    roleByEnumHash_.insert(MessageRole, "message");
    roleByEnumHash_.insert(TypeRole, "type");
    roleByEnumHash_.insert(TimestampRole, "timestamp");
    roleByEnumHash_.insert(CondensedRole, "condensed");

    QHash<int, QByteArray>::const_iterator i = roleByEnumHash_.constBegin();
    while (i != roleByEnumHash_.constEnd()) {
        roleByNameHash_.insert(i.value(), i.key());
        ++i;
    }
}

void SciScrollbackModel::sanitize()
{
    int removeCount = data_.length() - maximumCount_;
    if (removeCount > 0) {
        beginRemoveRows(QModelIndex(), 0, removeCount - 1);

        for (int i = 0; i < removeCount; ++i) {
            data_.removeFirst();
        }

        endRemoveRows();
        emit countChanged();
    }
}
