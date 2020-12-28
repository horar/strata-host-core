#pragma once

#include <Connector.h>
#include <QObject>
#include <QSocketNotifier>

namespace strata::connector
{
class Connector;
}

namespace strata::strataComm
{
class ClientConnector : public QObject
{
    Q_OBJECT

public:
    ClientConnector(QString serverAddress, QByteArray dealerId = "StrataClient",
                    QObject *parent = nullptr)
        : QObject(parent), serverAddress_(serverAddress), dealerId_(dealerId)
    {
    }
    ~ClientConnector();

    bool initilize();
    bool disconnectClient();
    bool connectClient();
    void readMessages();
    bool sendMessage(const QByteArray &message);

signals:
    void newMessageRecived(const QByteArray &message);

private slots:
    void readNewMessages(/*int socket*/);

private:
    std::unique_ptr<strata::connector::Connector> connector_;
    std::unique_ptr<QSocketNotifier> readSocketNotifier_;
    QString serverAddress_;
    QByteArray dealerId_;
};

}  // namespace strata::strataComm
