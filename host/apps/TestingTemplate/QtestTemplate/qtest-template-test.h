#ifndef QTEST_TEMPLATE_TEST_H
#define QTEST_TEMPLATE_TEST_H

#include "templateLib.h"
#include <QObject>
#include <QtTest>>
#include <QSignalSpy>
#include <iostream>

class QtestTemplateTest: public QObject
{
    Q_OBJECT
private slots:
    void testFunction1();
    void testFunction2();
    void testSignals1();
};

#endif // QTEST_TEMPLATE_TEST_H
