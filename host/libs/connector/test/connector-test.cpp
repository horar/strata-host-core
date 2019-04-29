
#include "Connector.h"
#include <gtest/gtest.h>
#include <atomic>
#include <memory>
#include <thread>
#include <zhelpers.hpp>

class ConnectorTest : public testing::Test
{
public:
    void dealerMain(const std::string& identity)
    {
        std::unique_ptr<Connector> dealerConnector(
            ConnectorFactory::getConnector(ConnectorFactory::CONNECTOR_TYPE::DEALER));

        dealerConnector->setDealerID(identity);
        ASSERT_TRUE(dealerConnector->open(ADDRESS));

        for (uint32_t i = 0; i < LOOP_COUNTER; i++) {
            for (uint32_t j = 0; j < REQUEST_MESSAGE_REFS.size(); j++) {
                dealerConnector->send(REQUEST_MESSAGE_REFS[j] + dealerConnector->getDealerID());

                std::string workload;
                ASSERT_TRUE(dealerConnector->read(workload));
                ASSERT_EQ(RESPONSE_MESSAGE_REFS[j],
                          workload.substr(0, RESPONSE_MESSAGE_REFS[j].size()));
                ASSERT_EQ(dealerConnector->getDealerID(),
                          workload.substr(RESPONSE_MESSAGE_REFS[j].size()));
            }
        }
        return;
    }

    void routerMain()
    {
        std::unique_ptr<Connector> routerConnector(
            ConnectorFactory::getConnector(ConnectorFactory::CONNECTOR_TYPE::ROUTER));

        routerConnector->setDealerID("B");
        ASSERT_TRUE(routerConnector->open(ADDRESS));

        const std::string REQ_REF("req");

        for (uint32_t i = 0; i < MAX_IDS * LOOP_COUNTER * REQUEST_MESSAGE_REFS.size(); ++i) {
            std::string message;
            ASSERT_TRUE(routerConnector->read(message));
            ASSERT_EQ(REQ_REF, message.substr(0, REQ_REF.size()));
            routerConnector->send("resp" + message.substr(REQ_REF.size()));
        }
    }

    void subscriberMain(const std::string& identity)
    {
        std::unique_ptr<Connector> subscriberConnector(
            ConnectorFactory::getConnector(ConnectorFactory::CONNECTOR_TYPE::SUBSCRIBER));

        subscriberConnector->setDealerID(identity);
        ASSERT_TRUE(subscriberConnector->open(ADDRESS));

        int32_t index = -1;
        std::string messageOut;

        for (uint32_t i = 0; i < LOOP_COUNTER; ++i) {
            ASSERT_TRUE(subscriberConnector->read(messageOut));
            if (-1 == index) {
                index = static_cast<int32_t>(
                    std::distance(PUBLISHER_MESSAGE_REFS.begin(),
                                  std::find(PUBLISHER_MESSAGE_REFS.begin(),
                                            PUBLISHER_MESSAGE_REFS.end(), messageOut)));
                ASSERT_GE(PUBLISHER_MESSAGE_REFS.size(), index);
            }

            ASSERT_EQ(PUBLISHER_MESSAGE_REFS[static_cast<uint32_t>(index++) %
                                             PUBLISHER_MESSAGE_REFS.size()],
                      messageOut);
        }
    }

    void subscriberEmptyMain(const int32_t identities)
    {
        std::unique_ptr<Connector> subscriberConnector(
            ConnectorFactory::getConnector(ConnectorFactory::CONNECTOR_TYPE::SUBSCRIBER));

        subscriberConnector->setDealerID("");
        ASSERT_TRUE(subscriberConnector->open(ADDRESS));

        int32_t index = -1;
        int32_t step = 0;

        std::string messageOut;

        while (true) {
            ASSERT_TRUE(subscriberConnector->read(messageOut));
            if (-1 == index) {
                index = static_cast<int32_t>(
                    std::distance(PUBLISHER_MESSAGE_REFS.begin(),
                                  std::find(PUBLISHER_MESSAGE_REFS.begin(),
                                            PUBLISHER_MESSAGE_REFS.end(), messageOut)));
                ASSERT_GE(PUBLISHER_MESSAGE_REFS.size(), index);
            }
            if (PUBLISHER_MESSAGE_REFS[static_cast<uint32_t>(index) %
                                       PUBLISHER_MESSAGE_REFS.size()] != messageOut) {
                step = identities + 1;
                break;
            }
        }

        for (uint32_t i = 0; i < LOOP_COUNTER; i++) {
            ASSERT_TRUE(subscriberConnector->read(messageOut));

            ASSERT_EQ(PUBLISHER_MESSAGE_REFS[static_cast<uint32_t>(index + (step++ / identities)) %
                                             PUBLISHER_MESSAGE_REFS.size()],
                      messageOut);
        }
    }

    void publisherMain(const std::vector<std::string>& identities)
    {
        std::unique_ptr<Connector> publisherConnector(
            ConnectorFactory::getConnector(ConnectorFactory::CONNECTOR_TYPE::PUBLISHER));

        for (const std::string& identity : identities) {
            publisherConnector->addSubscriber(identity);
        }
        ASSERT_TRUE(publisherConnector->open(ADDRESS));

        uint32_t i = 0;
        while (false == mStop_) {
            publisherConnector->send(PUBLISHER_MESSAGE_REFS[i++ % PUBLISHER_MESSAGE_REFS.size()]);
        }
    }

    void responseMain()
    {
        std::unique_ptr<Connector> responseConnector(
            ConnectorFactory::getConnector(ConnectorFactory::CONNECTOR_TYPE::RESPONSE));

        ASSERT_TRUE(responseConnector->open(ADDRESS));

        std::string messageOut;

        for (uint32_t i = 0; i < LOOP_COUNTER; i++) {
            for (uint32_t index = 0; index < REQUEST_MESSAGE_REFS.size(); ++index) {
                ASSERT_TRUE(responseConnector->read(messageOut));
                ASSERT_EQ(messageOut, REQUEST_MESSAGE_REFS[index]);
                responseConnector->send(RESPONSE_MESSAGE_REFS[index]);
            }
        }
    }

    void requestMain()
    {
        std::unique_ptr<Connector> requestConnector(
            ConnectorFactory::getConnector(ConnectorFactory::CONNECTOR_TYPE::REQUEST));

        ASSERT_TRUE(requestConnector->open(ADDRESS));

        std::string messageOut;

        for (uint32_t i = 0; i < LOOP_COUNTER; i++) {
            for (uint32_t index = 0; index < REQUEST_MESSAGE_REFS.size(); ++index) {
                requestConnector->send(REQUEST_MESSAGE_REFS[index]);
                ASSERT_TRUE(requestConnector->read(messageOut));
                ASSERT_EQ(messageOut, RESPONSE_MESSAGE_REFS[index]);
            }
        }
    }

    void stop()
    {
        mStop_ = true;
    }

protected:
    void SetUp() override
    {
    }

    virtual void TearDown() override
    {
    }

    const std::string ADDRESS{"tcp://127.0.0.1:5555"};

    const uint32_t MAX_IDS{10};
    const uint32_t LOOP_COUNTER{20};

    const std::vector<const std::string> REQUEST_MESSAGE_REFS{"req1", "req2", "req3"};
    const std::vector<const std::string> RESPONSE_MESSAGE_REFS{"resp1", "resp2", "resp3"};
    const std::vector<const std::string> PUBLISHER_MESSAGE_REFS{"pub-sub1", "pub-sub2", "pub-sub3"};

    std::atomic_int mStop_{false};
};

TEST_F(ConnectorTest, RouDea_10)
{
    std::vector<std::thread> dealers;
    for (uint32_t routerId = 0; routerId < MAX_IDS; ++routerId) {
        dealers.emplace_back(
            std::thread(&ConnectorTest::dealerMain, this, "B" + std::to_string(routerId)));
    }

    std::thread router(&ConnectorTest::routerMain, this);
    router.join();

    for (std::thread& dealer : dealers) {
        dealer.join();
    }
}

TEST_F(ConnectorTest, PubSub_10)
{
    std::vector<std::string> identities;
    std::vector<std::thread> subscribers;

    for (uint32_t subscriberId = 0; subscriberId < MAX_IDS; ++subscriberId) {
        identities.emplace_back("B" + std::to_string(subscriberId));
        subscribers.emplace_back(
            std::thread(&ConnectorTest::subscriberMain, this, identities.back()));
    }

    std::thread publisher(&ConnectorTest::publisherMain, this, identities);

    for (std::thread& subscriber : subscribers) {
        subscriber.join();
    }

    stop();
    publisher.join();
}

TEST_F(ConnectorTest, PubSub_8_2)
{
    std::vector<std::string> identities;
    std::vector<std::thread> subscribers;

    for (uint32_t subscriberId = 0; subscriberId < MAX_IDS - 2; ++subscriberId) {
        identities.emplace_back("B" + std::to_string(subscriberId));
        subscribers.emplace_back(
            std::thread(&ConnectorTest::subscriberMain, this, identities.back()));
    }

    // no filter -> to capture all messages
    subscribers.emplace_back(std::thread(&ConnectorTest::subscriberEmptyMain, this, MAX_IDS - 2));
    subscribers.emplace_back(std::thread(&ConnectorTest::subscriberEmptyMain, this, MAX_IDS - 2));

    std::thread publisher(&ConnectorTest::publisherMain, this, identities);

    for (std::thread& subscriber : subscribers) {
        subscriber.join();
    }

    stop();
    publisher.join();
}

TEST_F(ConnectorTest, ReqRep)
{
    std::thread response(&ConnectorTest::responseMain, this);
    std::thread request(&ConnectorTest::requestMain, this);

    request.join();
    response.join();
}

int main(int argc, char** argv)
{
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
