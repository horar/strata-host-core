#ifndef SERVER_H
#define SERVER_H

#include <QObject>
#include <QTcpSocket>
#include <QUdpSocket>

constexpr qint16 TCP_PORT(24125);

class Server : public QObject
{
    Q_OBJECT
    Q_PROPERTY(quint16 port READ getPort WRITE setPort);
    Q_PROPERTY(QString udpBuffer READ getUdpBuffer NOTIFY udpBufferUpdated);
    Q_PROPERTY(QString tcpBuffer READ getTcpBuffer NOTIFY tcpBufferUpdated);
    Q_PROPERTY(bool isConnected READ getConnectionStatus NOTIFY connectionStatusUpdated);
    Q_PROPERTY(QString hostAddress READ getHostAddress CONSTANT);
    Q_PROPERTY(QString tcpPort READ getTcpPort CONSTANT);
    Q_PROPERTY(QString clientAddreass READ getClientAddress NOTIFY clientAddressUpdated);

public:
    Server(QObject *parent = nullptr);
    ~Server();

    enum class ConnectionStatus { Connected, Disconnected };
    Q_ENUM(ConnectionStatus);

public slots:
    void setPort(quint16 port);
    quint16 getPort() const;
    void preccessPendingDatagrams();
    QString getUdpBuffer();
    QString getTcpBuffer();
    bool getConnectionStatus();
    void connectToStrataClient(QHostAddress hostAddress, qint16 port);
    void newTcpMessage();
    void sendTcpMessge(QByteArray message);
    void disconnectTcpSocket();
    QString getHostAddress();
    QString getTcpPort();
    QString getClientAddress();

signals:
    void udpBufferUpdated();
    void tcpBufferUpdated();
    void connectionStatusUpdated();
    void clientAddressUpdated();

private:
    void setUdpBuffer(const QByteArray &newDatagram);
    void setTcpBuffer(const QByteArray &newData);

    QTcpSocket *tcpSocket_ = nullptr;
    QUdpSocket *udpSocket_ = nullptr;
    quint16 port_ = 5146;
    QString udpBuffer_;
    QString tcpBuffer_;
    ConnectionStatus connectionStatus_;
    QString clientAddress_;
};

#endif  // SERVER_H
