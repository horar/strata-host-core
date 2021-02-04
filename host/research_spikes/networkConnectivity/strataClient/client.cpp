#include "client.h"

client::client(QObject *)
{
    udpSocket_ = new QUdpSocket(this);
}

client::~client()
{

}

void client::broadcastDatagram()
{
    qDebug() << "Port:" << port_;
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
