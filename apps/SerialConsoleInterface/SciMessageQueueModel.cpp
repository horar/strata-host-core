/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SciMessageQueueModel.h"

SciMessageQueueModel::SciMessageQueueModel(QObject *parent)
    : QAbstractListModel(parent)
{
    setModelRoles();
}

SciMessageQueueModel::~SciMessageQueueModel()
{
}

QVariant SciMessageQueueModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= data_.count()) {
        return QVariant();
    }

    const QueueItem &item = data_.at(row);

    switch (role) {
    case RawMessageRole:
        return item.rawMessage;
    }

    return QVariant();
}

int SciMessageQueueModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return data_.length();
}

int SciMessageQueueModel::count() const
{
    return data_.length();
}

QString SciMessageQueueModel::errorString(SciMessageQueueModel::ErrorCode code) const
{
    switch (code) {
    case ErrorCode::NoError:
        return "";
    case ErrorCode::ErrorQueueSizeLimitExceeded:
        return "queue size limit exceeded";
    default:
        return "unknown error";
    }
}

SciMessageQueueModel::ErrorCode SciMessageQueueModel::append(const QString &message)
{
    if (data_.length() >= queueSizeLimit_ - 1) {
        return ErrorCode::ErrorQueueSizeLimitExceeded;
    }

    QueueItem item;
    item.rawMessage = message;

    beginInsertRows(QModelIndex(), data_.length(), data_.length());
    data_.append(item);
    endInsertRows();

    emit countChanged();

    return ErrorCode::NoError;
}

QString SciMessageQueueModel::first()
{
    if (data_.isEmpty()) {
        return QString();
    }

    return data_.first().rawMessage;
}

void SciMessageQueueModel::removeFirst()
{
    if (data_.isEmpty()) {
        return;
    }

    beginRemoveRows(QModelIndex(), 0, 0);
    data_.removeFirst();
    endRemoveRows();

    emit countChanged();
}

bool SciMessageQueueModel::isEmpty()
{
    return data_.isEmpty();
}

QHash<int, QByteArray> SciMessageQueueModel::roleNames() const
{
    return roleByEnumHash_;
}

void SciMessageQueueModel::setModelRoles()
{
    roleByEnumHash_.clear();
    roleByEnumHash_.insert(RawMessageRole, "rawMessage");
}
