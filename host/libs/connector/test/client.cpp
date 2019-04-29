#include <iostream>
#include <string>
#include <zmq.hpp>
/*
int main()
{
    //  Prepare our context and socket
    zmq::context_t context(1);
    zmq::socket_t socket(context, ZMQ_REQ);

    std::cout << "Connecting to hello world server…" << std::endl;
    socket.connect("tcp://localhost:5556");

    //  Do 10 requests, waiting each time for a response
    for (int request_nbr = 0; request_nbr != 10; request_nbr++) {
        zmq::message_t request(5);
        memcpy(request.data(), "Hello", 5);
        std::cout << "Sending Hello " << request_nbr << "…" << std::endl;
        socket.send(request);

        //  Get the reply.
        zmq::message_t reply;
        socket.recv(&reply);
        std::cout << "Received World " << request_nbr << std::endl;
    }
    return 0;
}
*/
#include "zhelpers.hpp"

int main()
{
    //  Prepare our context and subscriber
    zmq::context_t context(1);
    zmq::socket_t subscriber(context, ZMQ_SUB);
    subscriber.connect("tcp://localhost:5555");
    subscriber.setsockopt(ZMQ_SUBSCRIBE, "B", 1);
/*
    while (1) {
        std::string address;   //  Read envelope with address
        std::string contents;  //  Read message contents
        if (s_recv(subscriber, address) && s_recv(subscriber, contents)) {
            std::cout << "[" << address << "] " << contents << std::endl;
        }
    }
*/
    return 0;
}
