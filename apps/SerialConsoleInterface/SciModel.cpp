#include "SciModel.h"
#include "logging/LoggingQtCategories.h"
#include <Mock/MockDeviceScanner.h>

SciModel::SciModel(QObject *parent)
    : QObject(parent),
      platformManager_(true, true, true),
      platformModel_(&platformManager_),
      mockDevice_(&platformManager_)
{
    platformManager_.init(strata::device::Device::Type::SerialDevice);
    platformManager_.init(strata::device::Device::Type::MockDevice);
    mockDevice_.init();
}

SciModel::~SciModel()
{
}

strata::PlatformManager *SciModel::platformManager()
{
    return &platformManager_;
}

SciPlatformModel *SciModel::platformModel()
{
    return &platformModel_;
}

SciMockDevice* SciModel::mockDevice()
{
    return &mockDevice_;
}
