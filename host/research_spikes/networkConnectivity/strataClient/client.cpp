#include "client.h"

client::client(QObject *parent) : QObject(parent)
{
    udpSocket_ = new QUdpSocket(this);
    tcpSever_ = new QTcpServer(this);
    tcpSever_->listen(QHostAddress::Any, port_);

    connect(tcpSever_, &QTcpServer::newConnection, this, &client::gotTcpConnection);
}

client::~client()
{
    tcpSever_->close();
}

QString client::getConnectionStatus() const
{
    return tcpConnectionStatus_;
}

void client::setConnectionStatus(QString &status)
{
    if (status != tcpConnectionStatus_) {
        tcpConnectionStatus_ = status;
        emit connectionStatusChanged();
    }
}

void client::broadcastDatagram()
{
    qDebug() << "broadcasting at port:" << port_;
    QByteArray datageam = "strata Client";
    udpSocket_->writeDatagram(datageam, QHostAddress::Broadcast, port_);
}

void client::setPort(quint16 port)
{
    if (port_ != port) {
        port_ = port;
    }
}

quint16 client::getPort() const
{
    return port_;
}

void client::gotTcpConnection()
{
    qDebug() << "TCP connection has been established";
    setConnectionStatus(status_[1]);

    // get tcp socket from server
    clientConnection_ = tcpSever_->nextPendingConnection();
    // ensure that the socket will be deleted after disconnecting
    connect(clientConnection_, &QAbstractSocket::disconnected,
            clientConnection_, &QObject::deleteLater);
}

void client::disconnect()
{
    clientConnection_->disconnectFromHost();
    setConnectionStatus(status_[0]);
}
