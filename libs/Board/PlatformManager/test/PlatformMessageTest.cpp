/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "PlatformMessageTest.h"
#include <PlatformMessage.h>

using strata::platform::PlatformMessage;

QTEST_MAIN(PlatformMessageTest)

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
    // assignment operator and copy constructor test
    {
        PlatformMessage msg1("{\"a\":1}");
        PlatformMessage msg2("{\"b\":2}");
        PlatformMessage msg3(msg1);   // calls copy constructor
        PlatformMessage msg4 = msg1;  // also calls copy constructor
        QVERIFY(msg1.raw() == msg3.raw());
        QVERIFY(msg3.raw() == msg4.raw());
        msg2 = msg1;  // calls assignment operator
        QVERIFY(msg1.json() == msg2.json());
        QVERIFY(msg1.raw() == msg2.raw());
        msg3 = msg4;  // msg3 and msg4 had the same shared data before assignment
        QVERIFY(msg3.raw() == msg4.raw());
    }
}

void PlatformMessageTest::messageContentTest()
{
    const QByteArray source("{\"a\":1}");
    rapidjson::Document doc;
    doc.Parse(source.data(), source.size());
    PlatformMessage msg(source);
    QVERIFY(msg.raw() == source);
    QVERIFY(msg.json() == doc);
}
