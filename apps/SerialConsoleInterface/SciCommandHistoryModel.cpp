/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SciCommandHistoryModel.h"
#include "logging/LoggingQtCategories.h"
#include "SciPlatform.h"
#include "SGJsonFormatter.h"

#include <QJsonDocument>

SciCommandHistoryModel::SciCommandHistoryModel(SciPlatform *platform)
    : QAbstractListModel(platform),
      platform_(platform)
{
}

SciCommandHistoryModel::~SciCommandHistoryModel()
{
}

QVariant SciCommandHistoryModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= commandList_.count()) {
        return QVariant();
    }

    const SciCommandHistoryModelItem &item = commandList_.at(row);

    switch (role) {
    case MessageRole:
        return item.message;
    case IsJsonValidRole:
        return item.isJsonValid;
    }

    return QVariant();
}

int SciCommandHistoryModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return commandList_.length();
}

int SciCommandHistoryModel::count() const
{
    return commandList_.length();
}

QVariantMap SciCommandHistoryModel::get(int row)
{
    if (row < 0 || row >= commandList_.count()) {
        return QVariantMap();
    }

    QVariantMap map;
    map["message"] = commandList_.at(row).message;
    map["isJsonValid"] = commandList_.at(row).isJsonValid;

    return map;
}

int SciCommandHistoryModel::maximumCount() const
{
    return maximumCount_;
}

void SciCommandHistoryModel::setMaximumCount(int maximumCount)
{
    if (maximumCount_ != maximumCount) {
        maximumCount_ = maximumCount;
        sanitize();
    }
}

void SciCommandHistoryModel::add(const QString &message)
{
    QString messageToStore = message;

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(message.toUtf8(), &parseError);
    bool isJsonValid = parseError.error == QJsonParseError::NoError;

    if (isJsonValid) {
        messageToStore = SGJsonFormatter::minifyJson(message);
    }

    int index = -1;
    for (int i = 0; i < commandList_.length(); ++i) {
        if (commandList_.at(i).message == messageToStore) {
            index = i;
            break;
        }
    }

    if (index < 0) {
        //append
        beginInsertRows(QModelIndex(), commandList_.length(), commandList_.length());

        SciCommandHistoryModelItem item;
        item.message = messageToStore;
        item.isJsonValid = isJsonValid;
        commandList_.append(item);

        endInsertRows();
        emit countChanged();

        sanitize();
    } else if (index == commandList_.length() - 1) {
        //already at the right position => do nothing
    } else {
        //move to the right position
        beginMoveRows(QModelIndex(), index, index, QModelIndex(), commandList_.length());
        commandList_.move(index, commandList_.length() - 1);
        endMoveRows();
    }
}

void SciCommandHistoryModel::populate(const QStringList &list)
{
    beginResetModel();
    commandList_.clear();

    for (const QString& message : list) {
        QJsonParseError parseError;
        QJsonDocument doc = QJsonDocument::fromJson(message.toUtf8(), &parseError);

        SciCommandHistoryModelItem item;
        item.message = message;
        item.isJsonValid = parseError.error == QJsonParseError::NoError;
        commandList_.append(item);
    }

    endResetModel();
    emit countChanged();
}

QStringList SciCommandHistoryModel::getCommandList() const
{
    QStringList list;
    for (const auto &item : commandList_) {
        list.append(item.message);
    }

    return list;
}

bool SciCommandHistoryModel::removeAt(int row)
{
    if (row < 0 || row >= commandList_.length()) {
        return false;
    }

    beginRemoveRows(QModelIndex(), row, row);
    commandList_.removeAt(row);
    endRemoveRows();

    platform_->storeCommandHistory(getCommandList());

    emit countChanged();

    return true;
}

QHash<int, QByteArray> SciCommandHistoryModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[MessageRole] = "message";
    roles[IsJsonValidRole] = "isJsonValid";

    return roles;
}

void SciCommandHistoryModel::sanitize()
{
    int removeCount = commandList_.length() - maximumCount_;

    if (removeCount > 0) {
        beginRemoveRows(QModelIndex(), 0, removeCount - 1);

        for (int i = 0; i < removeCount; ++i) {
            commandList_.removeFirst();
        }

        endRemoveRows();
        emit countChanged();
    }
}
