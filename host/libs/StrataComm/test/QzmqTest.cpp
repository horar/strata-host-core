#include "QzmqTest.h"

// temp test, needs to be improved.
void ServerConnectorTest::testConnector()
{
    strata::strataComm::ServerConnector connector("tcp://127.0.0.1:5564");
    QCOMPARE(connector.initilize(), true);

    QTest::qWait(100);
    QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);

    connector.sendMessage(QByteArray::fromHex("414141"), "this message is meant to be to 414141");
    connector.sendMessage(QByteArray::fromHex("424242"), "this message is meant to be to 424242");

    QTest::qWait(100);
    QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
}

void ServerConnectorTest::testOpenConnectorFaild() 
{
    strata::strataComm::ServerConnector connector("tcp://127.0.0.1:5564");
    QCOMPARE(connector.initilize(), true);

    strata::strataComm::ServerConnector connectorDublicate("tcp://127.0.0.1:5564");
    QCOMPARE(connectorDublicate.initilize(), false);
}
