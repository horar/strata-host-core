#ifndef SERVER_H
#define SERVER_H

#include <QObject>
#include <QTcpSocket>
#include <QUdpSocket>

constexpr qint16 TCP_PORT(24125);

class Server : public QObject
{
    Q_OBJECT
    Q_PROPERTY(quint16 port READ getPort WRITE setPort)
    Q_PROPERTY(QString buffer READ getBuffer NOTIFY bufferUpdated)

public:
    Server(QObject *parent = nullptr);
    ~Server();

public slots:
    void setPort(quint16 port);
    quint16 getPort() const;
    void preccessPendingDatagrams();
    QString getBuffer();
    void connectToStrataClient(QHostAddress hostAddress, qint16 port);
    void newTcpMessage();
    void sendTcpMessge();

signals:
    void bufferUpdated();

private:
    void setBuffer(const QByteArray &newDatagram);

    QTcpSocket *tcpSocket_ = nullptr;
    QUdpSocket *udpSocket_ = nullptr;
    quint16 port_ = 5146;
    QString buffer_;
};

#endif  // SERVER_H
