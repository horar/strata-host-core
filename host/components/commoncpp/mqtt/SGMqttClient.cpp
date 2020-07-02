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
