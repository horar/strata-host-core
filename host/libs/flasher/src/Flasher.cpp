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
using namespace std;


/** Flasher default Constructor.
* @brief init SerialConnector and set can_delete_serial to true since serial initialized in the Flasher.
*/
Flasher::Flasher(){
  serial_ = new SerialConnector();
  can_deallocate_serial_ = true;
  cout << "Flasher: ctor" << endl;
}
Flasher::~Flasher(){
  if(can_deallocate_serial_){
    delete serial_;
  }
  cout << "Flasher: dtor" << endl;

}

/** Flasher setSerialConnector.
* @brief Set SerialConnector
* @param source The string to be converted to hex.
*/
Flasher::Flasher(const SerialConnector *s){
  serial_ = (SerialConnector *)s;
  can_deallocate_serial_ = false;
}

/** Flasher write.
* @brief Send data through SerialConnector.
* @param data The data to be sent through serial.
* @return true on success, false otherwise.
*/
bool Flasher::write(string data){
  return serial_->send(data);
}

/** Flasher read.
* @brief Read data from serial using SerialConnector API.
*/
int Flasher::read(){
  string read;
  serial_->read(read);

  // Clear recieved_buffer_ before writing
  memset(recieved_buffer_, 0, sizeof(recieved_buffer_));
  strcpy(recieved_buffer_, read.c_str());

  return read.size();
}
/** Flasher writeFirmwareInfoBlock.
* @brief Sends firmware info blcok to bootloader.
* @param firmware_size The firmware size to be stored in the fib.
* @param checksum The firmware checksum.
* @param status The bootloader status.
* @return true on success, false otherwise.
*/
int Flasher::writeFirmwareInfoBlock(unsigned int firmware_size, unsigned int checksum, unsigned int status){

  cout << "Sending checksum" << endl;
  struct FirmwareInformationBlock firmware_information_block;
  char send_buffer[ 2*sizeof(firmware_information_block) +1 ];
  char raw_buffer[ (sizeof(firmware_information_block)) +1];

  firmware_information_block.command_header.cmd = Command::kSetFirmwareInfoBlcok;
  firmware_information_block.command_header.pad = 0;
  firmware_information_block.firmware_metadata.firmware_size = firmware_size;
  firmware_information_block.firmware_metadata.checksum = checksum;
  firmware_information_block.firmware_metadata.firmware_status = status;

  memcpy(raw_buffer, &firmware_information_block, sizeof(firmware_information_block));

  convertRawStringToHexString(raw_buffer,sizeof(firmware_information_block),send_buffer);

  return write(send_buffer);

}
/** Flasher isPlatfromConnected.
* @brief Wait for a platfrom to be connected and send firmware_update command to the platfrom's firmware.
* @return true on success, false otherwise.
*/
bool Flasher::isPlatfromConnected(){
  // Fimrware update command to be sent to the platfrom core.
  string firmware_update_json = R"({'cmd':'firmware_update'})";
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

  }else{
    // Enter bootloader mode.
    if(!write(firmware_update_json)){
      return false;
    }
    // Bootloader takes 5 seconds to start (known issue related to clock source). Platform and bootloader uses the same setting for clock source.
    // clock source for bootloader and application must match. Otherwise when application jumps to bootloader, it will have a hardware fault which requires board to be reset.
    std::this_thread::sleep_for (std::chrono::milliseconds(5500));
  }

  // Read response
  read();

  return true;
}
/** Flasher flash.
* @brief Flash firmware to bootloader.
* @param input_firmware The firmware path to be flashed to the bootloader.
* @return true on success, false otherwise.
*/
int Flasher::flash(const std::string &input_firmware){

  // This is a blocking function and has a timeout.
  bool res = isPlatfromConnected();
  if(!res){
    return 0;
  }

  unsigned long fsize, fsize_temp,read_size;
  char file_read_buffer[FLASH_SECTOR_SIZE];
  struct Flash flash;
  char send_buffer[ 2*sizeof(flash) ];
  char raw_buffer[ (sizeof(flash)) ];
  int sector_id = 0;

  // Open firmware file as read, binary only
  // On Windows binary must be stated explicitly
  FILE *file = fopen(input_firmware.c_str(), "rb");
  if (file == NULL){
		cout << "Could not open firmware file " << input_firmware << endl;
		return 0;
	}

  //Calculate file size
	fseek(file, 0, SEEK_END);
	fsize = ftell(file);
	fseek(file, 0, SEEK_SET);

  fsize_temp = fsize;

  if(fsize > 0){
    // Write file size to the bootloader. Also, needed for the rollback since this is how much we are going to read.
    // In case the flashing process failed. The bootloader should stay in the bootloader mode. Since the flasher about to overwrite the firmware section.
    writeFirmwareInfoBlock(fsize,0,FirmwareStatus::kNoFirmware);
    std::this_thread::sleep_for (std::chrono::milliseconds(500));
#ifdef FLASH_DEBUG
    read();
    std::this_thread::sleep_for (std::chrono::milliseconds(500));
    read();
    std::this_thread::sleep_for (std::chrono::milliseconds(500));
    read();
#endif
  }else{
    // Return when the file is empty.
    return 0;
  }

  // Send firmware data sector by sector
  while( fsize_temp > 0 ){

    read_size = fread(file_read_buffer, 1, sizeof(file_read_buffer), file);

    if (read_size <= 0){
			break;
		}

    // Set the data struct values
    flash.command_header.cmd = Command::kFlashFirmware;
    flash.command_header.pad = 0;

    flash.binary.sector_id = sector_id;
    flash.binary.bytes_count = read_size;

    // Copy read data to bin_data
    memcpy(flash.binary.binary_data, &file_read_buffer, sizeof(file_read_buffer));

    // Copy the struct data to a buffer of char
    memcpy(raw_buffer, &flash, sizeof(flash));

    // Encode the raw buffer to Hex String format
    convertRawStringToHexString(raw_buffer,sizeof(flash),send_buffer);

    // Send small chunks of data
    serial_->sendSmallChunks(send_buffer, SERIAL_CHUNK_LIMIT_SIZE);

    this_thread::sleep_for (std::chrono::milliseconds(100));

#ifdef FLASH_DEBUG
      std::this_thread::sleep_for (std::chrono::milliseconds(50));
      read();
#endif

    // Decrement fsize_temp since it is used to stop this loop. Trying to make this to be 0
    fsize_temp -= read_size;

    // Increment the sector id to indicates the sector number that we want to write the data to in the flash memory.
    sector_id++;
  }

  // Close the firmware file.
  fclose(file);

#ifdef FLASH_DEBUG
    read();
    std::this_thread::sleep_for (std::chrono::milliseconds(500));
#endif
  std::this_thread::sleep_for (std::chrono::milliseconds(1000));
  // Rollback and writes the read firmware to temp file "output.bin"
  rollback(fsize);

  // Compare flashed firmware and the read firmware checksum. Return 0 if both don't match.
  unsigned int checksum = isChecksumMatch((char *)input_firmware.c_str(), BINARY_TEMP_OUTPUT_FILENAME);

  // Write the fib on positive chekcsum
  if(checksum > 0){
    // Write the final fib to the bootloader
    return writeFirmwareInfoBlock(fsize,checksum,FirmwareStatus::kValidFirmware);
  }

  // Flashing the firmware failed
  return false;
}

/** Flasher rollback.
* @brief Read existing firmware from bootloader and save it to a temporary file.
* @param fsize The expected firmware size to be read from the bootloader.
* @return total read bytes from the bootloader.
*/
// TODO: rollback should be a stand alone and should get firmware size from the bootloader.
unsigned int Flasher::rollback(unsigned int fsize){

  // saves data read from flash (platfrom) to this file
  FILE *debug_file = fopen(BINARY_TEMP_OUTPUT_FILENAME, "wb");
  if (debug_file == NULL){
		cout << "Could not open debug_file file" << endl;
		return 0;
	}

  struct CommandHeader command_header;
  struct Flash flash;

  // Number of secters expected to recieve plus 30, since serial buffer might return wrong data in windows and thus needs to read more.
  int loop_max_limit = (fsize / FLASH_SECTOR_SIZE) + 30;
  int loop_counter = 0;
  int serial_receive_size = 0;
  int total_read_bytes = 0;
  int binary_bytes_count = 0;
  int read_tries_count = 0;
  char buffer[BUFFER_SIZE];
  char raw_buffer[sizeof(flash)];

  command_header.cmd = Command::kRollback;
  command_header.pad = 0;

  memcpy(raw_buffer, &command_header, sizeof(command_header));
  convertRawStringToHexString(raw_buffer,sizeof(command_header), buffer);

  serial_->sendSmallChunks(buffer, SERIAL_CHUNK_LIMIT_SIZE);

#ifdef FLASH_DEBUG
      read();
      std::this_thread::sleep_for (std::chrono::milliseconds(500));
#endif

  /*
  * This loop exits in two cases:
  * 1. When flasher recevied all bytes expected from bootloader.
  * 2. When the loop reached its limit by receiving non rollback realted data.
  */
  while ( (total_read_bytes < fsize) && (loop_counter < loop_max_limit) ) {

    /*
      Tries to read 100 times, 10ms delay each time.
      Solves windows and linux inconsistency read issues after sending rollback command.
    */
    read_tries_count = 0;
    do{
      std::this_thread::sleep_for (std::chrono::milliseconds(10));
      serial_receive_size = read();
      read_tries_count++;
      if(read_tries_count > 100){
        cout << "Serial read limit reached." << endl;
        fclose(debug_file);
        return 0;
      }
    }while(serial_receive_size==0);

    // Decode recieved data to raw bytes
    convertHexStringToRawString(recieved_buffer_,sizeof(flash), raw_buffer);

    memcpy(&flash,raw_buffer,sizeof(flash));

    binary_bytes_count = flash.binary.bytes_count;

    // Check if recevied data coming from rollback command
    if(flash.command_header.cmd == Command::kRollback){
      cout << "sector_id:" << flash.binary.sector_id << endl;
      cout << "binary_bytes_count:" << binary_bytes_count << endl;

  		if(serial_receive_size < 1){
  			cout << "Should have recieved:" << fsize << " But recevied only " << total_read_bytes << ". Missing " << fsize - total_read_bytes << " bytes." <<endl;
        // Close file
        fclose(debug_file);
  			return 0;
  		}

  		// Write recieved data to a file
  		fwrite(flash.binary.binary_data, 1, binary_bytes_count, debug_file);

  		// Actual bytes written to file
  		total_read_bytes +=binary_bytes_count;
    }

    // Increment loop counter
    loop_counter++;

	}

  cout << "Total Read Firmware Size: " << total_read_bytes << endl;

  fclose(debug_file);

  return total_read_bytes;

}
/** Flasher isChecksumMatch.
* @brief Return the checksum if two files match the checksum, 0 otherwise
* @param filname_one The firmware path.
* @param filname_two The read firmware path.
*/
uint32_t Flasher::isChecksumMatch(const std::string &filname_one, const std::string &filname_two){

  unsigned int checksum_file_one = getFileChecksum(filname_one);
  unsigned int checksum_file_two = getFileChecksum(filname_two);

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
uint32_t Flasher::rawBytesChecksum(unsigned char *buffer, size_t length)
{
  unsigned int sum;       // nothing gained in using smaller types!
  for ( sum = 0 ; length != 0 ; length-- ){
      sum += *(buffer++);   // parenthesis not required!
	}
  return (uint32_t)sum;
}
/** Flasher getFileChecksum.
* @brief Return the sum from the given binary file. Positive number for checksum, -1 for error.
* @param filname The firmware path.
*/
uint32_t Flasher::getFileChecksum(const std::string &filname){
	FILE * file;
	long file_size;
	char * buffer;
	size_t result;

	file = fopen ( filname.c_str() , "rb" );
	if (file==NULL) {
    cout << "Could not open file " << filname << " to calculate the checksum."<< endl;
    return -1;
  }

	// Get file size:
	fseek (file , 0 , SEEK_END);
	file_size = ftell (file);
	rewind (file);

	// allocate memory to contain the whole file:
	buffer = (char*) new char[file_size];
  // Handel allocating error
	if (buffer == NULL){
    return -1;
  }

	// Copy the file into the buffer:
	result = fread (buffer,1,file_size,file);
	if (result != file_size){
    return -1;
  }

  // Get file checksum
	uint32_t sum = (unsigned int)rawBytesChecksum((unsigned char*)buffer,file_size);

	// Close the opened file
	fclose (file);
  // Free the buffer
	delete[] buffer;

	return sum;
}
