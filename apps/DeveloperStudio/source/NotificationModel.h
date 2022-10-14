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
#include <QDateTime>
#include <QTimer>
#include "Notification.h"

class NotificationModel: public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(NotificationModel)

    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum ModelRole {
        NotificationRole = Qt::UserRole + 1,
    };

    explicit NotificationModel(QObject *parent = nullptr);

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    int count() const;

    Q_INVOKABLE Notification* create(
            QVariantMap params,
            QVariantList list=QVariantList());

    Notification* create(
            const Notification::Request &data,
            const NotificationActionList &list);

    Q_INVOKABLE void remove(const QString &uuid);
    Q_INVOKABLE void removeAll();

    Q_INVOKABLE Notification* get(int row) const;

signals:
    void countChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private:
    int find(const QString &uuid);
    bool isUnique(const QString &title);

    QVector<Notification*> data_;
    static constexpr  std::chrono::milliseconds removeTimeout_ = std::chrono::seconds(6);
};
