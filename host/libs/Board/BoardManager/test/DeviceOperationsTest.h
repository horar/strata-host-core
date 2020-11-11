#pragma once

#include <rapidjson/document.h>
#include <QObject>
#include "DeviceMock.h"
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
    void switchToBootloaderAndBackTest();
    void cancelOperationTest();

protected slots:
    void handleOperationFinished(strata::device::operation::Result result, int, QString);

private:
    static void printJsonDoc(rapidjson::Document &doc);
    static void verifyMessage(const QByteArray &msg, const QByteArray &expectedJson);

    void connectHandlers(strata::device::operation::BaseDeviceOperation* operation);

    std::shared_ptr<DeviceMock> device_;
    QSharedPointer<strata::device::operation::BaseDeviceOperation> deviceOperation_;
    int operationErrorCount_ = 0;
    int operationFinishedCount_ = 0;
};
