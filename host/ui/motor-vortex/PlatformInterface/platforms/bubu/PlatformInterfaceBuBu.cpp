#include <PlatformInterface/platforms/bubu/PlatformInterfaceBuBu.h>

using namespace PlatformInterfaceBuBu;

PlatformInterface::PlatformInterface(QObject *parent) : CoreInterface(parent)
{
    qDebug() << "PlatformInterfaceMotorBuBu::PlatformInterface::PlatformInterface CTOR called";
}

PlatformInterface::~PlatformInterface()
{
    qDebug() << "PlatformInterfaceMotorBuBu::PlatformInterface::~PlatformInterface DTOR called";
}
