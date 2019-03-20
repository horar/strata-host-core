#include "HostControllerClient.hpp"

namespace Spyglass {

HostControllerClient::HostControllerClient(const char* net_in_address) : sendCmdSocket_(nullptr), notificationSocket_(nullptr)
{
    context_ = new zmq::context_t;

    notificationSocket_ = new zmq::socket_t(*context_, ZMQ_DEALER);

    notificationSocket_->connect(net_in_address);

}

HostControllerClient::~HostControllerClient()
{
    if (notificationSocket_) {
        notificationSocket_->close();
        delete notificationSocket_;
    }

    zmq_term(context_);
    delete context_;
}

} //namespace Spyglass