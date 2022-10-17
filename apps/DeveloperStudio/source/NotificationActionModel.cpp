/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "NotificationActionModel.h"
#include "logging/LoggingQtCategories.h"

NotificationActionModel::NotificationActionModel(
        QVector<ActionItem> list,
        QObject *parent)
    : QAbstractListModel(parent)
{
    data_.append(list);
}

QVariant NotificationActionModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= data_.count()) {
        qCWarning(lcNotification) << "index out of range";
        return QVariant();
    }

    const ActionItem &item = data_.at(row);
    switch (role) {
    case IdRole: return item.id;
    case TextRole: return item.text;
    }

    return QVariant();
}

int NotificationActionModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return data_.length();
}

QHash<int, QByteArray> NotificationActionModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[IdRole] = "id";
    names[TextRole] = "text";
    return names;
}
