#pragma once

#include <QObject>
#include <QSocketNotifier>
#include <Connector.h>

namespace strata::strataComm {

class ServerConnector : public QObject {
    Q_OBJECT

public:
    ServerConnector(QString serverAddress, QObject *parent = nullptr) : QObject(parent), connector_(nullptr), serverAddress_(serverAddress){}
    ~ServerConnector();

    bool initilize();
    void readMessages();
    bool sendMessage(const QByteArray &clientId, const QByteArray &message);

signals:
    void newMessageRecived(const QByteArray &clientId, const QByteArray &message);

private slots:
    void readNewMessages(/*int socket*/);

private:
    std::unique_ptr<strata::connector::Connector> connector_;
    QSocketNotifier *readSocketNotifier_;
    QString serverAddress_;
};

}   // namespace strata::strataComm
