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
#include "Connector.h"
#include "bootloader_protocol.h"



// #define FLASH_DEBUG
#define POOLING_COUNTER_LIMIT                   100
#define SERIAL_CHUNK_LIMIT_SIZE                 64
#define BINARY_TEMP_OUTPUT_FILENAME             "output.bin"
class Flasher{

public:
  Flasher();
  Flasher(Connector* s);
  ~Flasher();

  int flash(const std::string &input_firmware);
  unsigned int rollback(unsigned int);
  int writeFirmwareInfoBlock(unsigned int firmware_size, unsigned int checksum, unsigned int status);

private:
  char recieved_buffer_[ BUFFER_SIZE ];

  uint32_t rawBytesChecksum(unsigned char *buffer, size_t length);
  uint32_t getFileChecksum(const std::string &filname);
  uint32_t isChecksumMatch(const std::string &filname_one, const std::string &filname_two);

  bool isPlatfromConnected();

  // Serial API
  bool write(const std::string& );
  int read();

  Connector *serial_;

  // Hold status if serial was initialized in the flasher
  bool can_deallocate_serial_;

  Flasher(const Flasher&)=delete;
  Flasher& operator=(const Flasher&)=delete;

};

#endif
