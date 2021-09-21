/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <rapidjson/document.h>
#include <QObject>
#include <Platform.h>
#include <Mock/MockDevice.h>
#include "QtTest.h"
#include "Operations/PlatformOperations.h"

class PlatformOperationsTest : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(PlatformOperationsTest)

public:
    PlatformOperationsTest();

private slots:
    // test init/teardown
    void initTestCase();
    void cleanupTestCase();
    void init();
    void cleanup();

    // tests
    void connectTest();
    void identifyTest();
    void noResponseTest();
    void notJSONTest();
    void JSONWithoutPayloadTest();
    void nackTest();
    void invalidValueTest();
    void bootloaderResponseTest();
    void cancelOperationTest();
    void identifyLegacyTest();

    void retryGetFirmwareInfoTest();

protected slots:
    void handleOperationFinished(QByteArray, strata::platform::operation::Type, strata::platform::operation::Result result, int, QString);
    void handleRetryGetFirmwareInfo();

private:
    static void printJsonDoc(rapidjson::Document &doc);
    static void verifyMessage(const QByteArray &msg, const QByteArray &expectedJson);

    void connectRetryGetFirmwareInfoHandler(strata::platform::operation::BasePlatformOperation* operation);

    strata::platform::PlatformPtr platform_;
    strata::device::MockDevicePtr mockDevice_;
    strata::platform::operation::PlatformOperations platformOperations_;
    int operationErrorCount_ = 0;
    int operationFinishedCount_ = 0;
    int operationTimeoutCount_ = 0;
    int operationCommandsCount_ = 0;
};
