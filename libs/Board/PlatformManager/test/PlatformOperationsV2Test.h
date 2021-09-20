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
#include <Mock/MockDevice.h>
#include "Operations/PlatformOperations.h"

#include "QtTest.h"

class PlatformOperationsV2Test : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(PlatformOperationsV2Test)

public:
    PlatformOperationsV2Test();

private slots:
    // test init/teardown
    void initTestCase();
    void cleanupTestCase();
    void init();
    void cleanup();

    // tests
    void identifyEmbeddedApplicationTest();
    void identifyAssistedApplicationTest();

    void identifyEmbeddedBootloaderTest();
    void identifyAssistedBootloaderTest();

    void identifyAssistedNoBoardTest();

    void switchToBootloaderAndBackEmbeddedTest();
    void switchToBootloaderAndBackAssistedTest();

    void cancelOperationEmbeddedTest();
    void cancelOperationAssistedTest();

    void noResponseEmbeddedTest();
    void noResponseAssistedTest();

    void invalidValueV2Test();

    void flashFirmwareTest();
    void flashBootloaderTest();

    void flashResendChunkTest();
    void flashMemoryErrorTest();
    void flashInvalidCmdSequenceTest();
    void flashInvalidValueTest();
    void cancelFlashOperationTest();
    void startFlashInvalidTest();

protected slots:
    void handleOperationFinished(QByteArray, strata::platform::operation::Type, strata::platform::operation::Result result, int, QString);
    void handleFlashPartialStatus(int status);

private:
    static void printJsonDoc(rapidjson::Document &doc);
    static void verifyMessage(const QByteArray &msg, const QByteArray &expectedJson);

    void connectFlashHandlers(strata::platform::operation::BasePlatformOperation* operation);

    strata::platform::PlatformPtr platform_;
    strata::device::MockDevicePtr mockDevice_;
    strata::platform::operation::PlatformOperations platformOperations_;

    QByteArray dataForChunkSize(int chunkSize);

    void flashPartialStatusTest(strata::device::MockResponse response, int status);

    int operationErrorCount_ = 0;
    int operationFinishedCount_ = 0;
    int operationTimeoutCount_ = 0;
    int operationFailureCount_ = 0;
    int flashPartialStatusCount_ = 0;
};
