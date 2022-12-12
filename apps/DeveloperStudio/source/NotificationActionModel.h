/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QAbstractListModel>

class NotificationActionModel: public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(NotificationActionModel)

public:
    enum ModelRole {
        IdRole = Qt::UserRole + 1,
        TextRole,
    };

    struct ActionItem {
        QString id;
        QString text;
    };

    NotificationActionModel(
            QVector<ActionItem> list,
            QObject *parent = nullptr);

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private:
    QVector<ActionItem> data_;
};

typedef NotificationActionModel::ActionItem NotificationActionItem;
typedef QVector<NotificationActionItem> NotificationActionList;
