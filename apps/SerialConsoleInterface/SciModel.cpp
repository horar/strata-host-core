#include "SciModel.h"
#include "logging/LoggingQtCategories.h"
#include <Mock/MockDeviceScanner.h>

SciModel::SciModel(QObject *parent)
    : QObject(parent),
      platformManager_(true, true, true),
      platformModel_(&platformManager_),
      mockDeviceModel_(&platformManager_),
      bleDeviceModel_(&platformManager_)
{
    platformManager_.addScanner(strata::device::Device::Type::SerialDevice);
    platformManager_.addScanner(strata::device::Device::Type::MockDevice);
    platformManager_.addScanner(strata::device::Device::Type::TcpDevice);
    platformManager_.addScanner(strata::device::Device::Type::BLEDevice);
    mockDeviceModel_.init();
    bleDeviceModel_.init();
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

SciBleDeviceModel *SciModel::bleDeviceModel()
{
    return &bleDeviceModel_;
}
