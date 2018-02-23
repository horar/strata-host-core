#include <PlatformInterface/platforms/usb-pd/PlatformInterfaceUsbPd.h>

using namespace PlatformInterfaceUsbPd;


PlatformInterface::PlatformInterface(QObject *parent) : CoreInterface(parent)
{
    qDebug() << "PlatformInterfaceUsbPd::PlatformInterface::PlatformInterface CTOR called";
}

PlatformInterface::~PlatformInterface()
{
    qDebug() << "PlatformInterfaceUsbPd::PlatformInterface::~PlatformInterface DTOR called";
}
