

//  Framework Libraries
#include "nimbus.h"
#include "zhelpers.hpp"
#include "zmq.hpp"
#include "zmq_addon.hpp"
#include "base64.h"
#include "Observer.h"
//  Standard Libraries
#include <string>
#include <iostream>
#include <unistd.h>
#include <chrono>
#include <fstream>

void ParseJSON_Rev1(jsonString jsonBody) {
    jsonDocument        jDoc;
    std::ofstream       output_file;

    char   full_path[100];
    char   path[] = "./test/";
    const char*   filename;
    const char*   data;


    jDoc.Parse( jsonBody );

    // Attempt to parse document
    if ( jDoc.HasParseError() ) {
        DEBUG("JSON Parse failed: %u.\n", jDoc.GetParseError());
        return;
    }

    // Look for "command" key
    if ( !jDoc.HasMember(COMMAND_KEY) ) {
        DEBUG("No command found\n.");
        return;
    }
    else {
        DEBUG("Found command: %s\n", jDoc[COMMAND_KEY].GetString());
    }

    // Look for Schematic key; skip if not there
    if ( !jDoc.HasMember(SCHEMATIC_KEY) ) {
        DEBUG("No schematic files found\n.");
    }
    else if (jDoc[SCHEMATIC_KEY].IsArray()) {
        DEBUG("Found schematic files:\n");
        const rapidjson::Value& file_array = jDoc[SCHEMATIC_KEY].GetArray();
        for (SizeType i = 0; i < file_array.Size(); i++) {
            auto file_obj = file_array[i].GetObject();
            DEBUG("is object is %s\n", (file_obj[FILE_NAME_KEY].GetString()));
        }
    }

    // Look for layout key; skip if not there
    if ( !jDoc.HasMember(LAYOUT_KEY) ) {
        DEBUG("No layout files found\n.");
    }
    else if (jDoc[LAYOUT_KEY].IsArray()) {
        DEBUG("Found layout files:\n");
        const rapidjson::Value& file_array = jDoc[LAYOUT_KEY].GetArray();
        for (SizeType i = 0; i < file_array.Size(); i++) {
            auto file_obj = file_array[i].GetObject();
            DEBUG("is object is %s\n", (file_obj[FILE_NAME_KEY].GetString()));
        }
    }
// Look for assembly key; skip if not there
    if ( !jDoc.HasMember(ASSEMBLY_KEY) ) {
        DEBUG("No assembly files found\n.");
    }
    else if (jDoc[ASSEMBLY_KEY].IsArray()) {
        DEBUG("Found assembly files:\n");

        const rapidjson::Value& file_array = jDoc[ASSEMBLY_KEY].GetArray();

        for (SizeType i = 0; i < file_array.Size(); i++) {
            auto file_obj = file_array[i].GetObject();
            DEBUG("is object is %s\n", (file_obj[FILE_NAME_KEY].GetString()));
            // Example of taking files and outputing to file
            if (file_obj.HasMember(DATA_KEY)) {
                DEBUG("Decoding file.\n");
                data = file_obj[DATA_KEY].GetString();

                // Decode with base64
                string data_string = data;
                string data_binary = base64_decode(data_string);

                // Write to file
                filename = file_obj[FILE_NAME_KEY].GetString();
                snprintf(full_path, sizeof(full_path), "%s%s", path, filename);
                DEBUG("Writing to file %s\n", filename);
                output_file.open(full_path, std::ofstream::out);
                output_file << data_binary;
                output_file.close();
            }
            else {
                DEBUG("No data found\n.");
            }
        }
    }

    return;

    string data_string = data;
    string data_binary;
    data_binary = base64_decode(data_string);

    // Write to file
    snprintf(full_path, sizeof(full_path), "%s%s", path, filename);
    DEBUG("Writing to file %s", filename);
    output_file.open(full_path, std::ofstream::out);
    output_file << data_binary;
    output_file.close();
}


void ParseJSON(int revision, jsonString jsonBody) {

      
        switch (revision) {

            case 0: {
                jsonDocument jDoc;
                //Nimbus::NimbusError error;
                std::ofstream   output_file;

                char   full_path[100];
                char   path[] = "/context/data/";
                char*   filename;
                char*   data;

                //DEBUG("%s", jsonBody);
                jDoc.Parse( jsonBody );

                // Attempt to parse document
                if ( jDoc.HasParseError() ) {
                    DEBUG("JSON Parse failed: %u.\n", jDoc.GetParseError());
                    return;
                }

                // Look for "image" key
                if ( !jDoc.HasMember("type") ) {
                    DEBUG("No type found\n.");
                    return;
                }
                else {
                    DEBUG("Found type: %s\n", jDoc["type"].GetString());
                }

                // Look for filename key
                if ( !jDoc.HasMember("file") ) {
                    DEBUG("No filename found\n.");
                    return;
                }
                else {
                    filename = (char*)jDoc["file"].GetString();
                    DEBUG("Found filename %s\n", filename );
                }

                if ( !jDoc.HasMember("data") ) {
                    DEBUG("No base64 data found\n.");
                    return;
                }
                else {
                    data = (char*)jDoc["data"].GetString();
                    DEBUG("Found data %u\n", jDoc["data"].GetStringLength());
                }

                string data_string = data;
                string data_binary;
                data_binary = base64_decode(data_string);

                // Write to file
                snprintf(full_path, sizeof(full_path), "%s%s", path, filename);
                DEBUG("Writing to file %s", filename);
                output_file.open(full_path, std::ofstream::out);
                output_file << data_binary;
                output_file.close();
                break;
            }
            case 1: {
                ParseJSON_Rev1(jsonBody);
                break;
            }
            default:
            DEBUG("Unknown revision type.");
        }
}
    


int main()
{
	zmq::context_t context;
	zmq::socket_t socket(context, ZMQ_SUB);
	socket.connect("tcp://127.0.0.1:5563");
    socket.setsockopt(ZMQ_SUBSCRIBE,"",0);
	jsonDocument jDoc;
    int revision = 0;

	while(1) {		
		zmq::message_t reply;
        DEBUG("Before receive\n");
        #if 0 
		int n = socket.recv(&reply);
		DEBUG("Received %d\n",n);
		std::string jsonBody_string =
		   	std::string(static_cast < char *>(reply.data()),
				reply.size());
        #endif
        s_recv(socket);
        std::string jsonBody_string = s_recv(socket);
#if 1
		const char* jsonBody = jsonBody_string.c_str();

		jDoc.Parse( jsonBody );
        if (jDoc.HasParseError() ) {
            DEBUG("Received JSON has parsing issues. Skipping.\n");
        }

        // Lets peek at the revision and parse it
        if ( !jDoc.HasMember(REVISION_KEY)) {
            DEBUG("Found no revision in JSON. Assuming Rev 0\n");
            revision = 0;
        }
        else {
            revision = jDoc[REVISION_KEY].GetInt();
            DEBUG("Found revision %u\n", revision);
        }
        ParseJSON(revision, jsonBody);
#endif
	}
	return 0;
}
