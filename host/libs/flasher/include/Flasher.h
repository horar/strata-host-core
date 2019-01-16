/**
******************************************************************************
* @file Flasher.h
* @author Luay Alshawi
* $Rev: 1 $
* $Date: 2018-06-13 17:46:28 +0100 (Wed, 23 June 2018) $
* @brief Flasher header file.
******************************************************************************
* @copyright Copyright 2018 On Semiconductor
*
* @internal
*
* @endinternal
*
* @ingroup driver
*/

#ifndef Flasher_H_
#define Flasher_H_

#include <string>
#include <vector>
#include "Connector.h"
#include "bootloader_protocol.h"

#include "rapidjson/schema.h"
#include "rapidjson/document.h"


// #define FLASH_DEBUG
#define POOLING_COUNTER_LIMIT                   100
//#define SERIAL_CHUNK_LIMIT_SIZE                 64
#define BINARY_TEMP_OUTPUT_FILENAME             "output.bin"
class Flasher{

public:
  Flasher();
  Flasher(Connector* s);
  ~Flasher();

  Flasher(const Flasher&)=delete;
  Flasher& operator=(const Flasher&)=delete;

  bool flash(const std::string &filename);
  bool rollback(const std::string& filename);


  enum class RESPONSE_STATUS
  {
      NONE,
      NEXT_CHUNK,
      RESEND_CHUNK
  };

  bool processFirmwareInfoBlockCommand(int firmware_size, int checksum, int status);
  bool processFlashFirmwareCommand(int32_t chunkNumber, const std::vector<uint8_t>& chunkBuffer);
  bool processRollbackFirmwareCommand();

  bool writeFirmwareInfoBlockCommand(int firmware_size, int checksum, int status);
  bool writeFlashCommand(int32_t chunkNumber, const std::vector<uint8_t>& chunkBuffer);
  bool writeRollbackCommand(Flasher::RESPONSE_STATUS status);

private:

  char recieved_buffer_[ BUFFER_SIZE ];

  int32_t rawBytesChecksum(unsigned char *buffer, size_t length);
  int32_t getFileChecksum(const std::string &filname);
  int32_t isChecksumMatch(const std::string &filname_one, const std::string &filname_two);

  bool isPlatfromConnected();

  // Serial API
  bool write(const std::string& );
  int read();
  bool readAck(const std::string& ackName);
  bool readNotify(const std::string& notificationName, std::string& status);
  bool readNotifyRollback(const std::string& notificationName, std::string& status);

  static rapidjson::SchemaDocument createJsonSchema(const std::string& schema);
  static bool validateJsonMessage(const std::string& message, const rapidjson::SchemaDocument& schemaDocument, rapidjson::Document& document);

  static rapidjson::SchemaDocument ackJsonSchema;
  static rapidjson::SchemaDocument notifyJsonSchema;
  static rapidjson::SchemaDocument notifyRollbackJsonSchema;

  Connector *serial_;

  // Hold status if serial was initialized in the flasher
  bool can_deallocate_serial_;

  struct Chunk
  {
      int32_t number;

      enum class SIZE : uint32_t
      {
          DEFAULT = 256
      };
      std::vector<uint8_t> data;
  } chunk_;


};

#endif
