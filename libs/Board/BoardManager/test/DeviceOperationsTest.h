#pragma once

#include <rapidjson/document.h>
#include <QObject>
#include <Device/Mock/MockDevice.h>
#include "QtTest.h"

namespace strata::device::operation {
class BaseDeviceOperation;
enum class Result : int;
}

class DeviceOperationsTest : public QObject
{
    Q_OBJECT

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
    void switchToBootloaderAndBackTest();
    void cancelOperationTest();
    void identifyLegacyTest();

    void retryGetFirmwareInfoTest();

protected slots:
    void handleOperationFinished(strata::device::operation::Result result, int, QString);
    void handleRetryGetFirmwareInfo();

private:
    static void printJsonDoc(rapidjson::Document &doc);
    static void verifyMessage(const QByteArray &msg, const QByteArray &expectedJson);

    void connectHandlers(strata::device::operation::BaseDeviceOperation* operation);
    void connectRetryGetFirmwareInfoHandler(strata::device::operation::BaseDeviceOperation* operation);

    std::shared_ptr<strata::device::mock::MockDevice> device_;
    QSharedPointer<strata::device::operation::BaseDeviceOperation> deviceOperation_;
    int operationErrorCount_ = 0;
    int operationFinishedCount_ = 0;
    int operationTimeoutCount_ = 0;
    int operationCommandsCount_ = 0;
};

