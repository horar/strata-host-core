#include <QTest>
#include "PlatformController.h"

class TestPlatformController : public QObject {
    Q_OBJECT
  public:
    TestPlatformController()
    {

    }

private slots:
    void initPlatformController();
    void testWaterHeaterAtributes();
    void testCommunication();
    void stressPlatform();

private:
    PlatformController* platformController_;
    QJsonObject payload_;
};

void TestPlatformController::initPlatformController()
{
    platformController_= new PlatformController();
    bool isPlatformConnected = QTest::qWaitFor([&]() {

        return platformController_->platformConnected();
    }, 5000);

    QCOMPARE(isPlatformConnected, true);
}
void TestPlatformController::testWaterHeaterAtributes()
{
    if (!platformController_->platformConnected())
        QSKIP("\nThis test requires connected platform\n");

    QCOMPARE(platformController_->verboseName(),"ON WaterHeater");
    QCOMPARE(platformController_->platformID(),"SEC.2018.0.0.0.0.00000000-0000-0000-0000-000000000000");
}

void TestPlatformController::testCommunication()
{
    if (!platformController_->platformConnected())
        QSKIP("\nThis test requires connected platform\n");

    platformController_->sendCommand("{}","test");
    QTest::qWait(200);
    QCOMPARE(platformController_->notification(),"{\"payload\":{\"cmd\":\"\"},\"notification\":\"Unknown Command\"}");

    QBENCHMARK_ONCE(platformController_->notification().localeAwareCompare("{\"payload\":{\"cmd\":\"\"},\"notification\":\"Unknown Command\"}"));
}

void TestPlatformController::stressPlatform()
{
    if (!platformController_->platformConnected())
        QSKIP("\nThis test requires connected platform\n");
    int ms=100;
    while(ms!=0)
    {
    platformController_->setNotification(QString());
    platformController_->sendCommand("{}","test");
    QTest::qWait(ms);
    if(ms<=10)
        QEXPECT_FAIL("10 ms and lower", "10 ms and lower", Continue);
    QCOMPARE(platformController_->notification(),"{\"payload\":{\"cmd\":\"\"},\"notification\":\"Unknown Command\"}");

    ms-=10;
    }
}


QTEST_MAIN(TestPlatformController)
#include "main.moc"
