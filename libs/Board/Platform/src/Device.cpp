#include <Device.h>

#include "logging/LoggingQtCategories.h"

namespace strata::device {

QDebug operator<<(QDebug dbg, const Device* d) {
    return dbg.nospace().noquote() << "Device " << d->deviceId_ << ": ";
}

QDebug operator<<(QDebug dbg, const DevicePtr& d) {
    return dbg << d.get();
}

Device::Device(const QByteArray& deviceId, const QString& name, const Type type) :
    deviceId_(deviceId), deviceName_(name), deviceType_(type)
{ }

Device::~Device() { }

QByteArray Device::deviceId() const {
    return deviceId_;
}

const QString Device::deviceName() const {
    return deviceName_;
}

Device::Type Device::deviceType() const {
    return deviceType_;
}

}  // namespace
