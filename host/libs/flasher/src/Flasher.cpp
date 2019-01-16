/**
 ******************************************************************************
 * @file Flasher.cpp
 * @author Luay Alshawi
 * $Rev: 1 $
 * $Date: 2018-06-13 17:46:28 +0100 (Wed, 23 June 2018) $
 * @brief Flasher API.
 ******************************************************************************
 * @copyright Copyright 2018 On Semiconductor
 *
 * @internal
 *
 * @endinternal
 *
 * @ingroup driver
 */
#include "Flasher.h"
#include <sstream>
#include <iostream>
#include <fstream>
#include <string.h>
#include <thread>// std::this_thread::sleep_for
#include <chrono>// std::chrono::seconds
#include <iomanip>// std::setfill, std::setw
#include "util.h"
#include <vector>
#include <numeric>

// rapidjson libraries
#include <rapidjson/schema.h>
#include <rapidjson/document.h>
#include <rapidjson/writer.h>
#include <rapidjson/stringbuffer.h>

#include "Base64.h"
using namespace std;
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

// {"notification":{"value":"write_fib","payload":{"status":"OK"}}}

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


// {"notification":{"value":"rollback","payload":{"chunk" : { "number":1 , "size" : 10, "crc" : 120, "data" : "abcdef" }, "status": "error" }}}
rapidjson::SchemaDocument Flasher::notifyRollbackJsonSchema( createJsonSchema(R"({
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


/** Flasher default Constructor.
 * @brief init SerialConnector and set can_delete_serial to true since serial initialized in the Flasher.
 */
Flasher::Flasher()
{
    serial_ = ConnectorFactory::getConnector("platform");
    can_deallocate_serial_ = true;
    cout << "Flasher: ctor" << endl;
}

Flasher::~Flasher()
{
    if(can_deallocate_serial_) {
        delete serial_;
    }
    cout << "Flasher: dtor" << endl;
}

/** Flasher setSerialConnector.
 * @brief Set SerialConnector
 * @param source The string to be converted to hex.
 */
Flasher::Flasher(Connector* s)
{
    serial_ = s;
    can_deallocate_serial_ = false;
}

/** Flasher write.
 * @brief Send data through SerialConnector.
 * @param data The data to be sent through serial.
 * @return true on success, false otherwise.
 */
bool Flasher::write(const string& data)
{
    return serial_->send(data);
}

/** Flasher read.
 * @brief Read data from serial using SerialConnector API.
 */
int Flasher::read()
{
    string read;
    serial_->read(read);

    // Clear recieved_buffer_ before writing
    memset(recieved_buffer_, 0, sizeof(recieved_buffer_));
    strcpy(recieved_buffer_, read.c_str());

    return static_cast<int>(read.size());
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

    printf("%s(%d) message: %s\n", __FILE__, __LINE__, message.c_str());

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

    std::cout << "readAck : " << payload["return_string"].GetString() << std::endl;

    return payload["return_value"].GetBool();
}

bool Flasher::readNotify(const std::string& notificationName, std::string& status)
{
    std::string message;

    serial_->read(message);

    printf("%s(%d) message: %s\n", __FILE__, __LINE__, message.c_str());
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

    status = notification["payload"]["status"].GetString();
    if (std::string("OK") != status)
    {
        std::cout << status << std::endl;

        return false;
    }

    return true;
}


/** Flasher writeFirmwareInfoBlock.
 * @brief Sends firmware info blcok to bootloader.
 * @param firmware_size The firmware size to be stored in the fib.
 * @param checksum The firmware checksum.
 * @param status The bootloader status.
 * @return true on success, false otherwise.
 */
bool Flasher::processFirmwareInfoBlockCommand(int firmware_size, int checksum, int status)
{
    std::string notificationStatus;

    return (writeFirmwareInfoBlockCommand(firmware_size, checksum, status) &&
            readAck("write_fib") &&
            readNotify("write_fib", notificationStatus));
}

/** Flasher writeFirmwareInfoBlock.
 * @brief Sends firmware info blcok to bootloader.
 * @param firmware_size The firmware size to be stored in the fib.
 * @param checksum The firmware checksum.
 * @param status The bootloader status.
 * @return true on success, false otherwise.
 */
bool Flasher::writeFirmwareInfoBlockCommand(int firmware_size, int checksum, int status)
{
    cout << "Sending checksum" << endl;

    StringBuffer s;
    Writer<StringBuffer> writer(s);

    writer.StartObject();

    writer.Key("cmd");                // output a key,
    writer.String("write_fib");             // follow by a value.

    writer.Key("payload");
    writer.StartObject();

    writer.Key("size");
    writer.Int(firmware_size);

    writer.Key("checksum");
    writer.Int(checksum);

    writer.Key("status");
    writer.Int(status);

    writer.EndObject();

    writer.EndObject();

    return write(s.GetString());
}


bool Flasher::processFlashFirmwareCommand(int32_t chunkNumber, const std::vector<uint8_t>& chunkBuffer)
{
    Flasher::RESPONSE_STATUS status(RESPONSE_STATUS::NEXT_CHUNK);
    std::string notificationStatus;

    int32_t errorCounter = 10;
    do
    {
        if (writeFlashCommand(chunkNumber, chunkBuffer) &&
            readAck("flash_firmware") &&
            readNotify("flash_firmware", notificationStatus))
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

bool Flasher::writeFlashCommand(int32_t chunkNumber, const std::vector<uint8_t>& chunkBuffer)
{
    std::string chunkBase64;
    chunkBase64.resize(base64::encoded_size(chunkBuffer.size()));
    base64::encode((void*)chunkBase64.data(), chunkBuffer.data(), chunkBuffer.size());

    StringBuffer s;
    Writer<StringBuffer> writer(s);

    writer.StartObject();

    writer.Key("cmd");                // output a key,
    writer.String("flash_firmware");             // follow by a value.

    writer.Key("payload");
    writer.StartObject();

    writer.Key("chunk");
    writer.StartObject();

    writer.Key("number");
    writer.Int(chunkNumber);

    writer.Key("size");
    writer.Int(static_cast<int>(chunkBuffer.size()));

    writer.Key("crc");
    writer.Int(std::accumulate(chunkBuffer.begin(), chunkBuffer.end(), 0));

    writer.Key("data");
    writer.String(chunkBase64.c_str(), static_cast<SizeType>(chunkBase64.length()));

    writer.EndObject();

    writer.EndObject();

    writer.EndObject();

    return write(s.GetString());
}

/** Flasher isPlatfromConnected.
 * @brief Wait for a platfrom to be connected and send firmware_update command to the platfrom's firmware.
 * @return true on success, false otherwise.
 */
bool Flasher::isPlatfromConnected()
{
    // Wait for a platfrom to be connected. Pooling!!!
    int pooling_counter = 0;
    while(!serial_->isSpyglassPlatform()){

        // Sleep for 100ms.
        std::this_thread::sleep_for (std::chrono::milliseconds(100));
        cout << "Waiting for a platfrom to be connected."<< endl;
        pooling_counter++;

        if(pooling_counter > POOLING_COUNTER_LIMIT){
            cout << "Could not connect to a platfrom. Exiting Flash function!"<< endl;
            return false;
        }
    }

    // Read dealer id after spyglass enabled platform was found
    if(serial_->getDealerID() == "Bootloader"){
        // Already in bootloader mode. Do nothing
        cout << "Platform in bootloader mode. Flashing Process is about to start." << endl;

    }
    else{
        // Fimrware update command to be sent to the platfrom core.
        string firmware_update_json = R"({'cmd':'firmware_update'})";
        // Enter bootloader mode.
        if(!write(firmware_update_json)){
            return false;
        }
        // Bootloader takes 5 seconds to start (known issue related to clock source). Platform and bootloader uses the same setting for clock source.
        // clock source for bootloader and application must match. Otherwise when application jumps to bootloader, it will have a hardware fault which requires board to be reset.
        std::this_thread::sleep_for (std::chrono::milliseconds(5500));
    }

    // Read response
    //KUC read();

    return true;
}


/** Flasher flash.
 * @brief Flash firmware to bootloader.
 * @param input_firmware The firmware path to be flashed to the bootloader.
 * @return true on success, false otherwise.
 */
bool Flasher::flash(const std::string &filename)
{
    // This is a blocking function and has a timeout.
    if (false == isPlatfromConnected())
    {
        return false;
    }

    // Open firmware file as read, binary only
    // On Windows binary must be stated explicitly
    FILE *file = fopen(filename.c_str(), "rb");
    if (file == nullptr)
    {
        cout << "Could not open firmware file " << filename << endl;
        return false;
    }

    //Calculate file size
    fseek(file, 0, SEEK_END);
    int32_t fsize = static_cast<int32_t>(ftell(file));
    fseek(file, 0, SEEK_SET);

    if (fsize <= 0)
    {
        // Return when the file is empty.
        return false;
    }

    // Write file size to the bootloader. Also, needed for the rollback since this is how much we are going to read.
    // In case the flashing process failed. The bootloader should stay in the bootloader mode. Since the flasher about to overwrite the firmware section.
    if (false == processFirmwareInfoBlockCommand(fsize, 0, FirmwareStatus::kNoFirmware))
    {
        return false;
    }

    // Send firmware data
    const size_t FLASH_CHUNK_SIZE = 256;
    std::vector<uint8_t> chunkBuffer(FLASH_CHUNK_SIZE);

    size_t totalSize = fsize;
    size_t chunkSize = 0;
    int32_t chunkNumber = 0;

    RESPONSE_STATUS status(RESPONSE_STATUS::NEXT_CHUNK);

    while (totalSize > 0)
    {
        chunkNumber++;
        if (totalSize < FLASH_CHUNK_SIZE)
        {
            chunkNumber = 0;    // the last chunk
        }

        chunkSize = fread(chunkBuffer.data(), 1, FLASH_CHUNK_SIZE, file);
        chunkBuffer.resize(chunkSize);

        totalSize -= chunkSize;

        if (false == processFlashFirmwareCommand(chunkNumber, chunkBuffer))
        {
            return false;
        }
    }

    // Close the firmware file.
    fclose(file);

    // Rollback and writes the read firmware to temp file "output.bin"
    rollback(filename + ".rb");

    // Compare flashed firmware and the read firmware checksum. Return 0 if both don't match.
    int checksum = isChecksumMatch(filename.c_str(), filename + ".rb");

    // Write the fib on positive chekcsum
    if(checksum > 0){
        // Write the final fib to the bootloader
        return writeFirmwareInfoBlockCommand(fsize,checksum,FirmwareStatus::kValidFirmware);
    }

    // Flashing the firmware failed
    return false;
}

/** Flasher rollback.
 * @brief Read existing firmware from bootloader and save it to a temporary file.
 * @param fsize The expected firmware size to be read from the bootloader.
 * @return total read bytes from the bootloader.
 */
bool Flasher::rollback(const std::string& filename)
{
    // saves data read from flash (platfrom) to this file
    FILE *rollbackFile = fopen(filename.c_str(), "wb");
    if (rollbackFile == nullptr)
    {
        cout << "Could not open debug_file file : " << filename << endl;
        return false;
    }

    do     // the last chunk
    {
        if (false == processRollbackFirmwareCommand())
        {
            return false;
        }

        fwrite(chunk_.data.data(), 1, chunk_.data.size(), rollbackFile);
    }
    while (0 != chunk_.number);

    fclose(rollbackFile);

    return true;

}

bool Flasher::writeRollbackCommand(Flasher::RESPONSE_STATUS status)
{
    cout << "writeRollbackCommand" << endl;

    StringBuffer s;
    Writer<StringBuffer> writer(s);

    writer.StartObject();

    writer.Key("cmd");
    writer.String("rollback_firmware");

    if (RESPONSE_STATUS::NONE != status)
    {
        writer.Key("payload");
        writer.StartObject();

        writer.Key("status");

        if (RESPONSE_STATUS::NEXT_CHUNK == status)
        {
            writer.String("OK");
        }
        else if (RESPONSE_STATUS::RESEND_CHUNK == status)
        {
            writer.String("resend_chunk");
        }

        writer.EndObject();
    }

    writer.EndObject();

    return write(s.GetString());
}

bool Flasher::readNotifyRollback(const std::string& notificationName, std::string& status)
{
    chunk_.data.clear();
    status.clear();

    std::string message;

    serial_->read(message);
printf("%s(%d) message: %s\n", __FILE__, __LINE__, message.c_str());
    Document document;

    if (false == validateJsonMessage(message, notifyRollbackJsonSchema, document))
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
        status = payload["status"].GetString();
        if (std::string("OK") != status)
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


bool Flasher::processRollbackFirmwareCommand()
{
    Flasher::RESPONSE_STATUS status(0 == chunk_.number ? RESPONSE_STATUS::NONE : RESPONSE_STATUS::NEXT_CHUNK);
    std::string notificationStatus;

    int32_t errorCounter = 10;
    do
    {
        if (writeRollbackCommand(status) &&
            readAck("rollback_firmware") &&
            readNotifyRollback("rollback_firmware", notificationStatus))
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


/** Flasher isChecksumMatch.
 * @brief Return the checksum if two files match the checksum, 0 otherwise
 * @param filname_one The firmware path.
 * @param filname_two The read firmware path.
 */
int32_t Flasher::isChecksumMatch(const std::string &filname_one, const std::string &filname_two)
{
    int32_t checksum_file_one = getFileChecksum(filname_one);
    int32_t checksum_file_two = getFileChecksum(filname_two);

    cout << "Firmware Checksum:" << checksum_file_one << endl;
    cout << "Read Back Firmware Checksum:" << checksum_file_two << endl;

    if(checksum_file_one > 0 && checksum_file_two > 0){
        if(checksum_file_one == checksum_file_two){
            return checksum_file_one;
        }
    }
    return 0;
}
/** Flasher rawBytesChecksum.
 * @brief Return the sum of given bytes.
 * @param buff The
 * @param length The lenght of the buff.
 */
int32_t Flasher::rawBytesChecksum(unsigned char *buffer, size_t length)
{
    int32_t sum;       // nothing gained in using smaller types!
    for ( sum = 0 ; length != 0 ; length-- ){
        sum += *(buffer++);   // parenthesis not required!
    }
    return sum;
}
/** Flasher getFileChecksum.
 * @brief Return the sum from the given binary file. Positive number for checksum, -1 for error.
 * @param filname The firmware path.
 */
int32_t Flasher::getFileChecksum(const std::string &filname)
{
    FILE * file;
    size_t file_size;
    uint8_t * buffer;
    size_t result;

    file = fopen ( filname.c_str() , "rb" );
    if (file == nullptr) {
        cout << "Could not open file " << filname << " to calculate the checksum."<< endl;
        return -1;
    }

    // Get file size:
    fseek (file , 0 , SEEK_END);
    file_size = static_cast<size_t>(ftell(file));
    rewind (file);

    // allocate memory to contain the whole file:
    buffer = new uint8_t[file_size];
    // Handel allocating error
    if (buffer == nullptr){
        return -1;
    }

    // Copy the file into the buffer:
    result = fread (buffer,1,file_size,file);
    if (result != file_size){
        return -1;
    }

    // Get file checksum
    int32_t sum = rawBytesChecksum(buffer,file_size);

    // Close the opened file
    fclose (file);
    // Free the buffer
    delete[] buffer;

    return sum;
}
