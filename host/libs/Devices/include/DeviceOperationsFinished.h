#ifndef DEVICE_OPERATIONS_FINISHED_H
#define DEVICE_OPERATIONS_FINISHED_H

#include <climits>

namespace strata {

// special values for DeviceOperations finished() signal
constexpr int OPERATION_DEFAULT_DATA(INT_MIN);
constexpr int OPERATION_BACKUP_NO_FIRMWARE(-100);

}

#endif
