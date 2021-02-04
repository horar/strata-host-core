#ifndef CLIENT_H
#define CLIENT_H

#include <QObject>
#include <QUdpSocket>

class client : public QObject
{
    Q_OBJECT
    Q_PROPERTY(quint16 port READ getPort WRITE setPort)

public:
    client(QObject *parent = nullptr);
    ~client();


public slots:
   void broadcastDatagram();
   void setPort(quint16 port);
   quint16 getPort() const;

private:
    QUdpSocket *udpSocket_ = nullptr;
    quint16 port_ = 0;
};

#endif // CLIENT_H
