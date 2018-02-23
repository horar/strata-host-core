#include <PlatformInterface/platforms/bubu/PlatformInterface.h>

using namespace PlatformInterfaceBuBu;


PlatformInterface::PlatformInterface(QObject *parent) : CoreInterface(parent)
{
    qDebug() << "PlatformInterface::PlatformInterface CTOR called";
}

PlatformInterface::~PlatformInterface()
{
    qDebug() << "PlatformInterface::~PlatformInterface DTOR called";
}
