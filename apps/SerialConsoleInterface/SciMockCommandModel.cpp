/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SciMockCommandModel.h"
#include "logging/LoggingQtCategories.h"

using namespace strata::device;

SciMockCommandModel::SciMockCommandModel(QObject *parent)
    : QAbstractListModel(parent)
{
    setModelRoles();
}

SciMockCommandModel::~SciMockCommandModel()
{
    clear();
}

void SciMockCommandModel::clear()
{
    beginResetModel();

    commands_.clear();

    endResetModel();
    emit countChanged();
}

QVariantMap SciMockCommandModel::get(int row)
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

int SciMockCommandModel::find(const QVariant& type) const
{
    MockCommand command = type.value<MockCommand>();
    int count = 0;
    for (auto iter = commands_.constBegin(); iter != commands_.constEnd(); ++iter) {
        if (iter->type_ == command) {
            return count;
        }
        ++count;
    }
    return -1;
}

QVariant SciMockCommandModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= commands_.count()) {
        qCWarning(lcSci) << "Attempting to access out of range index when acquiring data";
        return QVariant();
    }

    switch (role) {
    case NameRole:
        return commands_.at(row).name_;
    case TypeRole:
        return QVariant::fromValue(commands_.at(row).type_);
    }

    return QVariant();
}

QVariant SciMockCommandModel::data(int row, const QByteArray &role) const
{
    int enumRole = roleByNameHash_.value(role, -1);
    return data(this->index(row), enumRole);
}

int SciMockCommandModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return commands_.length();
}

int SciMockCommandModel::count() const
{
    return commands_.length();
}

QHash<int, QByteArray> SciMockCommandModel::roleNames() const
{
    return roleByEnumHash_;
}

void SciMockCommandModel::setModelRoles()
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

void SciMockCommandModel::updateModelData(const MockVersion& version)
{
    beginResetModel();

    commands_.clear();
    QList<MockCommand> commands = mockSupportedCommands(version);
    foreach(auto command, commands) {
        commands_.push_back({command, mockCommandConvertEnumToString(command)});
    }

    endResetModel();
    emit countChanged();
}
