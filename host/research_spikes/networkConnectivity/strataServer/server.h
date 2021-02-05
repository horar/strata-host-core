#ifndef SERVER_H
#define SERVER_H

#include <QObject>
#include <QUdpSocket>

class Server : public QObject
{
    Q_OBJECT
    Q_PROPERTY(quint16 port READ getPort WRITE setPort)

public:
    Server(QObject *parent = nullptr);
    ~Server();


public slots:
   void setPort(quint16 port);
   quint16 getPort() const;
   void preccessPendingDatagrams();

private:
    QUdpSocket *udpSocket_ = nullptr;
    quint16 port_ = 45454;
};

#endif // SERVER_H
