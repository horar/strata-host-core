#pragma once

#include <rapidjson/document.h>
#include <QObject>
#include "DeviceMock.h"
#include "DeviceOperationsDerivate.h"
#include "QtTest.h"

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
    void handleOperationFinished(strata::device::DeviceOperation operation, int data);
    void handleOperationError(QString message);

private:
    static void printJsonDoc(rapidjson::Document &doc);
    static void verifyMessage(const QByteArray &msg, const QByteArray &expectedJson);

    std::shared_ptr<DeviceMock> device_;
    QSharedPointer<DeviceOperationsDerivate> deviceOperations_;
    int operationErrorCount_ = 0;
    int operationFinishedCount_ = 0;
    strata::device::DeviceOperation lastFinishedOperation_ = strata::device::DeviceOperation::None;
};
