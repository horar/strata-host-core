/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SciModel.h"
#include "logging/LoggingQtCategories.h"
#ifdef APPS_TOOLBOX_SCI_MOCK_DEVICE
#include <Mock/MockDeviceScanner.h>
#endif // APPS_TOOLBOX_SCI_MOCK_DEVICE

SciModel::SciModel(QObject *parent)
    : QObject(parent)
      , platformManager_(true, true, true)
      , platformModel_(&platformManager_)
#ifdef APPS_TOOLBOX_SCI_MOCK_DEVICE
      , mockDeviceModel_(&platformManager_)
#endif // APPS_TOOLBOX_SCI_MOCK_DEVICE
#ifdef APPS_FEATURE_BLE
      , bleDeviceModel_(&platformManager_)
#endif // APPS_FEATURE_BLE
{
    platformManager_.addScanner(strata::device::Device::Type::SerialDevice);
#ifdef APPS_TOOLBOX_SCI_MOCK_DEVICE
    platformManager_.addScanner(strata::device::Device::Type::MockDevice);
#endif // APPS_TOOLBOX_SCI_MOCK_DEVICE
    platformManager_.addScanner(strata::device::Device::Type::TcpDevice);
#ifdef APPS_FEATURE_BLE
    platformManager_.addScanner(strata::device::Device::Type::BLEDevice);
#endif // APPS_FEATURE_BLE
#ifdef APPS_TOOLBOX_SCI_MOCK_DEVICE
    mockDeviceModel_.init();
#endif // APPS_TOOLBOX_SCI_MOCK_DEVICE
#ifdef APPS_FEATURE_BLE
    bleDeviceModel_.init();
#endif // APPS_FEATURE_BLE
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

#ifdef APPS_TOOLBOX_SCI_MOCK_DEVICE
SciMockDeviceModel *SciModel::mockDeviceModel()
{
    return &mockDeviceModel_;
}
#endif // APPS_TOOLBOX_SCI_MOCK_DEVICE

void SciModel::handleQmlWarning(const QList<QQmlError> &warnings)
{
    QStringList msg;
    foreach (const QQmlError &error, warnings) {
        msg << error.toString();
    }
    emit notifyQmlError(msg.join(QStringLiteral("\n")));
}

#ifdef APPS_FEATURE_BLE
SciBleDeviceModel *SciModel::bleDeviceModel()
{
    return &bleDeviceModel_;
}
#endif // APPS_FEATURE_BLE
