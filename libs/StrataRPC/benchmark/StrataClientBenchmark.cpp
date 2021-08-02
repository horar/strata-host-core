#include "StrataClientBenchmark.h"

#include <QMetaObject>

QTEST_MAIN(StrataClientBenchmark)

void StrataClientBenchmark::benchmarkLargeNumberOfHandlers()
{
    int totalNumberOfHandlers = 1000;
    StrataClient client(address_, "", this);
    client.connect();

    for (int i = 0; i < totalNumberOfHandlers; i++) {
        client.registerHandler(QString::number(i), [](const QJsonObject &) { return; });
    }

    QBENCHMARK
    {
        QMetaObject::invokeMethod(
            &client, "newServerMessage", Qt::DirectConnection,
            Q_ARG(QByteArray, R"({"jsonrpc":"2.0","method":"500","params":{}})"));
    }
}

void StrataClientBenchmark::benchmarkSendRequest()
{
    StrataClient client(address_, "", this);

    QBENCHMARK
    {
        client.sendRequest("test_method", QJsonObject());
    }
}

void StrataClientBenchmark::benchmarkSendNotification()
{
    StrataClient client(address_, "", this);

    QBENCHMARK
    {
        client.sendNotification("test_method", QJsonObject());
    }
}
