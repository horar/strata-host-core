#include "client.h"

client::client(QObject *parent) : QObject(parent)
{
    udpSocket_ = new QUdpSocket(this);
    tcpSever_ = new QTcpServer(this);
    tcpSever_->listen(QHostAddress::Any, TCP_PORT);

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

void client::readTcpMessage()
{
    recivedBuffer_ += "Host: " + (QString(clientConnection_->readAll())) + "\n";
    emit tcpMessageUpdated();
}

QString client::getTcpMessage() const
{
    return recivedBuffer_;
}

void client::broadcastDatagram()
{
    qDebug() << "broadcasting at port:" << port_;
    QByteArray datageam = "strata client";
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
    connect(clientConnection_, &QAbstractSocket::disconnected, clientConnection_, &QObject::deleteLater);

    connect(clientConnection_, &QTcpSocket::readyRead, this, &client::readTcpMessage);


    connect(clientConnection_, &QTcpSocket::disconnected, this, [this]() {
        qDebug() << "Host close connection";
        setConnectionStatus(status_[0]);;
        emit connectionStatusChanged();
    });

}

void client::disconnect()
{
    clientConnection_->disconnectFromHost();
    setConnectionStatus(status_[0]);
    emit connectionStatusChanged();
}

void client::tcpWrite(QByteArray block)
{
    clientConnection_->write(block);
    recivedBuffer_ += "Client: " + QString(block) + "\n";
    emit tcpMessageUpdated();
}
