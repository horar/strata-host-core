#pragma once

#include <rapidjson/document.h>
#include <QObject>
#include <Mock/MockDevice.h>
#include <Operations/Flash.h>

#include "QtTest.h"

namespace strata::platform::operation {
class BasePlatformOperation;
enum class Result : int;
}

class PlatformOperationsV2Test : public QObject
{
    Q_OBJECT

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
    void handleOperationFinished(strata::platform::operation::Result result, int, QString);
    void handleFlashPartialStatus(int status);

private:
    static void printJsonDoc(rapidjson::Document &doc);
    static void verifyMessage(const QByteArray &msg, const QByteArray &expectedJson);

    void connectHandlers(strata::platform::operation::BasePlatformOperation* operation);
    void connectFlashHandlers(strata::platform::operation::BasePlatformOperation* operation);

    strata::platform::PlatformPtr platform_;
    std::shared_ptr<strata::device::MockDevice> mockDevice_;
    QSharedPointer<strata::platform::operation::BasePlatformOperation> platformOperation_;
    QSharedPointer<strata::platform::operation::Flash> flashOperation_;

    QByteArray dataForChunkSize(int chunkSize);

    void flashPartialStatusTest(strata::device::MockResponse response, int status);

    int operationErrorCount_ = 0;
    int operationFinishedCount_ = 0;
    int operationTimeoutCount_ = 0;
    int operationFailureCount_ = 0;
    int flashPartialStatusCount_ = 0;
};
