/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "Notification.h"

#include <QDebug>
#include <QUuid>

Notification::Notification(
        const Request &data,
        const NotificationActionList &list,
        QObject *parent)
    : QObject(parent),
      level_(data.level),
      title_(data.title),
      description_(data.description),
      removeAutomatically_(data.removeAutomatically),
      actionModel_(new NotificationActionModel(list, this))
{
    dateTime_ = QDateTime::currentDateTime();
    uuid_ = QUuid::createUuid().toString(QUuid::WithoutBraces);
}

Notification::NotificationLevel Notification::level() const {
    return level_;
};

QString Notification::title() const {
    return title_;
};

QString Notification::description() const {
    return description_;
};

QDateTime Notification::dateTime() const {
    return dateTime_;
};

QString Notification::uuid() const
{
    return uuid_;
};
bool Notification::removeAutomatically() const {
    return removeAutomatically_;
};

bool Notification::unique() const {
    return unique_;
};

NotificationActionModel* Notification::actionModel() const {
    return actionModel_;
};
