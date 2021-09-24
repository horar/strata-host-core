/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include "SciMockCommandModel.h"
#include "SciMockResponseModel.h"
#include "SciMockVersionModel.h"

#include <PlatformManager.h>
#include <Mock/MockDevice.h>

#include <QObject>

class SciMockDevice : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SciMockDevice)

public:
    Q_PROPERTY(bool isValid READ isValid NOTIFY isValidChanged)
    Q_PROPERTY(bool canReopenMockDevice READ canReopenMockDevice NOTIFY canReopenMockDeviceChanged)
    Q_PROPERTY(bool openEnabled READ mockIsOpenEnabled WRITE mockSetOpenEnabled NOTIFY openEnabledChanged)
    Q_PROPERTY(bool autoResponse READ mockIsAutoResponse WRITE mockSetAutoResponse NOTIFY autoResponseChanged)
    Q_PROPERTY(strata::device::MockCommand mockCommand READ mockGetCommand WRITE mockSetCommand NOTIFY mockCommandChanged)
    Q_PROPERTY(strata::device::MockResponse mockResponse READ mockGetResponse WRITE mockSetResponse NOTIFY mockResponseChanged)
    Q_PROPERTY(strata::device::MockVersion mockVersion READ mockGetVersion WRITE mockSetVersion NOTIFY mockVersionChanged)
    Q_PROPERTY(SciMockCommandModel* mockCommandModel READ mockCommandModel CONSTANT)
    Q_PROPERTY(SciMockResponseModel* mockResponseModel READ mockResponseModel CONSTANT)
    Q_PROPERTY(SciMockVersionModel* mockVersionModel READ mockVersionModel CONSTANT)

    explicit SciMockDevice(strata::PlatformManager *platformManager);
    virtual ~SciMockDevice();

    void setMockDevice(const strata::device::MockDevicePtr& mockDevice);

    Q_INVOKABLE bool reopenMockDevice();

    SciMockCommandModel* mockCommandModel();
    SciMockResponseModel* mockResponseModel();
    SciMockVersionModel* mockVersionModel();

    bool isValid() const;
    bool canReopenMockDevice() const;
    bool mockIsOpenEnabled() const;
    bool mockIsAutoResponse() const;
    strata::device::MockCommand mockGetCommand() const;
    strata::device::MockResponse mockGetResponse() const;
    strata::device::MockVersion mockGetVersion() const;

    void mockSetDeviceId(const QByteArray& deviceId);
    void mockSetOpenEnabled(bool enabled);
    void mockSetAutoResponse(bool autoResponse);
    void mockSetVersion(strata::device::MockVersion version);
    void mockSetCommand(strata::device::MockCommand command);
    void mockSetResponse(strata::device::MockResponse response);

signals:
    void isValidChanged();
    void canReopenMockDeviceChanged();
    void openEnabledChanged();
    void autoResponseChanged();
    void mockCommandChanged();
    void mockResponseChanged();
    void mockVersionChanged();

private:
    QByteArray deviceId_;
    strata::PlatformManager *platformManager_;
    SciMockCommandModel mockCommandModel_;
    SciMockResponseModel mockResponseModel_;
    SciMockVersionModel mockVersionModel_;
    strata::device::MockDevicePtr mockDevice_;
    strata::device::MockCommand currentCommand_ = strata::device::MockCommand::Get_firmware_info;
};
