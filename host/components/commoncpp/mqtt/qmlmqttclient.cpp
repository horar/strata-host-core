#include "qmlmqttclient.h"

QmlMqttClient::QmlMqttClient(QObject *parent)
    : QMqttClient(parent)
{
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

void QmlMqttSubscription::handleMessage(const QMqttMessage &qmsg)
{
    emit messageReceived(qmsg.payload());
}

void QmlMqttClient::connectToHostEncrypted()
{
    QMqttClient::connectToHostEncrypted(qmlSslConfiguration_->getQsslConfObject());
}