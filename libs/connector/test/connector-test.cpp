/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "connector-test.h"

#include <chrono>
#include <memory>
#include <thread>

using strata::connector::Connector;
using strata::connector::ReadMode;

TEST_F(ConnectorTest, RouDea_BlockingRead_10)
{
    std::vector<std::thread> dealers;
    for (uint32_t routerId = 0; routerId < MAX_IDS; ++routerId) {
        dealers.emplace_back(
            std::thread(&ConnectorTest::dealerMain, this, "B" + std::to_string(routerId), ReadMode::BLOCKING));
    }

    std::thread router(&ConnectorTest::routerMain, this, ReadMode::BLOCKING);
    router.join();

    for (std::thread& dealer : dealers) {
        dealer.join();
    }
}

TEST_F(ConnectorTest, RouDea_NonBlockingRead_10)
{
    std::vector<std::thread> dealers;
    for (uint32_t routerId = 0; routerId < MAX_IDS; ++routerId) {
        dealers.emplace_back(
            std::thread(&ConnectorTest::dealerMain, this, "B" + std::to_string(routerId), ReadMode::NONBLOCKING));
    }

    std::thread router(&ConnectorTest::routerMain, this, ReadMode::NONBLOCKING);
    router.join();

    for (std::thread& dealer : dealers) {
        dealer.join();
    }
}

TEST_F(ConnectorTest, PubSub_NonBlocking_10)
{
    std::vector<std::string> identities;
    std::vector<std::thread> subscribers;

    for (uint32_t subscriberId = 0; subscriberId < MAX_IDS; ++subscriberId) {
        identities.emplace_back("B" + std::to_string(subscriberId));
        subscribers.emplace_back(
            std::thread(&ConnectorTest::subscriberMain, this, identities.back(), ReadMode::NONBLOCKING));
    }

    std::thread publisher(&ConnectorTest::publisherMain, this, identities);

    for (std::thread& subscriber : subscribers) {
        subscriber.join();
    }

    stop();
    publisher.join();
}

TEST_F(ConnectorTest, PubSub_Blocking_10)
{
    std::vector<std::string> identities;
    std::vector<std::thread> subscribers;

    for (uint32_t subscriberId = 0; subscriberId < MAX_IDS; ++subscriberId) {
        identities.emplace_back("B" + std::to_string(subscriberId));
        subscribers.emplace_back(
            std::thread(&ConnectorTest::subscriberMain, this, identities.back(), ReadMode::BLOCKING));
    }

    std::thread publisher(&ConnectorTest::publisherMain, this, identities);

    for (std::thread& subscriber : subscribers) {
        subscriber.join();
    }

    stop();
    publisher.join();
}

TEST_F(ConnectorTest, PubSub_Blocking_Read_8_2)
{
    std::vector<std::string> identities;
    std::vector<std::thread> subscribers;

    for (uint32_t subscriberId = 0; subscriberId < MAX_IDS - 2; ++subscriberId) {
        identities.emplace_back("B" + std::to_string(subscriberId));
        subscribers.emplace_back(
            std::thread(&ConnectorTest::subscriberMain, this, identities.back(), ReadMode::BLOCKING));
    }

    // no filter -> to capture all messages
    subscribers.emplace_back(std::thread(&ConnectorTest::subscriberEmptyMain, this, MAX_IDS - 2, ReadMode::BLOCKING));
    subscribers.emplace_back(std::thread(&ConnectorTest::subscriberEmptyMain, this, MAX_IDS - 2, ReadMode::BLOCKING));

    std::thread publisher(&ConnectorTest::publisherMain, this, identities);

    for (std::thread& subscriber : subscribers) {
        subscriber.join();
    }

    stop();
    publisher.join();
}

TEST_F(ConnectorTest, PubSub_NonBlockingRead_8_2)
{
    std::vector<std::string> identities;
    std::vector<std::thread> subscribers;

    for (uint32_t subscriberId = 0; subscriberId < MAX_IDS - 2; ++subscriberId) {
        identities.emplace_back("B" + std::to_string(subscriberId));
        subscribers.emplace_back(
            std::thread(&ConnectorTest::subscriberMain, this, identities.back(), ReadMode::NONBLOCKING));
    }

    // no filter -> to capture all messages
    subscribers.emplace_back(std::thread(&ConnectorTest::subscriberEmptyMain, this, MAX_IDS - 2, ReadMode::NONBLOCKING));
    subscribers.emplace_back(std::thread(&ConnectorTest::subscriberEmptyMain, this, MAX_IDS - 2, ReadMode::NONBLOCKING));

    std::thread publisher(&ConnectorTest::publisherMain, this, identities);

    for (std::thread& subscriber : subscribers) {
        subscriber.join();
    }

    stop();
    publisher.join();
}

TEST_F(ConnectorTest, ReqRep_Blocking_Read)
{
    std::thread response(&ConnectorTest::responseMain, this, ReadMode::BLOCKING);
    std::thread request(&ConnectorTest::requestMain, this, ReadMode::BLOCKING);

    request.join();
    response.join();
}

TEST_F(ConnectorTest, ReqRep_NonBlocking_Read)
{
    std::thread response(&ConnectorTest::responseMain, this, ReadMode::NONBLOCKING);
    std::thread request(&ConnectorTest::requestMain, this, ReadMode::NONBLOCKING);

    request.join();
    response.join();
}

bool ConnectorTest::nonBlockingReadPolling(std::unique_ptr<Connector> &connector, std::string &message)   {
    // Polling on the non-blocking call with ~2000ms timeout
    // This call will fail if the message was lost (failure in ZMQ library) or never send (failure in test itself)
    // But can also fail if computer resources are exhausted and the ~2000ms timeout is exceeded
    for(uint32_t i = 0; i < 200; i++) {
        if(connector->read(message, ReadMode::NONBLOCKING)) {
            return true;
        } else {
            std::this_thread::sleep_for(std::chrono::milliseconds(10));
        }
    }
    return false;
}

void ConnectorTest::dealerMain(const std::string &identity, ReadMode read_mode)
{
    std::unique_ptr<Connector> dealerConnector(
                Connector::getConnector(Connector::CONNECTOR_TYPE::DEALER));
    dealerConnector->setDealerID(identity);
    ASSERT_TRUE(dealerConnector->open(ADDRESS));
    for (uint32_t i = 0; i < LOOP_COUNTER; i++) {
        for (uint32_t j = 0; j < REQUEST_MESSAGE_REFS.size(); j++) {
            dealerConnector->send(REQUEST_MESSAGE_REFS[j] + dealerConnector->getDealerID());
            std::string workload;
            if(read_mode == ReadMode::BLOCKING) {
                ASSERT_TRUE(dealerConnector->read(workload, read_mode));
            }
            else {
                ASSERT_TRUE(nonBlockingReadPolling(dealerConnector, workload));
            }
            EXPECT_EQ(RESPONSE_MESSAGE_REFS[j],
                      workload.substr(0, RESPONSE_MESSAGE_REFS[j].size()));
            EXPECT_EQ(dealerConnector->getDealerID(),
                      workload.substr(RESPONSE_MESSAGE_REFS[j].size()));
        }
    }
    return;
}

void ConnectorTest::routerMain(ReadMode read_mode)
{
    std::unique_ptr<Connector> routerConnector(
                Connector::getConnector(Connector::CONNECTOR_TYPE::ROUTER));

    routerConnector->setDealerID("B");
    ASSERT_TRUE(routerConnector->open(ADDRESS));

    const std::string REQ_REF("req");
    for (uint32_t i = 0; i < MAX_IDS * LOOP_COUNTER * REQUEST_MESSAGE_REFS.size(); ++i) {
        std::string message;
        if(read_mode == ReadMode::BLOCKING) {
            ASSERT_TRUE(routerConnector->read(message, read_mode));
        }
        else  {
            ASSERT_TRUE(nonBlockingReadPolling(routerConnector, message));
        }
        EXPECT_EQ(REQ_REF, message.substr(0, REQ_REF.size()));
        routerConnector->send("resp" + message.substr(REQ_REF.size()));
    }
}

void ConnectorTest::subscriberMain(const std::string &identity, ReadMode read_mode)
{
    std::unique_ptr<Connector> subscriberConnector(
                Connector::getConnector(Connector::CONNECTOR_TYPE::SUBSCRIBER));

    subscriberConnector->setDealerID(identity);
    ASSERT_TRUE(subscriberConnector->open(ADDRESS));

    int32_t index = -1;
    std::string messageOut;

    for (uint32_t i = 0; i < LOOP_COUNTER; ++i) {
        if(read_mode == ReadMode::BLOCKING) {
            ASSERT_TRUE(subscriberConnector->read(messageOut, read_mode));
        }
        else {
            ASSERT_TRUE(nonBlockingReadPolling(subscriberConnector, messageOut));
        }
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

void ConnectorTest::subscriberEmptyMain(const int32_t identities, ReadMode read_mode)
{
    std::unique_ptr<Connector> subscriberConnector(
                Connector::getConnector(Connector::CONNECTOR_TYPE::SUBSCRIBER));

    subscriberConnector->setDealerID("");
    ASSERT_TRUE(subscriberConnector->open(ADDRESS));

    int32_t index = -1;
    int32_t step = 0;

    std::string messageOut;

    while (true) {
        if(read_mode == ReadMode::BLOCKING) {
            ASSERT_TRUE(subscriberConnector->read(messageOut, read_mode));
        }
        else {
            ASSERT_TRUE(nonBlockingReadPolling(subscriberConnector, messageOut));
        }
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
        if(read_mode == ReadMode::BLOCKING) {
            ASSERT_TRUE(subscriberConnector->read(messageOut));
        }
        else  {
            ASSERT_TRUE(nonBlockingReadPolling(subscriberConnector, messageOut));
        }

        ASSERT_EQ(PUBLISHER_MESSAGE_REFS[static_cast<uint32_t>(index + (step++ / identities)) %
                PUBLISHER_MESSAGE_REFS.size()],
                messageOut);
    }
}

void ConnectorTest::publisherMain(const std::vector<std::string> &identities)
{
    std::unique_ptr<Connector> publisherConnector(
                Connector::getConnector(Connector::CONNECTOR_TYPE::PUBLISHER));

    for (const std::string& identity : identities) {
        publisherConnector->addSubscriber(identity);
    }
    ASSERT_TRUE(publisherConnector->open(ADDRESS));

    uint32_t i = 0;
    while (false == mStop_) {
        publisherConnector->send(PUBLISHER_MESSAGE_REFS[i++ % PUBLISHER_MESSAGE_REFS.size()]);
    }
}

void ConnectorTest::responseMain(ReadMode read_mode)
{
    std::unique_ptr<Connector> responseConnector(
                Connector::getConnector(Connector::CONNECTOR_TYPE::RESPONSE));

    ASSERT_TRUE(responseConnector->open(ADDRESS));

    std::string messageOut;

    for (uint32_t i = 0; i < LOOP_COUNTER; i++) {
        for (uint32_t index = 0; index < REQUEST_MESSAGE_REFS.size(); ++index) {
            if(read_mode == ReadMode::BLOCKING) {
                ASSERT_TRUE(responseConnector->read(messageOut, read_mode));
            }
            else {
                ASSERT_TRUE(nonBlockingReadPolling(responseConnector, messageOut));
            }

            ASSERT_EQ(messageOut, REQUEST_MESSAGE_REFS[index]);
            responseConnector->send(RESPONSE_MESSAGE_REFS[index]);
        }
    }
}

void ConnectorTest::requestMain(ReadMode read_mode)
{
    std::unique_ptr<Connector> requestConnector(
                Connector::getConnector(Connector::CONNECTOR_TYPE::REQUEST));

    ASSERT_TRUE(requestConnector->open(ADDRESS));

    std::string messageOut;

    for (uint32_t i = 0; i < LOOP_COUNTER; i++) {
        for (uint32_t index = 0; index < REQUEST_MESSAGE_REFS.size(); ++index) {
            requestConnector->send(REQUEST_MESSAGE_REFS[index]);
            if(read_mode == ReadMode::BLOCKING)  {
                ASSERT_TRUE(requestConnector->read(messageOut, read_mode));
            }
            else {
                ASSERT_TRUE(nonBlockingReadPolling(requestConnector, messageOut));
            }
            ASSERT_EQ(messageOut, RESPONSE_MESSAGE_REFS[index]);
        }
    }
}

void ConnectorTest::stop()
{
    mStop_ = true;
}

void ConnectorTest::SetUp()
{
}

void ConnectorTest::TearDown()
{
}
