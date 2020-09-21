#ifndef DEVICE_OPERATIONS_FINISHED_H
#define DEVICE_OPERATIONS_FINISHED_H

#include <climits>

namespace strata::device::operation {

// special values for device operation finished() signal
constexpr int DEFAULT_DATA(INT_MIN);
constexpr int ALREADY_IN_BOOTLOADER(1);
constexpr int BACKUP_NO_FIRMWARE(-100);
constexpr int BACKUP_STARTED(-101);
constexpr int FLASH_STARTED(-102);

}

#endif
