#include "SciModel.h"
#include "logging/LoggingQtCategories.h"

SciModel::SciModel(QObject *parent)
    : QObject(parent),
      platformManager_(true, true, true),
      platformModel_(&platformManager_)
{
    platformManager_.init(strata::device::Device::Type::SerialDevice);
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
