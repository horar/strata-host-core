#include "client.h"

Client::Client(QObject *parent)
    : QObject(parent),
      udpSocket_(new QUdpSocket(this)),
      tcpSever_(new QTcpServer(this)),
      tcpSocket_(new QTcpSocket(this))
{
    // No need to bind UDP socket for sending

    startTcpServer();
    connect(tcpSever_, &QTcpServer::newConnection, this, &Client::gotTcpConnection);
}

Client::~Client()
{
}

bool Client::getConnectionStatus() const
{
    return tcpSocket_->state() == QTcpSocket::ConnectedState ? true : false;
}

void Client::readTcpMessage()
{
    receivedMsgsBuffer += "Host: " + (QString(tcpSocket_->readAll())) + "\n";
    emit tcpMessageUpdated();
}

QString Client::getTcpMessage() const
{
    return receivedMsgsBuffer;
}

QString Client::getLog() const
{
    return logsBuffer_;
}

void Client::setLog(QString logMsg)
{
   logsBuffer_ += "- " + logMsg + "\n";
   emit logUpdated();
}

void Client::startTcpServer()
{
    // TCP server socket set up
    if (! tcpSever_->listen(QHostAddress::Any, TCP_PORT)) {
        setLog("Unable to start TCP server.\n" + tcpSever_->errorString());
        return;
    }
    setLog("TCP server has been started and listning at port: " + QString::number(TCP_PORT));
}

void Client::broadcastDatagram()
{
    if (tcpSocket_->state() == QTcpSocket::ConnectedState) {
        qDebug() << "TCP socket already connected.";
        return;
    }
    QByteArray datagram = "strata client";
    udpSocket_->writeDatagram(datagram, QHostAddress::Broadcast, port_);
    setLog("Sent Datagram: " + datagram + " at port: " + QString::number(port_));
}

void Client::setPort(quint16 port)
{
    if (port_ != port) {
        port_ = port;
    }
}

quint16 Client::getPort() const
{
    return port_;
}

void Client::gotTcpConnection()
{
    // get tcp socket from server
    tcpSocket_ = tcpSever_->nextPendingConnection();
    emit connectionStatusUpdated();
    setLog("Received and established a TCP connection from IP: "+ tcpSocket_->peerAddress().toString());

    // close server from listening to incoming connection
    tcpSever_->close();
    setLog(tcpSever_->isListening() ? "TCP server is listening at port: " + QString::number(TCP_PORT) : "TCP server stoped listning at port: " + QString::number(TCP_PORT));


    // ensure that the socket will be deleted after disconnecting
    connect(tcpSocket_, &QAbstractSocket::disconnected, tcpSocket_, &QObject::deleteLater);

    connect(tcpSocket_, &QTcpSocket::readyRead, this, &Client::readTcpMessage);

    connect(tcpSocket_, &QTcpSocket::disconnected, this, [this]() {
        setLog("TCP connection has been closed");
        startTcpServer();
        emit connectionStatusUpdated();
    });
}

void Client::disconnect()
{
    if (tcpSocket_->state() != QTcpSocket::ConnectedState) {
        qDebug() << "TCP socket not connected.";
        return;
    }

    tcpSocket_->disconnectFromHost();
}

void Client::tcpWrite(QByteArray block)
{
    if (tcpSocket_->state() != QTcpSocket::ConnectedState) {
        qDebug() << "tcp: socket not connected.";
        return;
    }

    tcpSocket_->write(block);
    receivedMsgsBuffer += "Client: " + QString(block) + "\n";
    emit tcpMessageUpdated();
}
