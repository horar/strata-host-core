#include "nimbus.h"
#include "base64.h"
#include "Connector.h"
#include <iostream>
#include <fstream>
// [TODO] [prasanth]
// Move all the following "KEY" to a config file
// This will break when we change the key value
#define PINGPONG_KEY    "test_string"
#define FILE_NAME_KEY   "filename"
#define DATA_KEY        "data"
#define COMMAND_KEY     "command"
#define REVISION_KEY    "revision"
#define SCHEMATIC_KEY   "schematic"
#define LAYOUT_KEY      "layout"
#define ASSEMBLY_KEY    "assembly"

#define DEBUG(...) printf("TEST: "); printf(__VA_ARGS__)

class AttachmentObserver : public Observer {
public:
    AttachmentObserver() {};
    AttachmentObserver(void *client_socket,void *client_id_list);

    void SyncStatusCallback(NimbusSyncInfo info) {
    }

    void ReplicationComplete() {
    };

    void DocumentChangeCallback(jsonString jsonBody);

    ~AttachmentObserver(){};
private:
    typedef std::list<std::string> clientList;
    clientList *client_list_;
    Connector *client_connector_;
};
