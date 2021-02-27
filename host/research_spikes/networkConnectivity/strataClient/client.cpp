#include "client.h"
#include <QNetworkInterface>

Client::Client(QObject *parent)
    : QObject(parent),
      udpSocket_(new QUdpSocket(this)),
      tcpSever_(new QTcpServer(this))
{
    // No need to bind UDP socket for sending

    startTcpServer();
    connect(tcpSever_, &QTcpServer::newConnection, this, &Client::gotTcpConnection);
}

Client::~Client()
{
    delete udpSocket_;
    delete tcpSever_;
}

bool Client::getConnectionStatus() const
{
    return isConnected;
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

QString Client::getHostAddress()
{
    QList<QString> hostAddressesList;
    foreach(QNetworkInterface interface, QNetworkInterface::allInterfaces()) {
        if (interface.flags().testFlag(QNetworkInterface::IsUp) && !interface.flags().testFlag(QNetworkInterface::IsLoopBack)) {
            foreach (QNetworkAddressEntry entry, interface.addressEntries()) {
                if (interface.hardwareAddress() != "00:00:00:00:00:00" && entry.ip().toString().contains(".") &&
                     !interface.humanReadableName().contains("vnic") && !interface.humanReadableName().contains("utun")) {
                    hostAddressesList.push_back(entry.ip().toString());
                }
            }
        }
    }
    return hostAddressesList.join(", ");
}

QString Client::getTcpPort()
{
    return QString::number(TCP_PORT);
}

void Client::broadcastDatagram()
{
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
    isConnected = true;
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
        isConnected = false;
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
