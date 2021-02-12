#include "client.h"

client::client(QObject *parent) : QObject(parent)
{
    // No need to bind UDP socket for sending
    udpSocket_ = new QUdpSocket(this);

    tcpSever_ = new QTcpServer(this);

    // TCP server socket set up
    if (! tcpSever_->listen(QHostAddress::Any, TCP_PORT)) {
        setLog("Unable to start TCP server.\n" + tcpSever_->errorString());
        return;
    }
    setLog("TCP server has been started and listning at port: " + QString::number(TCP_PORT));
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
    receivedMsgsBuffer += "Host: " + (QString(tcpSocket_->readAll())) + "\n";
    emit tcpMessageUpdated();
}

QString client::getTcpMessage() const
{
    return receivedMsgsBuffer;
}

QString client::getLog() const
{
    return logsBuffer_;
}

void client::setLog(QString LogMsg)
{
   logsBuffer_ += "- " + LogMsg + "\n";
   emit logUpdated();
}

void client::broadcastDatagram()
{
    QByteArray datagram = "strata client";
    udpSocket_->writeDatagram(datagram, QHostAddress::Broadcast, port_);
    setLog("Sent Datagram: " + datagram + " at port: " + QString::number(port_));
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
    setConnectionStatus(status_[1]);

    // get tcp socket from server
    tcpSocket_ = tcpSever_->nextPendingConnection();

    setLog("Received and established a TCP connection from IP: "+ tcpSocket_->peerAddress().toString());


    // ensure that the socket will be deleted after disconnecting
    connect(tcpSocket_, &QAbstractSocket::disconnected, tcpSocket_, &QObject::deleteLater);

    connect(tcpSocket_, &QTcpSocket::readyRead, this, &client::readTcpMessage);

    connect(tcpSocket_, &QTcpSocket::disconnected, this, [this]() {
        setLog("TCP connection has been closed");
        setConnectionStatus(status_[0]);;
        emit connectionStatusChanged();
    });
}

void client::disconnect()
{
    tcpSocket_->disconnectFromHost();
}

void client::tcpWrite(QByteArray block)
{
    tcpSocket_->write(block);
    receivedMsgsBuffer += "Client: " + QString(block) + "\n";
    emit tcpMessageUpdated();
}
