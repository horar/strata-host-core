#include <Device.h>

#include "logging/LoggingQtCategories.h"

namespace strata::device {

QDebug operator<<(QDebug dbg, const Device* d)
{
    return dbg.nospace().noquote() << QStringLiteral("Device ") << d->deviceId_ << QStringLiteral(": ");
}

QDebug operator<<(QDebug dbg, const DevicePtr& d)
{
    return dbg << d.get();
}

Device::Device(const QByteArray& deviceId, const QString& name, const Type type) :
    deviceId_(deviceId),
    deviceName_(name),
    deviceType_(type),
    messageNumber_(0)
{ }

Device::~Device() { }

unsigned Device::nextMessageNumber()
{
    return ++messageNumber_;
}

QByteArray Device::deviceId() const
{
    return deviceId_;
}

const QString Device::deviceName() const
{
    return deviceName_;
}

Device::Type Device::deviceType() const
{
    return deviceType_;
}

}  // namespace
