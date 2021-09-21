/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include "Connector.h"

#include <gtest/gtest.h>
#include <atomic>
#include <string>

class ConnectorTest : public testing::Test
{
public:
    bool nonBlockingReadPolling(std::unique_ptr<strata::connector::Connector>& connector,
                                std::string& message);

    void dealerMain(const std::string& identity, strata::connector::ReadMode read_mode);

    void routerMain(strata::connector::ReadMode read_mode);

    void subscriberMain(const std::string& identity, strata::connector::ReadMode read_mode);

    void subscriberEmptyMain(const int32_t identities, strata::connector::ReadMode read_mode);

    void publisherMain(const std::vector<std::string>& identities);

    void responseMain(strata::connector::ReadMode read_mode);

    void requestMain(strata::connector::ReadMode read_mode);

    void stop();

protected:
    void SetUp() override;

    virtual void TearDown() override;

    const std::string ADDRESS{"tcp://127.0.0.1:5555"};

    const uint32_t MAX_IDS{10};
    const uint32_t LOOP_COUNTER{20};

    const std::vector<std::string> REQUEST_MESSAGE_REFS{"req1", "req2", "req3"};
    const std::vector<std::string> RESPONSE_MESSAGE_REFS{"resp1", "resp2", "resp3"};
    const std::vector<std::string> PUBLISHER_MESSAGE_REFS{"pub-sub1", "pub-sub2", "pub-sub3"};

    std::atomic_int mStop_{false};
};
