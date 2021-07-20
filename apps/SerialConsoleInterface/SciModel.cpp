#include "SciModel.h"
#include "logging/LoggingQtCategories.h"
#include <Mock/MockDeviceScanner.h>

SciModel::SciModel(QObject *parent)
    : QObject(parent),
      platformManager_(true, true, true),
      mockDeviceModel_(&platformManager_),
      platformModel_(&platformManager_)
{
    platformManager_.addScanner(strata::device::Device::Type::SerialDevice);
    platformManager_.addScanner(strata::device::Device::Type::MockDevice);
    platformManager_.addScanner(strata::device::Device::Type::TcpDevice);
    mockDeviceModel_.init();
}

SciModel::~SciModel()
{
}

strata::PlatformManager *SciModel::platformManager()
{
    return &platformManager_;
}

SciMockDeviceModel *SciModel::mockDeviceModel()
{
    return &mockDeviceModel_;
}


SciPlatformModel *SciModel::platformModel()
{
    return &platformModel_;
}
