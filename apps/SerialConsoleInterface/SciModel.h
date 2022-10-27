/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <PlatformManager.h>
#include "SciPlatformModel.h"
#ifdef APPS_TOOLBOX_SCI_MOCK_DEVICE
#include "SciMockDeviceModel.h"
#endif // APPS_TOOLBOX_SCI_MOCK_DEVICE
#ifdef APPS_FEATURE_BLE
#include "SciBleDeviceModel.h"
#endif // APPS_FEATURE_BLE

#include <QObject>
#include <QQmlError>

class SciModel : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SciModel)

    Q_PROPERTY(strata::PlatformManager* platformManager READ platformManager CONSTANT)
    Q_PROPERTY(SciPlatformModel* platformModel READ platformModel CONSTANT)
#ifdef APPS_TOOLBOX_SCI_MOCK_DEVICE
    Q_PROPERTY(SciMockDeviceModel* mockDeviceModel READ mockDeviceModel CONSTANT)
#endif // APPS_TOOLBOX_SCI_MOCK_DEVICE
#ifdef APPS_FEATURE_BLE
    Q_PROPERTY(SciBleDeviceModel* bleDeviceModel READ bleDeviceModel CONSTANT)
#endif // APPS_FEATURE_BLE

public:
    explicit SciModel(QObject *parent = nullptr);
    virtual ~SciModel();

    strata::PlatformManager* platformManager();
    SciPlatformModel* platformModel();
#ifdef APPS_TOOLBOX_SCI_MOCK_DEVICE
    SciMockDeviceModel* mockDeviceModel();
#endif // APPS_TOOLBOX_SCI_MOCK_DEVICE
#ifdef APPS_FEATURE_BLE
    SciBleDeviceModel* bleDeviceModel();
#endif // APPS_FEATURE_BLE

public slots:
    void handleQmlWarning(const QList<QQmlError> &warnings);

signals:
    void notifyQmlError(QString notifyQmlError);

private:
    strata::PlatformManager platformManager_;
    SciPlatformModel platformModel_;
#ifdef APPS_TOOLBOX_SCI_MOCK_DEVICE
    SciMockDeviceModel mockDeviceModel_;
#endif // APPS_TOOLBOX_SCI_MOCK_DEVICE
#ifdef APPS_FEATURE_BLE
    SciBleDeviceModel bleDeviceModel_;
#endif // APPS_FEATURE_BLE
};
