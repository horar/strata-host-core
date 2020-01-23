#pragma once

#include "Connector.h"

#include <string>
#include <atomic>
#include <gtest/gtest.h>


class ConnectorTest : public testing::Test
{
public:

    bool nonBlockingReadPolling(std::unique_ptr<Connector> &connector, std::string &message);

    void dealerMain(const std::string& identity, ReadMode read_mode);

    void routerMain(ReadMode read_mode);

    void subscriberMain(const std::string& identity, ReadMode read_mode);

    void subscriberEmptyMain(const int32_t identities, ReadMode read_mode);

    void publisherMain(const std::vector<std::string>& identities);

    void responseMain(ReadMode read_mode);

    void requestMain(ReadMode read_mode);

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
