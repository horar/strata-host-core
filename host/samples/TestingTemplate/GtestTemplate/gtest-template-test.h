#ifndef GTEST_TEMPLATE_TEST_H
#define GTEST_TEMPLATE_TEST_H

#include "templateLib.h"
#include <gtest/gtest.h>
#include <QtTest>
#include <QSignalSpy>

class GtestTemplateTest : public testing::Test
{
public:
    // test helpers

protected:
    void SetUp() override;

    virtual void TearDown() override;
};

#endif // GTEST_TEMPLATE_TEST_H
