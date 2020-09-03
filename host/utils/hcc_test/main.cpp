#include <HostControllerClient.hpp>

#include <string>


const char* HOST_CONTROLLER_SERVICE_IN_ADDRESS = "tcp://127.0.0.1:5563";

strata::hcc::HostControllerClient* hcc = nullptr;

int send_register_client()
{
    const std::string msg("{ \"cmd\":\"register_client\" }");

    hcc->sendCmd(msg);
//    std::string response = hcc->receiveNotification();

    return 0;
}

int send_unregister_client()
{
    const std::string msg("{ \"hcs::cmd\":\"unregister\" }");

    hcc->sendCmd(msg);
//    std::string response = hcc->receiveNotification();

    return 0;
}

int send_load_documents()
{
    const std::string msg(  "{ \"cmd\":\"load_documents\", \"payload\":" \
                            " { \"class_id\":\"P2.2017.1.1.0.0.cbde0519-0f42-4431-a379-caee4a1494af\" } " \
                            "}" );

    hcc->sendCmd(msg);
    std::string response = hcc->receiveNotification();

    return 0;
}

int main(int, char*[])
{
    int ret;
    strata::hcc::HostControllerClient client(HOST_CONTROLLER_SERVICE_IN_ADDRESS);

    //connect ??

    hcc = &client;
    ret = send_register_client();
    ret = send_register_client();
    ret = send_register_client();

    ret = send_unregister_client();



//    std::string response;
//    std::string msg("{ \"cmd\":\"platform_id_request\", \"payload\": { } }");

//    client.sendCmd(msg);
//    response = client.receiveNotification();


//    client.sendCmd("hksjghskdjfg\njkfghjkdsfhg\nkdfhgjdhsfgjk\n");
//   std::string response = client.receiveNotification();

    return 0;
}

