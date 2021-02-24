#include "server.h"
#include <QList>
#include <QNetworkInterface>
#include <QStringList>

Server::Server(QObject *parent)
    : QObject(parent),
      udpSocket_(new QUdpSocket(this)),
      clientAddress_("")
{
    // UDP Socket set up
    if (false == udpSocket_->bind(port_, QUdpSocket::ShareAddress | QUdpSocket::ReuseAddressHint)) {
        qDebug() << "udp: failed to bind to port" << port_;
    }
    qDebug() << "udp: successful bind to port" << port_;

    connect(udpSocket_, &QUdpSocket::readyRead, this, &Server::preccessPendingDatagrams);
}

Server::~Server()
{
    qDebug() << "Free up memory";
    QHash<QTcpSocket *, quint16>::const_iterator i;
    for(i = tcpSockets_.constBegin(); i != tcpSockets_.constEnd(); i++) {
        qDebug() << i.key() << ':' << i.value();
        delete i.key();
    }
}

void Server::setPort(quint16 port)
{
    if (port_ != port) {
        port_ = port;
        udpSocket_->close();
        if (false == udpSocket_->bind(port_, QUdpSocket::ShareAddress)) {
            qDebug() << "udp: failed to bind to port" << port_;
        }
        qDebug() << "udp: successful bind to port" << port_;
    }
}

quint16 Server::getPort() const
{
    return port_;
}

void Server::preccessPendingDatagrams()
{
    qDebug() << "datagram..";
    QByteArray datagram;
    QHostAddress clientAddress;
    while (udpSocket_->hasPendingDatagrams()) {
        datagram.resize(int(udpSocket_->pendingDatagramSize()));
        udpSocket_->readDatagram(datagram.data(), datagram.size(), &clientAddress);
        qDebug() << "Clint(sender)'s address:" << clientAddress.toString()  << "datagram:" << datagram;
    }
    setUdpBuffer(datagram);

    if (datagram == "strata client") {
        connectToStrataClient(clientAddress, TCP_PORT);
    }
}

QString Server::getUdpBuffer()
{
    return udpBuffer_;
}

QString Server::getTcpBuffer()
{
    return tcpBuffer_;
}

bool Server::getConnectionStatus()
{
    if(tcpSockets_.size() < 1) {
        return false;
    }
    return false; //tcpSocket_->state() == QTcpSocket::ConnectedState ? true : false;
}

void Server::connectToStrataClient(QHostAddress hostAddress, qint16 port)
{
    QTcpSocket * tcpSocket = tcpSocketSetup();
    if (tcpSocket->state() == QTcpSocket::ConnectedState) {
        qDebug() << "tcp: socket already connected";
        return;
    }

    qDebug() << "tcp: connecting to:" << hostAddress.toString() << "port:" << port;
    tcpSocket->connectToHost(hostAddress, port);

    if (false == tcpSocket->waitForConnected(5000)) {
        qDebug() << "tcp: failed to connect.";
    }

    sendTcpMessge("Strata Host!", tcpSocket);
}

void Server::sendTcpMessge(QByteArray message, QTcpSocket *tcpSocket)
{
    tcpBuffer_ += "Host: " + message + '\n';
    emit tcpBufferUpdated();
    tcpSocket->write(message);
}

//void Server::disconnectTcpSocket()
//{
//    qDebug() << "tcp: Disconnecting socket...";

//    if (tcpSocket_->state() != QTcpSocket::ConnectedState) {
//        qDebug() << "tcp: socket not connected.";
//        return;
//    }

//    tcpSocket_->disconnectFromHost();
//}

QString Server::getHostAddress()
{
    QList<QString> hostAddressesList;
    foreach(QNetworkInterface interface, QNetworkInterface::allInterfaces()) {
        if (interface.flags().testFlag(QNetworkInterface::IsUp) && !interface.flags().testFlag(QNetworkInterface::IsLoopBack)) {
            foreach (QNetworkAddressEntry entry, interface.addressEntries()) {
            if (interface.hardwareAddress() != "00:00:00:00:00:00" && entry.ip().toString().contains(".") && !interface.humanReadableName().contains("vnic"))
               hostAddressesList.push_back(entry.ip().toString());
            }
        }
    }
    return hostAddressesList.join(", ");
}

QString Server::getTcpPort()
{
    return QString::number(TCP_PORT);
}

QString Server::getClientAddress()
{
    return clientAddress_;
}

QTcpSocket * Server::tcpSocketSetup()
{
    QTcpSocket *tcpSocket = new QTcpSocket();
    tcpSockets_[tcpSocket] = ++clientNumber;

    connect(tcpSocket, &QTcpSocket::connected, this, [this, tcpSocket]() {
        qDebug() << "tcp: socket connected" << tcpSocket << ':' << tcpSockets_[tcpSocket];
        clientAddress_ = tcpSocket->peerAddress().toString();
        emit connectionStatusUpdated();
        emit clientAddressUpdated();
    });

    connect(tcpSocket, &QTcpSocket::disconnected, this, [this, tcpSocket]() {
        qDebug() << "tcp: socket disconnected" << tcpSocket << ':' << tcpSockets_[tcpSocket];
        clientAddress_ = "";
        emit connectionStatusUpdated();
        emit clientAddressUpdated();
        // freeing up socket here cause a crash
    });

    connect(tcpSocket, &QTcpSocket::bytesWritten, this,
            [](qint64 bytesWritten) { qDebug() << "tcp: bytes written" << bytesWritten; });

    connect(tcpSocket, &QTcpSocket::readyRead, this, [this, tcpSocket]() {
        qDebug() << "tcp: New message received.";
        QByteArray data;
        data = tcpSocket->readAll();
        qDebug() << "tcp: message:" << QString(data) << tcpSocket << ':' << tcpSockets_[tcpSocket];;
        setTcpBuffer(data, tcpSocket);
    });

    qDebug() << "tcp: Client:" << tcpSockets_[tcpSocket] << "got address" << tcpSocket;

    return tcpSocket;
}

void Server::setUdpBuffer(const QByteArray &newDatagram)
{
    udpBuffer_ += newDatagram + '\n';
    emit udpBufferUpdated();
}

void Server::setTcpBuffer(const QByteArray &newData, QTcpSocket *tcpSocket)
{
    tcpBuffer_ += "Client "+ QString::number(tcpSockets_[tcpSocket]) + ": " + newData + '\n';
    emit tcpBufferUpdated();
}
