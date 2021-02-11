#ifndef CLIENT_H
#define CLIENT_H

#include <QObject>
#include <QUdpSocket>
#include <QTcpServer>
#include <QAbstractSocket>
#include <QTcpSocket>

constexpr qint16 TCP_PORT(24125);

class client : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString connectionStatus READ getConnectionStatus WRITE setConnectionStatus NOTIFY connectionStatusChanged)
    Q_PROPERTY(QString receivedMessages READ getTcpMessage NOTIFY tcpMessageUpdated)

public:
    client(QObject *parent = nullptr);
    ~client();
    QString getConnectionStatus() const;
    void setConnectionStatus(QString &status);
    void readTcpMessage();
    QString getTcpMessage() const;


public slots:
   void broadcastDatagram();
   void setPort(quint16 port);
   quint16 getPort() const;
   void gotTcpConnection();
   void disconnect();
   void tcpWrite(QByteArray block);

signals:
    void connectionStatusChanged();
    void tcpMessageUpdated();

private:
    QString status_[2] = {"Disconnected", "Connected"};
    QUdpSocket *udpSocket_ = nullptr;
    QTcpServer *tcpSever_ = nullptr;
    quint16 port_ = 5146;
    QString tcpConnectionStatus_ = status_[0];
    QTcpSocket *clientConnection_ = nullptr;
    QString recivedBuffer_;
};

#endif // CLIENT_H
