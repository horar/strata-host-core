#include "nimbus.h"
#include "base64.h" 
#include "Connector.h"
#include <iostream>
#include <fstream>

#define PINGPONG_KEY    "test_string"
#define FILE_NAME_KEY   "filename"
#define DATA_KEY        "data"
#define COMMAND_KEY     "command"
#define REVISION_KEY    "revision"
#define SCHEMATIC_KEY   "schematic"
#define LAYOUT_KEY      "layout"
#define ASSEMBLY_KEY    "assembly"

#define DEBUG(...) printf("TEST: "); printf(__VA_ARGS__)
using namespace std;
using namespace rapidjson;

// TODO : ian : this is a duplicate structure with
//   HostControllerService.h struct host_packet
//   move to a common location
struct host_packet {
    zmq::socket_t* command;
    zmq::socket_t* notify;
    Connector *platform;
    Connector *service;
};

class AttachmentObserver : public Observer {
public:
    host_packet *host;
    AttachmentObserver() {};
    AttachmentObserver(void *hostP);
    void DocumentChange() {}
    void ReplicationComplete() {};
    void ValidateDocumentCallback(jsonString jsonBody);
    ~AttachmentObserver(){};
};

