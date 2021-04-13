#pragma once

#include <rapidjson/document.h>
#include <QObject>
#include <Platform.h>
#include <Mock/MockDevice.h>
#include "QtTest.h"

namespace strata::platform::operation {
class BasePlatformOperation;
enum class Result : int;
}

class PlatformOperationsTest : public QObject
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

protected slots:
    void handleOperationFinished(strata::platform::operation::Result result, int, QString);

private:
    static void printJsonDoc(rapidjson::Document &doc);
    static void verifyMessage(const QByteArray &msg, const QByteArray &expectedJson);

    void connectHandlers(strata::platform::operation::BasePlatformOperation* operation);

    strata::platform::PlatformPtr platform_;
    std::shared_ptr<strata::device::MockDevice> mockDevice_;
    QSharedPointer<strata::platform::operation::BasePlatformOperation> platformOperation_;
    int operationErrorCount_ = 0;
    int operationFinishedCount_ = 0;
    int operationTimeoutCount_ = 0;
};
