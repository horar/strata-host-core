/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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

// delay between flash bootloader and identify operation for test purposes
constexpr std::chrono::milliseconds IDENTIFY_OPERATION_MOCK_DELAY(1);

// max count of 'get_firmware_info' command retries in identify operation
constexpr unsigned int MAX_GET_FW_INFO_RETRIES = 5;

}

#endif // FLASHER_CONSTANTS_H_
