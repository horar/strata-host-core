/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SciMessageQueueModel.h"
#include "logging/LoggingQtCategories.h"
#include <SGJsonFormatter.h>
#include <QJsonDocument>
#include <QJsonObject>

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
    case ExpandedMessageRole:
        return item.expandedMessage;
    case IsJsonValidRole:
        return item.isJsonValid;
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

SciMessageQueueModel::ErrorCode SciMessageQueueModel::append(const QByteArray &message)
{
    if (data_.length() >= queueSizeLimit_ - 1) {
        return ErrorCode::ErrorQueueSizeLimitExceeded;
    }

    QueueItem item;
    item.rawMessage = message;

    QJsonParseError parseError;
    QJsonDocument::fromJson(message, &parseError);
    item.isJsonValid = parseError.error == QJsonParseError::NoError;

    if (item.isJsonValid) {
        item.expandedMessage = SGJsonFormatter::prettifyJson(message, true);
    } else {
        //store invalid json message as is
        item.expandedMessage = message;
    }

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

void SciMessageQueueModel::remove(int index)
{
    if (index < 0 || index > data_.length() - 1) {
        return;
    }

    beginRemoveRows(QModelIndex(), index, index);
    data_.removeAt(index);
    endRemoveRows();

    emit countChanged();
}

void SciMessageQueueModel::incrementPosition(int index)
{
    if (index < 0 || index > data_.length() - 2) {
        return;
    }

    bool isMovable = beginMoveRows(QModelIndex(), index, index, QModelIndex(), index + 2);
    if (isMovable == false) {
        qCCritical(lcSci) << "index not movable" << index;
        return;
    }

    data_.move(index, index + 1);
    endMoveRows();
}

void SciMessageQueueModel::decrementPosition(int index)
{
    if (index < 1 || index > data_.length() - 1) {
        return;
    }

    bool isMovable = beginMoveRows(QModelIndex(), index, index, QModelIndex(), index - 1);
    if (isMovable == false) {
        qCCritical(lcSci) << "index not movable" << index;
        return;
    }

    data_.move(index, index - 1);
    endMoveRows();
}

QHash<int, QByteArray> SciMessageQueueModel::roleNames() const
{
    return roleByEnumHash_;
}

void SciMessageQueueModel::setModelRoles()
{
    roleByEnumHash_.clear();
    roleByEnumHash_.insert(RawMessageRole, "rawMessage");
    roleByEnumHash_.insert(ExpandedMessageRole, "expandedMessage");
    roleByEnumHash_.insert(IsJsonValidRole, "isJsonValid");
}
