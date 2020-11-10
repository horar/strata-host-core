#ifndef DEVICE_OPERATIONS_STATUS_H
#define DEVICE_OPERATIONS_STATUS_H

#include <climits>

namespace strata::device::operation {

// special values of status for device operation finished() signal
constexpr int DEFAULT_STATUS(INT_MIN);
constexpr int ALREADY_IN_BOOTLOADER(1);
constexpr int BACKUP_NO_FIRMWARE(-100);
constexpr int BACKUP_STARTED(-101);
constexpr int FLASH_STARTED(-102);
constexpr int SET_PLATFORM_ID_FAILED(-200);
constexpr int PLATFORM_ID_ALREADY_SET(-201);
constexpr int BOARD_NOT_CONNECTED_TO_CONTROLLER(-202);

}

#endif
