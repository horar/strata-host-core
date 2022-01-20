/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SGMqttClient.h"

QmlMqttClient::QmlMqttClient(QObject *parent)
    : QMqttClient(parent)
{
    qmlSslConfiguration_ = nullptr;
}

int QmlMqttClient::publish(const QString &topic, const QString &message, quint8 qos, bool retain)
{
    auto result = QMqttClient::publish(QMqttTopicName(topic), message.toUtf8(), qos, retain);
    return result;
}

QmlMqttSubscription* QmlMqttClient::subscribe(const QString &topic)
{
    auto subscription = QMqttClient::subscribe(topic, 0);
    auto result = new QmlMqttSubscription(subscription, this);
    return result;
}

QmlMqttSubscription::QmlMqttSubscription(QMqttSubscription *subscription, QmlMqttClient *client)
    : subscription_(subscription)
    , client_(client)
{
    connect(subscription_, &QMqttSubscription::messageReceived, this, &QmlMqttSubscription::handleMessage);
    topic_ = subscription_->topic();
}

QmlMqttSubscription::~QmlMqttSubscription()
{
}

void QmlMqttSubscription::handleMessage(const QMqttMessage &message)
{
    emit messageReceived(message.payload());
}

void QmlMqttClient::connectToHostSsl()
{
    #if QT_VERSION_MAJOR == 5 && QT_VERSION_MINOR == 14
        connectToHostEncrypted(qmlSslConfiguration_->getQsslConfigurationObject());
    #else
        qWarning() << "Please use Qt 5.14 and above for encrypted connection";
    #endif
}
