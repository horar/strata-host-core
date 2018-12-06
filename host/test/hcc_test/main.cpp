
#include <HostControllerClient.hpp>

#include <string>


const char* HOST_CONTROLLER_SERVICE_IN_ADDRESS = "tcp://127.0.0.1:5563";


int main(int argc, char* argv[])
{
    Spyglass::HostControllerClient client(HOST_CONTROLLER_SERVICE_IN_ADDRESS);

    std::string response;
    std::string msg("{ \"cmd\":\"platform_id_request\", \"payload\": { } }");

    client.sendCmd(msg);
    response = client.receiveNotification();


//    client.sendCmd("hksjghskdjfg\njkfghjkdsfhg\nkdfhgjdhsfgjk\n");
//   std::string response = client.receiveNotification();

    return 0;
}

