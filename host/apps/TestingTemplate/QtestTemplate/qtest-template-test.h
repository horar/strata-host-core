#pragma once

#include "templateLib.h"

// #include <QtTest/QtTest>
// #include <QtCore>
#include <QObject>

class QtestTemplateTest: public QObject
{
    Q_OBJECT
private slots:
    void testFunction1();
    void testFunction2();
};
