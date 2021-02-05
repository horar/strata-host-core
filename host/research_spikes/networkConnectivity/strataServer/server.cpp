#include "server.h"

Server::Server(QObject *)
{
    udpSocket_ = new QUdpSocket(this);
    if (false == udpSocket_->bind(port_, QUdpSocket::ShareAddress)) {
        qDebug() << "failed to bind to port" << port_;
    }
    qDebug() << "successful bind to port" << port_;

    connect(udpSocket_, &QUdpSocket::readyRead, this, &Server::preccessPendingDatagrams);
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
            qDebug() << "failed to bind to port" << port_;
        }
        qDebug() << "successful bind to port" << port_;
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
    while (udpSocket_->hasPendingDatagrams()) {
        datagram.resize(int(udpSocket_->pendingDatagramSize()));
        udpSocket_->readDatagram(datagram.data(), datagram.size());
        qDebug() << datagram;
    }
    setBuffer(datagram);
}

QString Server::getBuffer()
{
    return buffer_;
}

void Server::setBuffer(const QByteArray &newDatagram)
{
    buffer_ += newDatagram + '\n';
    emit bufferUpdated();
}
