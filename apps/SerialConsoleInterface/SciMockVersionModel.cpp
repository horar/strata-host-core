#include "SciMockVersionModel.h"
#include "logging/LoggingQtCategories.h"

using namespace strata::device;

SciMockVersionModel::SciMockVersionModel(QObject *parent)
    : QAbstractListModel(parent)
{
    setModelRoles();
    setModelData();
}

SciMockVersionModel::~SciMockVersionModel()
{
    clear();
}

void SciMockVersionModel::clear()
{
    beginResetModel();

    versions_.clear();

    endResetModel();
    emit countChanged();
}

QVariantMap SciMockVersionModel::get(int row)
{
    QHashIterator<int, QByteArray> iter(roleByEnumHash_);
    QVariantMap res;
    while (iter.hasNext()) {
        iter.next();
        QModelIndex idx = index(row, 0);
        QVariant data = idx.data(iter.key());
        res[iter.value()] = data;
    }
    return res;
}

int SciMockVersionModel::find(const QVariant& version) const
{
    MockVersion mockVersion = version.value<MockVersion>();
    int count = 0;
    for (auto iter = versions_.constBegin(); iter != versions_.constEnd(); ++iter) {
        if (iter->type_ == mockVersion) {
            return count;
        }
        ++count;
    }
    return -1;
}

QVariant SciMockVersionModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= versions_.count()) {
        qCWarning(logCategorySci) << "Attempting to access out of range index when acquiring data";
        return QVariant();
    }

    switch (role) {
    case NameRole:
        return versions_.at(row).name_;
    case TypeRole:
        return QVariant::fromValue(versions_.at(row).type_);
    }

    return QVariant();
}

QVariant SciMockVersionModel::data(int row, const QByteArray &role) const
{
    int enumRole = roleByNameHash_.value(role, -1);
    return data(this->index(row), enumRole);
}

int SciMockVersionModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return versions_.length();
}

int SciMockVersionModel::count() const
{
    return versions_.length();
}

QHash<int, QByteArray> SciMockVersionModel::roleNames() const
{
    return roleByEnumHash_;
}

void SciMockVersionModel::setModelRoles()
{
    roleByEnumHash_.clear();
    roleByEnumHash_.insert(TypeRole, "type");
    roleByEnumHash_.insert(NameRole, "name");

    QHash<int, QByteArray>::const_iterator i = roleByEnumHash_.constBegin();
    while (i != roleByEnumHash_.constEnd()) {
        roleByNameHash_.insert(i.value(), i.key());
        ++i;
    }
}

void SciMockVersionModel::setModelData()
{
    versions_.clear();
    QList<MockVersion> versions = mockSupportedVersions();
    foreach(auto version, versions) {
        versions_.push_back({version, mockVersionConvertEnumToString(version)});
    }
}
