#include "server.h"
#include <QList>
#include <QNetworkInterface>
#include <QStringList>

Server::Server(QObject *parent)
    : QObject(parent),
      udpSocket_(new QUdpSocket(this))
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
    QHash<quint16, QTcpSocket *>::const_iterator i;
    for(i = tcpSockets_.constBegin(); i != tcpSockets_.constEnd(); i++) {
        qDebug() << i.key() << ':' << i.value();
        delete i.value();
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
    if(availableClients_.size() < 1) {
        return false;
    }
    return true;
}

void Server::connectToStrataClient(QHostAddress clientAddress, qint16 port)
{
    QTcpSocket * tcpSocket = tcpSocketSetup();

    qDebug() << "tcp: connecting to:" << clientAddress.toString() << "port:" << port;
    tcpSocket->connectToHost(clientAddress, port);

    if (false == tcpSocket->waitForConnected(5000)) {
        qDebug() << "tcp: failed to connect." << tcpSocket->error();
        return;
    }

    sendTcpMessge("Strata Host!", clientNumber_);
}

void Server::sendTcpMessge(QByteArray message, quint16 clientNumber)
{
    tcpBuffer_ += "Host: " + message + '\n';
    emit tcpBufferUpdated();
    tcpSockets_[clientNumber]->write(message);
}

void Server::disconnectTcpSocket(quint16 clientNumber)
{
    qDebug() << "tcp: Disconnecting socket client number: " << clientNumber;

    if (tcpSockets_[clientNumber]->state() != QTcpSocket::ConnectedState) {
        qDebug() << "tcp: socket not connected.";
        return;
    }

    tcpSockets_[clientNumber]->disconnectFromHost();
}

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


QList<QVariant> Server::getAvailableClients() const
{
    return availableClients_;
}

QString Server::getClientAddress(QVariant index)
{
    return clientsAddresses_[index.toUInt()];
}

QTcpSocket * Server::tcpSocketSetup()
{
    QTcpSocket *tcpSocket = new QTcpSocket();
    tcpSockets_[++clientNumber_] = tcpSocket;
    quint16 currentClient = clientNumber_;

    connect(tcpSocket, &QTcpSocket::connected, this, [this, tcpSocket, currentClient]() {
        qDebug() << "tcp: socket connected" << currentClient << ':' << tcpSockets_[currentClient];
        clientsAddresses_[currentClient] = tcpSocket->peerAddress().toString();
        availableClients_.append(currentClient);
        emit connectionStatusUpdated();
        emit availableClientsUpdated();
    });

    connect(tcpSocket, &QTcpSocket::disconnected, this, [this,currentClient]() {
        qDebug() << "tcp: socket disconnected" << currentClient << ':' << tcpSockets_[currentClient];
        clientsAddresses_.remove(currentClient);
        availableClients_.removeAll(currentClient);
        emit connectionStatusUpdated();
        emit availableClientsUpdated();
    });

    connect(tcpSocket, &QTcpSocket::bytesWritten, this,
        [](qint64 bytesWritten) { qDebug() << "tcp: bytes written" << bytesWritten; });

    connect(tcpSocket, &QTcpSocket::readyRead, this, [this, tcpSocket,currentClient]() {
        qDebug() << "tcp: New message received.";
        QByteArray data;
        data = tcpSocket->readAll();
        qDebug() << "tcp: message:" << QString(data) << tcpSocket << ':' << tcpSockets_[currentClient];;
        setTcpBuffer(data, currentClient);
    });

    qDebug() << "tcp: Client:" << clientNumber_ << "got address" << tcpSockets_[clientNumber_];

    return tcpSocket;
}

void Server::setUdpBuffer(const QByteArray &newDatagram)
{
    udpBuffer_ += newDatagram + '\n';
    emit udpBufferUpdated();
}

void Server::setTcpBuffer(const QByteArray &newData, quint16 clientNumber)
{
    tcpBuffer_ += "Client "+ QString::number(clientNumber) + ": " + newData + '\n';
    emit tcpBufferUpdated();
}
