#pragma once

#include <Device/Operations/BaseDeviceOperation.h>

namespace strata::device::operation {

class SetAssistedPlatformId : public BaseDeviceOperation {

public:
    explicit SetAssistedPlatformId(
            const device::DevicePtr &device,
            const QString &classId,
            const QString &platformId,
            int boardCount,
            const QString &controllerClassId,
            const QString &controllerPlatformId,
            int controllerBoardCount,
            const QString fwClassId);

    ~SetAssistedPlatformId() = default;
};

}  // namespace
