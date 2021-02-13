#ifndef CLIENT_H
#define CLIENT_H

#include <QObject>
#include <QUdpSocket>
#include <QTcpServer>
#include <QAbstractSocket>
#include <QTcpSocket>

constexpr qint16 TCP_PORT(24125);

class Client : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isConnected READ getConnectionStatus NOTIFY connectionStatusUpdated)
    Q_PROPERTY(QString receivedMessages READ getTcpMessage NOTIFY tcpMessageUpdated)
    Q_PROPERTY(QString log READ getLog NOTIFY logUpdated)


public:
    Client(QObject *parent = nullptr);
    ~Client();
    bool getConnectionStatus() const;
    void readTcpMessage();
    QString getTcpMessage() const;
    QString getLog() const;
    void setLog(QString logMsg);
    void startTcpServer();


public slots:
   void broadcastDatagram();
   void setPort(quint16 port);
   quint16 getPort() const;
   void gotTcpConnection();
   void disconnect();
   void tcpWrite(QByteArray block);

signals:
    void connectionStatusUpdated();
    void tcpMessageUpdated();
    void logUpdated();

private:
    QUdpSocket *udpSocket_ = nullptr;
    QTcpServer *tcpSever_ = nullptr;
    QTcpSocket *tcpSocket_ = nullptr;
    quint16 port_ = 5146;
    QString receivedMsgsBuffer;
    QString logsBuffer_;
};

#endif // CLIENT_H
