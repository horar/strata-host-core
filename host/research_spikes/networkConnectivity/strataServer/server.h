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
    Q_PROPERTY(QList<QVariant> availableClients READ getAvailableClients NOTIFY availableClientsUpdated);

public:
    Server(QObject *parent = nullptr);
    ~Server();

public slots:
    void setPort(quint16 port);
    void preccessPendingDatagrams();
    bool getConnectionStatus();
    void connectToStrataClient(QHostAddress hostAddress, qint16 port);
    void sendTcpMessge(QByteArray message, quint16 clientNumber);
    void disconnectTcpSocket(quint16 clientNumber);
    quint16 getPort() const;
    QString getUdpBuffer();
    QString getTcpBuffer();
    QString getHostAddress();
    QString getTcpPort();
    QList<QVariant> getAvailableClients() const;
    QString getClientAddress(QVariant index);

signals:
    void udpBufferUpdated();
    void tcpBufferUpdated();
    void connectionStatusUpdated();
    void availableClientsUpdated();

private:
    void setUdpBuffer(const QByteArray &newDatagram);
    void setTcpBuffer(const QByteArray &newData, quint16 clientNumber);
    QTcpSocket * tcpSocketSetup();
    QUdpSocket *udpSocket_ = nullptr;
    QHash<quint16, QTcpSocket *> tcpSockets_;
    QHash<quint16, QString> clientsAddresses_;
    QList<QVariant> availableClients_;
    quint16 clientNumber_ = 0;
    quint16 port_ = 5146;
    QString udpBuffer_;
    QString tcpBuffer_;
};

#endif  // SERVER_H
