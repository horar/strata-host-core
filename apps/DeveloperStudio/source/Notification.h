/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QDateTime>
#include <QTimer>

#include "NotificationActionModel.h"

class Notification : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(Notification)

    Q_PROPERTY(NotificationLevel level READ level CONSTANT)
    Q_PROPERTY(QString title READ title CONSTANT)
    Q_PROPERTY(QString description READ description CONSTANT)
    Q_PROPERTY(QDateTime dateTime READ dateTime CONSTANT)
    Q_PROPERTY(QString uuid READ uuid CONSTANT)
    Q_PROPERTY(bool removeAutomatically READ removeAutomatically CONSTANT)
    Q_PROPERTY(bool unique READ unique CONSTANT)
    Q_PROPERTY(NotificationActionModel* actionModel READ actionModel CONSTANT)

public:
    enum NotificationLevel {
        Info,
        Warning,
        Error,
    };
    Q_ENUM(NotificationLevel)

    struct Request {
        NotificationLevel level;
        QString title;
        QString description;
        bool removeAutomatically = true;
        bool unique = false;
    };

    Notification(
            const Request &data,
            const NotificationActionList &list,
            QObject *parent);

    NotificationLevel level() const;
    QString title() const;
    QString description() const;
    QDateTime dateTime() const;
    QString uuid() const;
    bool removeAutomatically() const;
    bool unique() const;
    NotificationActionModel *actionModel() const;

signals:
    void actionTriggered(QString actionId);

private:
    NotificationLevel level_ = NotificationLevel::Info;
    QString title_;
    QString description_;
    QDateTime dateTime_;
    QString uuid_;
    bool removeAutomatically_;
    bool unique_;
    NotificationActionModel *actionModel_{nullptr};
};
