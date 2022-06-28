/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#include "SciPlatformTestMessageModel.h"

SciPlatformTestMessageModel::SciPlatformTestMessageModel(QObject *parent)
    : QAbstractListModel(parent)
{ }

SciPlatformTestMessageModel::~SciPlatformTestMessageModel()
{ }

QVariant SciPlatformTestMessageModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= data_.count()) {
        return QVariant();
    }

    TestMessageItem item = data_.at(row);

    switch (role) {
    case Qt::DisplayRole:
    case TextRole:
        return item.text;
    case TypeRole:
        return item.type;
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

void SciPlatformTestMessageModel::changeLastMessage(MessageType type, QString text)
{
    if (data_.isEmpty()) {
        addMessage(type, text);
        return;
    }

    data_.last().type = type;
    data_.last().text = text;

    int row = data_.length() - 1;
    emit dataChanged(createIndex(row, 0), createIndex(row, 0), {TypeRole, TextRole});
}

QHash<int, QByteArray> SciPlatformTestMessageModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[TypeRole] = "type";
    roles[TextRole] = "text";

    return roles;
}
