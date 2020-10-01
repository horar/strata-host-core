#ifndef FLASHER_CONSTANTS_H_
#define FLASHER_CONSTANTS_H_

#include <chrono>

namespace strata {

// size of chunk in bytes
constexpr int CHUNK_SIZE = 256;

// emit progress signal every X_PROGRESS_STEP chunks
constexpr int FLASH_PROGRESS_STEP = 5;
constexpr int BACKUP_PROGRESS_STEP = 5;

// delay between flash bootloader and identify operation
constexpr std::chrono::milliseconds IDENTIFY_OPERATION_DELAY(1000);

// max count of 'get_firmware_info' command retries in identify operation
constexpr uint MAX_GET_FW_INFO_RETRIES = 5;

}

#endif // FLASHER_CONSTANTS_H_
