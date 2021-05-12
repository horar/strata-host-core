#include "SciModel.h"
#include "logging/LoggingQtCategories.h"
#include <Mock/MockDeviceScanner.h>

SciModel::SciModel(QObject *parent)
    : QObject(parent),
      platformManager_(true, true, true),
      platformModel_(&platformManager_),
      mockDeviceModel_(&platformManager_)
{
    platformManager_.init(strata::device::Device::Type::SerialDevice);
    platformManager_.init(strata::device::Device::Type::MockDevice);
    mockDeviceModel_.init();
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

SciMockDeviceModel *SciModel::mockDeviceModel()
{
    return &mockDeviceModel_;
}

SciMockCommandModel *SciModel::mockCommandModel()
{
    return &mockCommandModel_;
}

SciMockResponseModel *SciModel::mockResponseModel()
{
    return &mockResponseModel_;
}

SciMockVersionModel *SciModel::mockVersionModel()
{
    return &mockVersionModel_;
}
