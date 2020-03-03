#include "qtest-template-test.h"
#include <QtTest>

void QtestTemplateTest::testFunction1() {
     templateLib myTemplateLib;
     QCOMPARE(myTemplateLib.returnBool(true), true);
}

void QtestTemplateTest::testFunction2() {
     templateLib myTemplateLib;
     QCOMPARE(myTemplateLib.returnBool(false), true);
}
