/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SciMockResponseModel.h"
#include "logging/LoggingQtCategories.h"

using namespace strata::device;

SciMockResponseModel::SciMockResponseModel(QObject *parent)
    : QAbstractListModel(parent)
{
    setModelRoles();
}

SciMockResponseModel::~SciMockResponseModel()
{
    clear();
}

void SciMockResponseModel::clear()
{
    beginResetModel();

    responses_.clear();

    endResetModel();
    emit countChanged();
}

QVariantMap SciMockResponseModel::get(int row)
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

int SciMockResponseModel::find(const QVariant& type) const
{
    MockResponse response = type.value<MockResponse>();
    int count = 0;
    for (auto iter = responses_.constBegin(); iter != responses_.constEnd(); ++iter) {
        if (iter->type_ == response) {
            return count;
        }
        ++count;
    }
    return -1;
}

QVariant SciMockResponseModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= responses_.count()) {
        qCWarning(lcSci) << "Attempting to access out of range index when acquiring data";
        return QVariant();
    }

    switch (role) {
    case Qt::DisplayRole:
    case NameRole:
        return responses_.at(row).name_;
    case TypeRole:
        return QVariant::fromValue(responses_.at(row).type_);
    }

    return QVariant();
}

QVariant SciMockResponseModel::data(int row, const QByteArray &role) const
{
    int enumRole = roleByNameHash_.value(role, -1);
    return data(this->index(row), enumRole);
}

int SciMockResponseModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return responses_.length();
}

int SciMockResponseModel::count() const
{
    return responses_.length();
}

QHash<int, QByteArray> SciMockResponseModel::roleNames() const
{
    return roleByEnumHash_;
}

void SciMockResponseModel::setModelRoles()
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

void SciMockResponseModel::updateModelData(const MockVersion& version, const MockCommand& command)
{
    beginResetModel();

    responses_.clear();
    QList<MockResponse> responses = mockSupportedResponses(version, command);
    foreach(auto response, responses) {
        responses_.push_back({response, mockResponseConvertEnumToString(response)});
    }

    endResetModel();
    emit countChanged();
}
