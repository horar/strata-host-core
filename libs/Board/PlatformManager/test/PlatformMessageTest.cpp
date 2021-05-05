#include "PlatformMessageTest.h"
#include <PlatformMessage.h>

using strata::platform::PlatformMessage;

PlatformMessageTest::PlatformMessageTest()
{
}

void PlatformMessageTest::initTestCase()
{
}

void PlatformMessageTest::cleanupTestCase()
{
}

void PlatformMessageTest::init()
{
}

void PlatformMessageTest::cleanup()
{
}

void PlatformMessageTest::validJsonTest()
{
    {
        PlatformMessage msg("{\"a\":1}");
        QCOMPARE(msg.isJsonValid(), true);
        QCOMPARE(msg.isJsonValidObject(), true);
        QCOMPARE(msg.jsonErrorOffset(), 0);
        QVERIFY(msg.jsonErrorString().isNull() == true);
    }
    // Strata messages requires object at JSON top level, but
    // there are valid JSONs which do not have object at top level.
    {
        PlatformMessage msg("[{\"a\":1},{\"b\":2}]");
        QCOMPARE(msg.isJsonValid(), true);
        QCOMPARE(msg.isJsonValidObject(), false);
        QCOMPARE(msg.jsonErrorOffset(), 0);
        QVERIFY(msg.jsonErrorString().isNull() == true);
    }
    {
        PlatformMessage msg("\"lorem ipsum\"");
        QCOMPARE(msg.isJsonValid(), true);
        QCOMPARE(msg.isJsonValidObject(), false);
    }
}

void PlatformMessageTest::invalidJsonTest()
{
    {
        PlatformMessage msg("{\"a\":b}");
        QCOMPARE(msg.isJsonValid(), false);
        QCOMPARE(msg.isJsonValidObject(), false);
        QCOMPARE(msg.jsonErrorOffset(), 5);
        QVERIFY(msg.jsonErrorString().isEmpty() == false);
    }
    {
        PlatformMessage msg("\"a\":1");
        QCOMPARE(msg.isJsonValid(), false);
        QCOMPARE(msg.isJsonValidObject(), false);
        QCOMPARE(msg.jsonErrorOffset(), 3);
        QVERIFY(msg.jsonErrorString().isEmpty() == false);
    }
    {
        PlatformMessage msg("");
        QCOMPARE(msg.isJsonValid(), false);
        QVERIFY(msg.raw().isNull() == false);
        QVERIFY(msg.raw().isEmpty() == true);
    }
    {
        PlatformMessage msg(" ");
        QCOMPARE(msg.isJsonValid(), false);
    }
    {
        const QByteArray nullArray;
        PlatformMessage msg(nullArray);
        QCOMPARE(msg.isJsonValid(), false);
        QVERIFY(msg.raw().isNull() == true);
    }
    {
        PlatformMessage msg;
        QCOMPARE(msg.isJsonValid(), false);
        QVERIFY(msg.raw().isNull() == true);
    }
}

void PlatformMessageTest::copyMessageTest()
{
    // valid JSON message
    {
        PlatformMessage msg1("{\"a\":1}");
        PlatformMessage msg2 = msg1;
        QVERIFY(msg1.json() == msg2.json());
        QVERIFY(msg1.raw() == msg2.raw());
    }
    // invalid JSON message
    {
        PlatformMessage msg1("{");
        PlatformMessage msg2 = msg1;
        QVERIFY(msg1.json() == msg2.json());
        QVERIFY(msg1.raw() == msg2.raw());
        QVERIFY(msg1.jsonErrorOffset() == msg2.jsonErrorOffset());
        QVERIFY(msg1.jsonErrorString() == msg2.jsonErrorString());
    }
}
