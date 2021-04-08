#ifndef SGMQTTCLIENT_H
#define SGMQTTCLIENT_H

#include <QtMqtt/qmqttclient.h>
#include <QtMqtt/qmqttsubscription.h>
#include "SGSslConfiguration.h"

class QmlMqttClient;

class QmlMqttSubscription : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QMqttTopicFilter topic MEMBER topic_ NOTIFY topicChanged)
public:
    QmlMqttSubscription(QMqttSubscription *subscription, QmlMqttClient *client);
    ~QmlMqttSubscription();

public slots:
    void handleMessage(const QMqttMessage &qmessage);

signals:
    void topicChanged(const QString &topic);
    void messageReceived(const QString &message);

private:
    Q_DISABLE_COPY(QmlMqttSubscription)
    QMqttSubscription *subscription_;
    QmlMqttClient *client_;
    QMqttTopicFilter topic_;
};

class QmlMqttClient : public QMqttClient
{
    Q_OBJECT
    Q_PROPERTY(QmlSslConfiguration* sslConfiguration MEMBER qmlSslConfiguration_)

public:
    QmlMqttClient(QObject *parent = nullptr);
    Q_INVOKABLE int publish(const QString &topic, const QString &message, quint8 qos = 0, bool retain = false);
    Q_INVOKABLE QmlMqttSubscription *subscribe(const QString &topic);
    Q_INVOKABLE void connectToHostSsl();
private:
    Q_DISABLE_COPY(QmlMqttClient)
    QmlSslConfiguration *qmlSslConfiguration_;
};

#endif // SGMQTTCLIENT_H
