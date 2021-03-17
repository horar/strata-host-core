#pragma once

#include <rapidjson/document.h>
#include <QObject>
#include <Mock/MockDevice.h>
#include "Flasher.h"
#include "QtTest.h"

class FlasherTest : public QObject
{
    Q_OBJECT

private slots:
    // test init/teardown
    void initTestCase();
    void cleanupTestCase();
    void init();
    void cleanup();

    // tests
    void flashFirmwareTest();
    void flashBootloaderTest();

    void disconnectWhileFlashingTest();

protected slots:
   void handleFlasherFinished(strata::Flasher::Result result, QString);
   void handleFlasherState(strata::Flasher::State state, bool done);
   void handleFlasherFirmwareProgress(int chunk, int total);
   void handleFlasherBootloaderProgress(int chunk, int total);
   void handleFlasherDevicePropertiesChanged();

private:
    static void printJsonDoc(rapidjson::Document &doc);
    static void verifyMessage(const QByteArray &msg, const QByteArray &expectedJson);

    void connectFlasherHandlers(strata::Flasher* flasher);

    std::shared_ptr<strata::device::mock::MockDevice> device_;

    QSharedPointer<strata::Flasher> flasher_;
    QSharedPointer<strata::device::operation::BaseDeviceOperation> deviceOperation_;

    int flasherNoFirmwareCount_ = 0;
    int flasherErrorCount_ = 0;
    int flasherTimeoutCount_ = 0;
    int flasherCancelledCount_ = 0;
    int flasherFinishedCount_ = 0;

//    int chunkSize_ = 0;
//    int chunkAmount_ = 0;
//    QByteArray md5_ = "";
};
