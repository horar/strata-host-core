/*!
 * Simple HostControllerClient Implementation
 * Cross-platform handling capability
 * Tested on Linux and Windows 64bit
 * Needs testing on Windows 32bit
 */

#include <future>
#include <iostream>
#include <string>

#include <rapidjson/document.h>
#include <rapidjson/error/en.h>
#include <zmq.hpp>
#include <zmq_addon.hpp>

using namespace std;
std::mutex coutMutex;

/*!
 * \brief : checks whether the received json over ZMQ_SUB is valid or not
 *          and increment the respective counter
 */
bool verifyJson(const string& received)
{
    //parse json
    rapidjson::Document jsonDoc;
    rapidjson::ParseResult result = jsonDoc.Parse(received.c_str());
    if (result.IsError()) {
        return false;
    } else {
        return true;
    }
}

void DealerThread(zmq::context_t *context) {
    //  Prepare dealer

    // dealer - messages not duplicates, only one will get them
    // publisher - it will duplicate the messages to all subscribers

    zmq::socket_t dealer(*context, zmq::socket_type::dealer);
    dealer.bind("inproc://#1");

    // Give the subscribers a chance to connect, so they don't lose any messages
    std::this_thread::sleep_for(std::chrono::milliseconds(20));

    for(int i = 0; i < 50; ++i) {
        {
            lock_guard<mutex> lock(coutMutex);
            cout << "Dealer: Sending Loop = " << i << endl;
        }
        //  Write three messages, each with an envelope and content
        dealer.send(zmq::str_buffer("ONSEMI A"), zmq::send_flags::sndmore);
        dealer.send(zmq::str_buffer("{\"cmd\":\"request_platform_id\",\"Host_OS\":\"Linux\"}"));
        dealer.send(zmq::str_buffer("ONSEMI B"), zmq::send_flags::sndmore);
        dealer.send(zmq::str_buffer("{\"cmd\":\"request_platform_id\",\"Host_OS\":\"Linux\"}"));
        dealer.send(zmq::str_buffer("ONSEMI C"), zmq::send_flags::sndmore);
        dealer.send(zmq::str_buffer("{\"cmd\":\"request_platform_id\",\"Host_OS\":\"Linux\"}"));
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }

    // send twice so all get the message
    dealer.send(zmq::str_buffer("ONSEMI A"), zmq::send_flags::sndmore);
    dealer.send(zmq::str_buffer("EXIT"));
    dealer.send(zmq::str_buffer("ONSEMI A"), zmq::send_flags::sndmore);
    dealer.send(zmq::str_buffer("EXIT"));
}

void SubscriberThread1(zmq::context_t *context) {
    //  Counter to keep track of valid and invalid jason
    int validJson = 0;
    int invalidJson = 0;

    //  Prepare subscriber
    zmq::socket_t subscriber(*context, zmq::socket_type::sub);
    subscriber.connect("inproc://#1");

    //  Subscriber Thread1 opens "ONSEMI A" and "ONSEMI B" envelopes
    subscriber.set(zmq::sockopt::subscribe, "ONSEMI A");
    subscriber.set(zmq::sockopt::subscribe, "ONSEMI B");

    while (1) {
        // Receive all parts of the message
        std::vector<zmq::message_t> recv_msgs;
        zmq::recv_result_t result =
                zmq::recv_multipart(subscriber, std::back_inserter(recv_msgs));
        assert(result && "recv failed");

        std::string iMessage = recv_msgs[1].to_string();
        if(iMessage == "EXIT")
            break;

        if (false == verifyJson(iMessage)) {
            ++invalidJson;
        } else {
            ++validJson;
        }

        {
            lock_guard<mutex> lock(coutMutex);
            std::cout << "Sub Thread1: [" << recv_msgs[0].to_string_view() << "] "
                      << recv_msgs[1].to_string_view() << std::endl;
        }
    }
    {
        lock_guard<mutex> lock(coutMutex);
        cout << "Valid Json Count Sub Thread1 = " << validJson << endl;
        cout << "InValid Json Count Sub Thread1 = " << invalidJson << endl;
    }
}

void SubscriberThread2(zmq::context_t *context) {
    //  Counter to keep track of valid and invalid jason
    int validJson = 0;
    int invalidJson = 0;

    //  Prepare our context and subscriber
    zmq::socket_t subscriber(*context, zmq::socket_type::sub);
    subscriber.connect("inproc://#1");

    //  Subscriber Thread2 opens ALL envelopes
    subscriber.set(zmq::sockopt::subscribe, "");

    while (1) {
        // Receive all parts of the message
        std::vector<zmq::message_t> recv_msgs;
        zmq::recv_result_t result =
                zmq::recv_multipart(subscriber, std::back_inserter(recv_msgs));
        assert(result && "recv failed");

        std::string iMessage = recv_msgs[1].to_string();
        if(iMessage == "EXIT")
            break;

        if (false == verifyJson(iMessage)) {
            ++invalidJson;
        } else {
            ++validJson;
        }

        {
            lock_guard<mutex> lock(coutMutex);
            std::cout << "Sub Thread2: [" << recv_msgs[0].to_string_view() << "] "
                      << recv_msgs[1].to_string_view() << std::endl;
        }
    }
    {
        lock_guard<mutex> lock(coutMutex);
        cout << "Valid Json Count Sub Thread2 = " << validJson << endl;
        cout << "InValid Json Count Sub Thread2 = " << invalidJson << endl;
    }
}

int main()
{
    cout << "Inicializing test" << endl;
    zmq::context_t context(0);

    auto thread1 = std::async(std::launch::async, DealerThread, &context);

    // Give the dealer a chance to connect
    std::this_thread::sleep_for(std::chrono::milliseconds(10));

    auto thread2 = std::async(std::launch::async, SubscriberThread1, &context);
    auto thread3 = std::async(std::launch::async, SubscriberThread2, &context);
    thread1.wait();
    thread2.wait();
    thread3.wait();

    cout << "Test ended" << endl;
}
