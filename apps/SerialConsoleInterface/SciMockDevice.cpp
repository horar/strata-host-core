#include "SciMockDevice.h"
#include "logging/LoggingQtCategories.h"

SciMockDevice::SciMockDevice(strata::PlatformManager *platformManager):
      mockDeviceModel_(platformManager)
{
}

SciMockDevice::~SciMockDevice()
{
}

void SciMockDevice::init() {
    mockDeviceModel_.init();
}

SciMockDeviceModel *SciMockDevice::mockDeviceModel()
{
    return &mockDeviceModel_;
}

SciMockCommandModel *SciMockDevice::mockCommandModel()
{
    return &mockCommandModel_;
}

SciMockResponseModel *SciMockDevice::mockResponseModel()
{
    return &mockResponseModel_;
}

SciMockVersionModel *SciMockDevice::mockVersionModel()
{
    return &mockVersionModel_;
}
