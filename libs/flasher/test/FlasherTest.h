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
    void flashFirmwareWithoutStartApplicationTest();

    void setFwClassIdTest();

    void disconnectWhileFlashingTest();

protected slots:
   void handleFlasherFinished(strata::Flasher::Result result, QString);
   void handleFlasherState(strata::Flasher::State state, bool done);
   void handleFlasherFirmwareProgress(int chunk, int total);
   void handleFlasherBootloaderProgress(int chunk, int total);
   void handleFlasherDevicePropertiesChanged();

   void handleFlashingProgressForDisconnectWhileFlashingTest(int chunk, int total);

private:
    static void printJsonDoc(rapidjson::Document &doc);
    static void verifyMessage(const QByteArray &msg, const QByteArray &expectedJson);

    void clearExpectedValues();
    void connectFlasherHandlers(strata::Flasher* flasher);
    void connectFlasherForDisconnectWhileFlashingTest(strata::Flasher* flasher);

    strata::platform::PlatformPtr platform_;
    std::shared_ptr<strata::device::MockDevice> device_;
    QSharedPointer<strata::Flasher> flasher_;
    QSharedPointer<strata::platform::operation::BasePlatformOperation> deviceOperation_;

    void getExpectedValues(QFile firmware);
    void getMd5(QFile firmware);

    int flasherNoFirmwareCount_ = 0;
    int flasherErrorCount_ = 0;
    int flasherTimeoutCount_ = 0;
    int flasherCancelledCount_ = 0;
    int flasherFinishedCount_ = 0;

    QString expectedMd5_;
    int expectedChunksCount_;
    QVector<quint64> expectedChunkSize_;
    QVector<QByteArray> expectedChunkData_;
    QVector<quint16> expectedChunkCrc_;
};
