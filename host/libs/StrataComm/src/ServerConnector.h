#pragma once

#include <QObject>
#include <QSocketNotifier>
#include <Connector.h>

namespace strata::connector
{
class Connector;
}

namespace strata::strataComm {

class ServerConnector : public QObject {
    Q_OBJECT

public:
    ServerConnector(std::string serverAddress, QObject *parent = nullptr) : QObject(parent), serverAddress_(serverAddress){}
    ~ServerConnector();

    bool initilize();
    void readMessages();
    void sendMessage(const QByteArray &clientId, const QString &message);

signals:
    void newMessageRecived(const QByteArray &clientId, const QString &message);

private slots:
    void readNewMessages(int socket);

private:
    std::unique_ptr<strata::connector::Connector> connector_;
    QSocketNotifier *readSocketNotifier_;
    std::string serverAddress_;
};

}   // namespace strata::strataComm 
