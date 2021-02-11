#include "server.h"
#include <QList>
#include <QNetworkInterface>
#include <QStringList>

Server::Server(QObject *parent)
    : QObject(parent),
      tcpSocket_(new QTcpSocket(this)),
      udpSocket_(new QUdpSocket(this)),
      connectionStatus_(ConnectionStatus::Disconnected),
      clientAddress_("")
{
    // UDP Socket set up.
    if (false == udpSocket_->bind(port_, QUdpSocket::ShareAddress | QUdpSocket::ReuseAddressHint)) {
        qDebug() << "udp: failed to bind to port" << port_;
    }
    qDebug() << "udp: successful bind to port" << port_;

    connect(udpSocket_, &QUdpSocket::readyRead, this, &Server::preccessPendingDatagrams);

    // TCP socket set up
    connect(tcpSocket_, &QTcpSocket::connected, this, [this]() {
        qDebug() << "tcp: socket connected";
        connectionStatus_ = ConnectionStatus::Connected;
        clientAddress_ = tcpSocket_->peerAddress().toString();
        emit connectionStatusUpdated();
        emit clientAddressUpdated();
    });

    connect(tcpSocket_, &QTcpSocket::disconnected, this, [this]() {
        qDebug() << "tcp: socket disconnected";
        connectionStatus_ = ConnectionStatus::Disconnected;
        clientAddress_ = "";
        emit connectionStatusUpdated();
        emit clientAddressUpdated();
    });

    //     connect(tcpSocket_, &QAbstractSocket::error, this, [](QAbstractSocket::SocketError
    //     socketError) {
    //         qDebug() << "tcp socket error!";
    //         qDebug() << socketError;
    //     });

    connect(tcpSocket_, &QTcpSocket::bytesWritten, this,
            [](qint64 bytesWritten) { qDebug() << "tcp: bytes written" << bytesWritten; });

    connect(tcpSocket_, &QTcpSocket::readyRead, this, &Server::newTcpMessage);
    qDebug() << "host Addresses:" << getHostAddress();
}

Server::~Server()
{
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
    QHostAddress hostAddress;
    while (udpSocket_->hasPendingDatagrams()) {
        datagram.resize(int(udpSocket_->pendingDatagramSize()));
        udpSocket_->readDatagram(datagram.data(), datagram.size(), &hostAddress);
        qDebug() << "host address:" << hostAddress.toString() << "datagram:" << datagram;
    }
    setUdpBuffer(datagram);

    if (datagram == "strata client") {
        connectToStrataClient(hostAddress, TCP_PORT);
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
    return connectionStatus_ == Server::ConnectionStatus::Connected;
}

void Server::connectToStrataClient(QHostAddress hostAddress, qint16 port)
{
    if (tcpSocket_->state() == QTcpSocket::ConnectedState) {
        qDebug() << "tcp: socket already connected";
        return;
    }

    qDebug() << "tcp: connecting to:" << hostAddress.toString() << "port:" << port;
    tcpSocket_->connectToHost(hostAddress, port);

    if (false == tcpSocket_->waitForConnected(5000)) {
        qDebug() << "tcp: failed to connect.";
    }

    sendTcpMessge("Strata Host!");
}

void Server::newTcpMessage()
{
    qDebug() << "tcp: New message received.";
    QByteArray data;
    data = tcpSocket_->readAll();
    qDebug() << "tcp: message:" << QString(data);
    setTcpBuffer(data);
}

void Server::sendTcpMessge(QByteArray message)
{
    tcpSocket_->write(message);
}

void Server::disconnectTcpSocket()
{
    qDebug() << "tcp: Disconnecting socket...";

    if (tcpSocket_->state() != QTcpSocket::ConnectedState) {
        qDebug() << "tcp: socket not connected.";
        return;
    }

    tcpSocket_->disconnectFromHost();
}

QString Server::getHostAddress()
{
    QList<QString> hostAddressesList;
    const QHostAddress &localhost = QHostAddress(QHostAddress::LocalHost);
    for (const QHostAddress &address : QNetworkInterface::allAddresses()) {
        if (address.protocol() == QAbstractSocket::IPv4Protocol && address != localhost) {
            hostAddressesList.push_back(address.toString());
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

void Server::setUdpBuffer(const QByteArray &newDatagram)
{
    udpBuffer_ += newDatagram + '\n';
    emit udpBufferUpdated();
}

void Server::setTcpBuffer(const QByteArray &newData)
{
    tcpBuffer_ += newData + '\n';
    emit tcpBufferUpdated();
}
