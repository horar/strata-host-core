#include <DeviceNew.h>

#include "logging/LoggingQtCategories.h"

namespace strata::device {

QDebug operator<<(QDebug dbg, const DeviceNew* d) {
    return dbg.nospace().noquote() << "Device " << d->deviceId_ << ": ";
}

QDebug operator<<(QDebug dbg, const DeviceNewPtr& d) {
    return dbg << d.get();
}

DeviceNew::DeviceNew(const QByteArray& deviceId, const QString& name, const Type type) :
    deviceId_(deviceId), deviceName_(name), deviceType_(type)
{ }

DeviceNew::~DeviceNew() { }

QByteArray DeviceNew::deviceId() const {
    return deviceId_;
}

const QString DeviceNew::deviceName() const {
    return deviceName_;
}

DeviceNew::Type DeviceNew::deviceType() const {
    return deviceType_;
}

}  // namespace
