#ifndef DEVICE_PROPERTIES_H
#define DEVICE_PROPERTIES_H

namespace strata::device {

enum class DeviceProperties {
    deviceName,
    verboseName,
    platformId,
    classId,
    bootloaderVer,
    applicationVer
};

}  // namespace

#endif
