#pragma once

#include <QObject>
#include <QSocketNotifier>
#include <Connector.h>

namespace strata::connector
{
class Connector;
}

namespace strata::strataComm {

class ClientConnector : public QObject {
    Q_OBJECT

public:
    ClientConnector(std::string serverAddress, std::string dealerId = "StrataClient", QObject *parent = nullptr) : QObject(parent), serverAddress_(serverAddress), dealerId_(dealerId) {}
    ~ClientConnector();

    bool initilize();
    void readMessages();
    void sendMessage(const QString &message);

signals:
    void newMessageRecived(const QString &message);

private slots:
    void readNewMessages(/*int socket*/);

private:
    std::unique_ptr<strata::connector::Connector> connector_;
    QSocketNotifier *readSocketNotifier_;
    std::string serverAddress_;
    std::string dealerId_;
};

}   // namespace strata::strataComm 
