/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>
#include "QtTest.h"
#include <PlatformManager.h>
#include <Operations/PlatformOperations.h>
#include <Mock/MockDevice.h>
#include <Mock/MockDeviceScanner.h>
#include <Platform.h>
#include <rapidjson/document.h>

class PlatformErrorsTest : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(PlatformErrorsTest)

public:
    PlatformErrorsTest();

private slots:
    // test init/teardown
    void initTestCase();
    void cleanupTestCase();
    void init();
    void cleanup();

    // tests
    void deviceLostWithDisconnectTest();
    void deviceLostWithoutDisconnectTest();
    void singleErrorTest();
    void errorBeforeOperationTest();
    void errorDuringOperationTest();
    void errorAfterOperationTest();
    void unableToOpenTest();
    void unableToCloseTest();
    void multipleOperationsTest();

private:
    void addMockDevice();
    void removeMockDevice(bool alreadyDisconnected);
    void verifyMessage(const QByteArray &msg, const QByteArray &expectedJson);
    void printJsonDoc(rapidjson::Document &doc);

    const QByteArray deviceId_ = "mock1234";
    strata::platform::PlatformPtr platform_;
    strata::device::MockDevicePtr mockDevice_;

    strata::platform::operation::PlatformOperations platformOperations_;

    std::shared_ptr<strata::PlatformManager> platformManager_;
    std::shared_ptr<strata::device::scanner::MockDeviceScanner> mockDeviceScanner_;

    int devicesCount_ = 0;
};

