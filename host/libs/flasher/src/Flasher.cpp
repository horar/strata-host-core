
#include "Flasher.h"

#include <thread>
#include <numeric>

#include <rapidjson/writer.h>
#include <rapidjson/stringbuffer.h>

#include "Connector.h"
#include "CodecBase64.h"


using namespace rapidjson;


// Schemas are gerenerated by https://www.liquid-technologies.com/online-json-to-schema-converter

// { "ack" : "<command_name>", "payload" : { "return_value" : <boolean>, "return_string" : "<string>" } }
rapidjson::SchemaDocument Flasher::ackJsonSchema( createJsonSchema(R"({
      "$schema": "http://json-schema.org/draft-04/schema#",
      "type": "object",
      "properties": {
        "ack": {
          "type": "string"
        },
        "payload": {
          "type": "object",
          "properties": {
            "return_value": {
              "type": "boolean"
            },
            "return_string": {
              "type": "string"
            }
          },
          "required": [
            "return_value",
            "return_string"
          ]
        }
      },
      "required": [
        "ack",
        "payload"
      ]
    })") );

// {"notification":{"value":"write_fib","payload":{"status":"ok"}}}
rapidjson::SchemaDocument Flasher::notifyJsonSchema( createJsonSchema(R"({
  "$schema": "http://json-schema.org/draft-04/schema#",
  "type": "object",
  "properties": {
    "notification": {
      "type": "object",
      "properties": {
        "value": {
          "type": "string"
        },
        "payload": {
          "type": "object",
          "properties": {
            "status": {
              "type": "string"
            }
          },
          "required": [
            "status"
          ]
        }
      },
      "required": [
        "value",
        "payload"
      ]
    }
  },
  "required": [
    "notification"
  ]
    })") );


// {"notification":{"value":"backup","payload":{"chunk" : { "number":1 , "size" : 10, "crc" : 120, "data" : "abcdef" }, "status": "error" }}}
rapidjson::SchemaDocument Flasher::notifyBackupJsonSchema( createJsonSchema(R"({
"$schema": "http://json-schema.org/draft-04/schema#",
"type": "object",
"properties": {
  "notification": {
    "type": "object",
    "properties": {
      "value": {
        "type": "string"
      },
      "payload": {
        "type": "object",
        "properties": {
          "chunk": {
            "type": "object",
            "properties": {
              "number": {
                "type": "integer"
              },
              "size": {
                "type": "integer"
              },
              "crc": {
                "type": "integer"
              },
              "data": {
                "type": "string"
              }
            },
            "required": [
              "number",
              "size",
              "crc",
              "data"
            ]
          },
          "status": {
            "type": "string"
          }
        }
      }
    },
    "required": [
      "value",
      "payload"
    ]
  }
},
"required": [
  "notification"
]
})") );


Flasher::Flasher()
: serial_(nullptr)
, firmwareFilename_()
{
}


Flasher::Flasher(Connector* connector, const std::string firmwareFilename)
: serial_(connector)
, firmwareFilename_(firmwareFilename)
{
}

Flasher::~Flasher()
{
}

void Flasher::setConnector(Connector* connector)
{
    serial_ = connector;
}

void Flasher::setFirmwareFilename(const std::string firmwareFilename)
{
    firmwareFilename_ = firmwareFilename;
}

SchemaDocument Flasher::createJsonSchema(const std::string& schemaJson)
{
    Document sd;
    if (sd.Parse(schemaJson.c_str()).HasParseError())
    {
        std::cout << "Invalid schema: " << schemaJson << std::endl;
    }
    return SchemaDocument(sd); // Compile a Document to SchemaDocument
}


bool Flasher::validateJsonMessage(const std::string& message, const rapidjson::SchemaDocument& schemaDocument, rapidjson::Document& document)
{
    if (document.Parse(message.c_str()).HasParseError())
    {
        std::cout << "Invalid document, parse error: " << message << std::endl;
        return false;
    }

    SchemaValidator validator(schemaDocument);

    if (!document.Accept(validator))
    {
        StringBuffer sb;
        validator.GetInvalidSchemaPointer().StringifyUriFragment(sb);
        std::cout << "Invalid schema: " << sb.GetString() << std::endl;
        std::cout << "Invalid keyword: " << validator.GetInvalidSchemaKeyword() << std::endl;
        sb.Clear();
        validator.GetInvalidDocumentPointer().StringifyUriFragment(sb);
        std::cout << "Invalid document: " << sb.GetString() << std::endl;

        return false;
    }

    return true;
}


bool Flasher::readAck(const std::string& ackName)
{
    std::string message;

    serial_->read(message);

    Document document;

    if (false == validateJsonMessage(message, ackJsonSchema, document))
    {
        return false;
    }

    if (ackName != document["ack"].GetString())
    {
        std::cout << "readAck : unknown ack" << document["ack"].GetString() << std::endl;

        return false;
    }

    Value& payload(document["payload"]);

    return payload["return_value"].GetBool();
}


bool Flasher::readNotify(const std::string& notificationName)
{
    std::string message;

    serial_->read(message);

    Document document;

    if (false == validateJsonMessage(message, notifyJsonSchema, document))
    {
        return false;
    }

    Value& notification(document["notification"]);

    if (notificationName != notification["value"].GetString())
    {
        return false;
    }

    std::string status = notification["payload"]["status"].GetString();
    if (std::string("ok") != status)
    {
        std::cout << status << std::endl;

        return false;
    }

    return true;
}


bool Flasher::processCommandFlashFirmware()
{
    Flasher::RESPONSE_STATUS status(RESPONSE_STATUS::NEXT_CHUNK);

    int32_t errorCounter = 10;
    do
    {
        if (writeCommandFlash() &&
            readAck("flash_firmware") &&
            readNotify("flash_firmware"))
        {
            status = RESPONSE_STATUS::NEXT_CHUNK;
        }
        else
        {
            status = RESPONSE_STATUS::RESEND_CHUNK;
        }

        if (0 == --errorCounter)
        {
            return false;
        }
    }
    while (RESPONSE_STATUS::RESEND_CHUNK == status);

    return true;
}


bool Flasher::writeCommandFlash()
{
    StringBuffer s;
    Writer<StringBuffer> writer(s);

    writer.StartObject();

    writer.Key("cmd");                // output a key,
    writer.String("flash_firmware");  // follow by a value.

    writer.Key("payload");
    writer.StartObject();

    writer.Key("chunk");
    writer.StartObject();

    writer.Key("number");
    writer.Int(chunk_.number);

    writer.Key("size");
    writer.Int(static_cast<int>(chunk_.data.size()));

    writer.Key("crc");
    writer.Int(std::accumulate(chunk_.data.begin(), chunk_.data.end(), 0));

    std::string chunkBase64;
    chunkBase64.resize(base64::encoded_size(chunk_.data.size()));
    base64::encode((void*)chunkBase64.data(), chunk_.data.data(), chunk_.data.size());

    writer.Key("data");
    writer.String(chunkBase64.c_str(), static_cast<SizeType>(chunkBase64.length()));

    writer.EndObject();

    writer.EndObject();

    writer.EndObject();

    return serial_->send(s.GetString());
}


bool Flasher::isPlatfromConnected()
{
    // Wait for a platfrom to be connected. Pooling!!!
    const int POOLING_COUNTER_LIMIT = 100;
    int pooling_counter = 0;
    while(!serial_->isSpyglassPlatform()){

        // Sleep for 100ms.
        std::this_thread::sleep_for (std::chrono::milliseconds(100));
        std::cout << "Waiting for a platfrom to be connected."<< std::endl;
        pooling_counter++;

        if(pooling_counter > POOLING_COUNTER_LIMIT){
            std::cout << "Could not connect to a platfrom. Exiting Flash function!"<< std::endl;
            return false;
        }
    }

    // Read dealer id after spyglass enabled platform was found
    if(serial_->getDealerID() == "Bootloader"){
        // Already in bootloader mode. Do nothing
        std::cout << "Platform in bootloader mode. Flashing Process is about to start." << std::endl;

    }
    else{
        // Fimrware update command to be sent to the platfrom core.
        // Enter bootloader mode.
        if(!serial_->send(R"({'cmd':'firmware_update'})")){
            return false;
        }
        // Bootloader takes 5 seconds to start (known issue related to clock source). Platform and bootloader uses the same setting for clock source.
        // clock source for bootloader and application must match. Otherwise when application jumps to bootloader, it will have a hardware fault which requires board to be reset.
        std::this_thread::sleep_for (std::chrono::milliseconds(5500));
    }

    return true;
}


bool Flasher::flash(bool forceStartApplication)
{
    // This is a blocking function and has a timeout.
    if (false == isPlatfromConnected())
    {
        return false;
    }

    //Calculate file size
    int32_t firmwareSize = getFileSize(firmwareFilename_);

    if (firmwareSize == 0)
    {
        return false;
    }

    // Open firmware file as read, binary only
    FILE *firmwareFile = fopen(firmwareFilename_.c_str(), "rb");
    if (firmwareFile == nullptr)
    {
        std::cout << "Could not open firmware file " << firmwareFilename_ << std::endl;
        return false;
    }

    // Send firmware data
    chunk_.number = 0;
    chunk_.data.resize(static_cast<int32_t>(Chunk::SIZE::DEFAULT));

    while (firmwareSize > 0)
    {
        chunk_.number++;
        if (firmwareSize < static_cast<int32_t>(Chunk::SIZE::DEFAULT))
        {
            chunk_.number = 0;    // the last chunk
        }

        chunk_.data.resize(fread(chunk_.data.data(), 1, static_cast<int32_t>(Chunk::SIZE::DEFAULT), firmwareFile));

        firmwareSize -= chunk_.data.size();

        if (false == processCommandFlashFirmware())
        {
            fclose(firmwareFile);
            return false;
        }
    }

    fclose(firmwareFile);

    return backup() && verify() && (forceStartApplication ? startApplication() : true);
}


bool Flasher::backup()
{
    const std::string& backupFilename(firmwareFilename_ + ".bak");

    FILE *backupFile = fopen(backupFilename.c_str(), "wb");
    if (backupFile == nullptr)
    {
        std::cout << "Could not open backup file : " << backupFilename << std::endl;
        return false;
    }

    chunk_.number = 0;
    chunk_.data.clear();

    do
    {
        if (false == processCommandBackupFirmware())
        {
            fclose(backupFile);
            return false;
        }

        fwrite(chunk_.data.data(), 1, chunk_.data.size(), backupFile);
    }
    while (0 != chunk_.number);     // the last chunk

    fclose(backupFile);
    return true;

}


bool Flasher::writeCommandStartApplication()
{
    StringBuffer s;
    Writer<StringBuffer> writer(s);

    writer.StartObject();

    writer.Key("cmd");
    writer.String("start_application");

    writer.EndObject();

    return serial_->send(s.GetString());
}

bool Flasher::processCommandStartApplication()
{
    std::string notificationStatus;

    for (int32_t errorCounter = 10; 0 != errorCounter; --errorCounter)
    {
        if (writeCommandStartApplication() &&
            readAck("start_application") &&
            readNotify("start_application"))
        {
            return true;
        }
    }

    return false;
}

bool Flasher::startApplication()
{
    return processCommandStartApplication();
}

bool Flasher::verify() const
{
    const std::string& backupFilename(firmwareFilename_ + ".bak");

    const int32_t firmwareSize = getFileSize(firmwareFilename_);
    const int32_t backupSize = getFileSize(backupFilename);

    if (firmwareSize != backupSize)
    {
        return false;
    }

    const int32_t firmwareChecksum = getFileChecksum(firmwareFilename_);
    const int32_t backupChecksum = getFileChecksum(backupFilename);

    std::cout << "Firmware Checksum:" << firmwareChecksum << std::endl;
    std::cout << "Read Back Firmware Checksum:" << backupChecksum << std::endl;

    return (firmwareChecksum == backupChecksum && -1 != firmwareChecksum);
}


bool Flasher::writeCommandBackup(Flasher::RESPONSE_STATUS status)
{
    StringBuffer s;
    Writer<StringBuffer> writer(s);

    writer.StartObject();

    writer.Key("cmd");
    writer.String("backup_firmware");

    if (RESPONSE_STATUS::NONE != status)
    {
        writer.Key("payload");
        writer.StartObject();

        writer.Key("status");

        if (RESPONSE_STATUS::NEXT_CHUNK == status)
        {
            writer.String("ok");
        }
        else if (RESPONSE_STATUS::RESEND_CHUNK == status)
        {
            writer.String("resend_chunk");
        }

        writer.EndObject();
    }

    writer.EndObject();

    return serial_->send(s.GetString());
}


bool Flasher::writeCommandReadFib()
{
    StringBuffer s;
    Writer<StringBuffer> writer(s);

    writer.StartObject();

    writer.Key("cmd");
    writer.String("read_fib");

    writer.EndObject();

    return serial_->send(s.GetString());
}


bool Flasher::readNotifyBackup(const std::string& notificationName)
{
    chunk_.data.clear();

    std::string message;
    serial_->read(message);

    Document document;

    if (false == validateJsonMessage(message, notifyBackupJsonSchema, document))
    {
        return false;
    }

    Value& notification(document["notification"]);

    if (notificationName != notification["value"].GetString())
    {
        return false;
    }


    Value& payload(notification["payload"]);

    if (payload.HasMember("status"))
    {
        std::string status(payload["status"].GetString());
        if (std::string("ok") != status)
        {
            std::cout << status << std::endl;

            return false;
        }
        return true;
    }
    else if (payload.HasMember("chunk"))
    {
        Value& chunk(payload["chunk"]);

        chunk_.number = chunk["number"].GetInt();
        uint32_t size = chunk["size"].GetUint();
        uint32_t crc = chunk["crc"].GetUint();
        std::string chunkBase64 = chunk["data"].GetString();

        chunk_.data.resize(base64::decoded_size(chunkBase64.size()));
        chunk_.data.resize(base64::decode(chunk_.data.data(), chunkBase64.data(), chunkBase64.size()).first);

        if (size != chunk_.data.size() ||
            crc != std::accumulate(chunk_.data.begin(), chunk_.data.end(), 0U))
        {
            return false;
        }
    }

    return true;
}


bool Flasher::processCommandBackupFirmware()
{
    Flasher::RESPONSE_STATUS status(0 == chunk_.number ? RESPONSE_STATUS::NONE : RESPONSE_STATUS::NEXT_CHUNK);

    int32_t errorCounter = 10;
    do
    {
        if (writeCommandBackup(status) &&
            readAck("backup_firmware") &&
            readNotifyBackup("backup_firmware"))
        {
            status = RESPONSE_STATUS::NEXT_CHUNK;
        }
        else
        {
            status =  RESPONSE_STATUS::RESEND_CHUNK;
        }

        if (0 == --errorCounter)
        {
            return false;
        }
    }
    while (RESPONSE_STATUS::RESEND_CHUNK == status);

    return true;
}


int32_t Flasher::getFileChecksum(const std::string &filname) const
{
    FILE * file = fopen ( filname.c_str() , "rb" );

    if (file == nullptr) {
        std::cout << "Could not open file " << filname << " to calculate the checksum."<< std::endl;
        return -1;
    }

    int32_t sum = 0;
    for (int32_t c = 0; c != EOF; c = getc (file))
    {
        sum += c;
    }

    fclose (file);

    return sum;
}

int32_t Flasher::getFileSize(const std::string &fileName) const
{
    FILE *file = fopen(fileName.c_str(), "rb");
    if (file == nullptr)
    {
        std::cout << "Could not open firmware file " << fileName << std::endl;
        return 0;
    }

    //Calculate file size
    fseek(file, 0, SEEK_END);
    int32_t firmwareSize = static_cast<int32_t>(ftell(file));
    fseek(file, 0, SEEK_SET);

    if (firmwareSize <= 0)
    {
        fclose(file);
        return 0;
    }
    return firmwareSize;
}
