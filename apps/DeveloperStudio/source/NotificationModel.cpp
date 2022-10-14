/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "NotificationModel.h"
#include "logging/LoggingQtCategories.h"

NotificationModel::NotificationModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

QVariant NotificationModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= data_.count()) {
        qCWarning(lcNotification) << "index out of range";
        return QVariant();
    }

    Notification *item = data_.at(row);
    switch (role) {
    case NotificationRole: return QVariant::fromValue(item);
    }

    return QVariant();
}

int NotificationModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return data_.length();
}

int NotificationModel::count() const
{
    return data_.length();
}

Notification *NotificationModel::create(
        QVariantMap params,
        QVariantList list)
{
    Notification::Request data;

    if (params.contains("level")) {
        data.level = static_cast<Notification::NotificationLevel>(params.value("level").toInt());
    }

    if (params.contains("title")) {
        data.title = params.value("title").toString();
    }

    if (params.contains("description")) {
        data.description = params.value("description").toString();
    }

    if (params.contains("removeAutomatically")) {
        data.removeAutomatically = params.value("removeAutomatically").toBool();
    }

    if (params.contains("unique")) {
        data.unique = params.value("unique").toBool();
    }

    NotificationActionList actionList;
    for (auto &action : list) {
        NotificationActionItem actionData;
        actionData.id = action.toMap().value("id").toString();
        actionData.text = action.toMap().value("text").toString();

        actionList.append(actionData);
    };

    return create(data, actionList);
}

Notification *NotificationModel::create(
        const Notification::Request &data,
        const NotificationActionList &list)
{
    if (data.unique) {

        if (isUnique(data.title) == false) {
            qCInfo(lcNotification) << "notification is not unique and cannot be created:" << data.title;
            return nullptr;
        }
    }

    Notification *notification = new Notification(data, list, this);
    if (notification == nullptr) {
        return nullptr;
    }

    qCInfo(lcNotification) << "create notificaiton" << notification->title() << notification->uuid();

    if (notification->removeAutomatically()) {
        QString uuid = notification->uuid();
        QTimer::singleShot(removeTimeout_, this, [this, uuid](){
            this->remove(uuid);
        });
    }

    beginInsertRows(QModelIndex(), data_.length(), data_.length());
    data_.append(notification);
    endInsertRows();

    emit countChanged();

    return notification;
}

void NotificationModel::remove(const QString &uuid)
{
    int index = find(uuid);
    if (index < 0) {
        //nothing to remove
        return;
    }

    beginRemoveRows(QModelIndex(), index, index);

    Notification *notification = data_.at(index);
    qCInfo(lcNotification) << "remove notification" << notification->title() << notification->uuid();
    data_.remove(index);
    delete notification;

    endRemoveRows();

    emit countChanged();
}

void NotificationModel::removeAll()
{
    qCInfo(lcNotification) << "remove all notifications";

    beginRemoveRows(QModelIndex(), 0, data_.length());

    qDeleteAll(data_);
    data_.clear();

    endRemoveRows();

    emit countChanged();
}

Notification *NotificationModel::get(int row) const
{
    if (row < 0 || row >= data_.count()) {
        qCWarning(lcNotification) << "index out of range";
        return nullptr;
    }

    return data_.at(row);
}

QHash<int, QByteArray> NotificationModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[NotificationRole] = "notification";

    return names;
}

int NotificationModel::find(const QString &uuid)
{
    for (int i = 0; i < data_.length(); ++i) {
        if (data_.at(i)->uuid() == uuid) {
            return i;
        }
    }

    return -1;
}

bool NotificationModel::isUnique(const QString &title)
{
    for (const auto &notification : qAsConst(data_)) {
        if (notification->title() == title) {
            return false;
        }
    }

    return true;
}
