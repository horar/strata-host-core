/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

// helper for QT test macros - define additional macros for convenience
#pragma once

#include <QtTest>

/*!
 * QVERIFY_ works as QVERIFY, but doesn't return. Unlike QVERIFY, can be used in functions with
 * non-void return type.
 */
#define QVERIFY_(statement) [&]() { QVERIFY(statement); }()

/*!
 * QCOMPARE_ works as QCOMPARE, but doesn't return. Unlike QCOMPARE, can be used in functions with
 * non-void return type.
 */
#define QCOMPARE_(actual, expected) [&]() { QCOMPARE(actual, expected); }()

/*!
 * QFAIL_ works as QFAIL, but doesn't return. Unlike QFAIL, can be used in functions with non-void
 * return type.
 */
#define QFAIL_(message) [&]() { QFAIL(message); }()

// add more macros as needed
