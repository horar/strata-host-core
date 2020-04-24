#ifndef QMLMQTTCLIENT_H
#define QMLMQTTCLIENT_H

#include <QtMqtt/QMqttClient>
#include <QtMqtt/QMqttSubscription>
#include "qmlsslconfiguration.h"

class QmlMqttClient;

class QmlMqttSubscription : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QMqttTopicFilter topic MEMBER m_topic NOTIFY topicChanged)
public:
    QmlMqttSubscription(QMqttSubscription *s, QmlMqttClient *c);
    ~QmlMqttSubscription();

Q_SIGNALS:
    void topicChanged(QString);
    void messageReceived(const QString &msg);

public slots:
    void handleMessage(const QMqttMessage &qmsg);

private:
    Q_DISABLE_COPY(QmlMqttSubscription)
    QMqttSubscription *sub;
    QmlMqttClient *client;
    QMqttTopicFilter m_topic;
};

class QmlMqttClient : public QMqttClient
{
    Q_OBJECT
    Q_PROPERTY(QmlSslConfiguration* sslConfiguration MEMBER m_qmlSslConf)

public:
    QmlMqttClient(QObject *parent = nullptr);
    Q_INVOKABLE int publish(const QString &topic, const QString &message, quint8 qos = 0, bool retain = false);
    Q_INVOKABLE QmlMqttSubscription *subscribe(const QString &topic);
    Q_INVOKABLE void connectToHostEncrypted();
private:
    Q_DISABLE_COPY(QmlMqttClient)
    QmlSslConfiguration *m_qmlSslConf;
};

#endif // QMLMQTTCLIENT_H
