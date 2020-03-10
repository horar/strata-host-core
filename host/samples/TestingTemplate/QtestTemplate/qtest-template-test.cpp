#include "qtest-template-test.h"

void QtestTemplateTest::testFunction1() {
     templateLib myTemplateLib;
     QCOMPARE(myTemplateLib.returnBool(true), true);
}

void QtestTemplateTest::testFunction2() {
     QSKIP("This test is skipped.."); // skip the failing test 
     templateLib myTemplateLib;
     QCOMPARE(myTemplateLib.returnBool(false), true);
}

void QtestTemplateTest::testSignals1() {
    // signal set-up
    templateLib template_1, template_2;
    QObject::connect(&template_1, &templateLib::valueChanged, &template_2, &templateLib::setValue);
    
    // set-up QSignalSpy -> a list of the emittied singals.
    // record valueChanged signal from template_1
    QSignalSpy mSpy(&template_1, &templateLib::valueChanged);

    // invoke the signal
    template_1.setValue(1);
    template_1.setValue(1); // Signal won't be emmited
    template_1.setValue(13);
    template_1.setValue(2);
    template_1.setValue(10);
    template_1.setValue(5);

    // check values
    QCOMPARE(template_1.getValue(), 5);
    QCOMPARE(template_2.getValue(), template_1.getValue());

    // check how many singals were emitted
    QCOMPARE(mSpy.count(), 5);

    // Inspect emitted signals
    QCOMPARE(mSpy.at(0).at(0).toInt(), 1);
    QCOMPARE(mSpy.at(1).at(0).toInt(), 13);
    QCOMPARE(mSpy.at(2).at(0).toInt(), 2);
    QCOMPARE(mSpy.at(3).at(0).toInt(), 10);
    QCOMPARE(mSpy.at(4).at(0).toInt(), 5);
}
